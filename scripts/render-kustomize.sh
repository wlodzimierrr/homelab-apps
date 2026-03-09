#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

overlay="${1:-}"
if [[ -z "$overlay" ]]; then
  echo "usage: $0 <kustomize-path>" >&2
  exit 1
fi

overlay_abs="$(cd "$overlay" && pwd)"

if [[ ! -f "$overlay_abs/kustomization.yaml" ]]; then
  echo "missing kustomization.yaml in $overlay" >&2
  exit 1
fi

if ! command -v kustomize >/dev/null 2>&1; then
  echo "kustomize is required to render $overlay" >&2
  exit 1
fi

render_with_placeholders() {
  local overlay_path="$1"
  local repo_copy
  local overlay_copy
  local overlay_rel
  local generator_file
  local enc_file
  local placeholder_name
  local placeholder_list=""

  overlay_rel="${overlay_path#$repo_root/}"
  repo_copy="$(mktemp -d)"
  trap 'rm -rf "$repo_copy"' RETURN
  cp -R "$repo_root"/. "$repo_copy/"
  overlay_copy="$repo_copy/$overlay_rel"

  make_placeholder_secret() {
    local source_file="$1"
    local output_file="$2"
    awk '
      /^sops:[[:space:]]*$/ { exit }
      /^data:[[:space:]]*$/ { in_data=1; in_string_data=0; print; next }
      /^stringData:[[:space:]]*$/ { in_data=0; in_string_data=1; print; next }
      {
        if ($0 ~ /^[^[:space:]]/) {
          in_data=0
          in_string_data=0
        }
        if (in_data && $0 ~ /^[[:space:]]+[A-Za-z0-9_.-]+:[[:space:]]*/) {
          sub(/:.*/, ": ZHVtbXk=")
          print
          next
        }
        if (in_string_data && $0 ~ /^[[:space:]]+[A-Za-z0-9_.-]+:[[:space:]]*/) {
          sub(/:.*/, ": dummy")
          print
          next
        }
        print
      }
    ' "$source_file" >"$output_file"
  }

  while IFS= read -r -d '' generator_file; do
    while IFS= read -r enc_file; do
      [[ -z "$enc_file" ]] && continue
      placeholder_name="$(basename "${enc_file%.enc.yaml}").ci-placeholder.yaml"
      make_placeholder_secret "$overlay_copy/$enc_file" "$overlay_copy/$placeholder_name"
      placeholder_list+="${placeholder_name}"$'\n'
    done < <(sed -nE 's/^[[:space:]]*-[[:space:]]*(.*secret.*\.enc\.ya?ml)[[:space:]]*$/\1/p' "$generator_file")
  done < <(find "$overlay_copy" -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) -print0)

  awk -v placeholders="$placeholder_list" '
    BEGIN {
      placeholder_count = split(placeholders, placeholder_files, "\n")
    }

    function emit_placeholders() {
      if (placeholders_emitted == 0) {
        for (i = 1; i <= placeholder_count; i++) {
          if (placeholder_files[i] != "") {
            print "  - " placeholder_files[i]
          }
        }
        placeholders_emitted = 1
      }
    }

    /^resources:[[:space:]]*$/ {
      in_resources = 1
      print
      next
    }

    in_resources {
      if ($0 ~ /^[[:space:]]*-[[:space:]]/) {
        print
        next
      }
      emit_placeholders()
      in_resources = 0
    }

    /^generators:[[:space:]]*$/ {
      skip_generators = 1
      next
    }

    skip_generators {
      if ($0 ~ /^[[:space:]]*-[[:space:]]/) {
        next
      }
      if ($0 ~ /^[^[:space:]]/ || $0 == "") {
        skip_generators = 0
      } else {
        next
      }
    }

    { print }

    END {
      if (in_resources) {
        emit_placeholders()
      }
    }
  ' "$overlay_copy/kustomization.yaml" >"$overlay_copy/kustomization.yaml.tmp"
  mv "$overlay_copy/kustomization.yaml.tmp" "$overlay_copy/kustomization.yaml"

  kustomize build "$overlay_copy"
}

can_decrypt_ksops_sources() {
  local overlay_path="$1"
  local generator_file
  local enc_file

  command -v sops >/dev/null 2>&1 || return 1

  while IFS= read -r -d '' generator_file; do
    while IFS= read -r enc_file; do
      [[ -z "$enc_file" ]] && continue
      if ! sops --decrypt "$overlay_path/$enc_file" >/dev/null 2>&1; then
        return 1
      fi
    done < <(sed -nE 's/^[[:space:]]*-[[:space:]]*(.*secret.*\.enc\.ya?ml)[[:space:]]*$/\1/p' "$generator_file")
  done < <(find "$overlay_path" -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) -print0)

  return 0
}

uses_ksops=0
while IFS= read -r -d '' file; do
  if grep -qE '^kind:[[:space:]]*ksops[[:space:]]*$' "$file"; then
    uses_ksops=1
    break
  fi
done < <(find "$overlay_abs" -type f \( -name '*.yml' -o -name '*.yaml' \) -print0)

if (( uses_ksops )); then
  if command -v ksops >/dev/null 2>&1 && can_decrypt_ksops_sources "$overlay_abs"; then
    kustomize build --enable-alpha-plugins --enable-exec "$overlay_abs"
    exit 0
  fi

  if [[ "${CI:-}" == "true" || "${RENDER_ALLOW_PLACEHOLDER_SECRETS:-}" == "1" ]]; then
    render_with_placeholders "$overlay_abs"
    exit 0
  fi

  if ! command -v ksops >/dev/null 2>&1; then
    echo "ksops is required to render $overlay because it contains ksops generators" >&2
  else
    echo "unable to decrypt SOPS-managed secrets for $overlay; set SOPS_AGE_KEY_FILE or use CI placeholder mode" >&2
  fi
  exit 1
fi

kustomize build --enable-alpha-plugins --enable-exec "$overlay_abs"
