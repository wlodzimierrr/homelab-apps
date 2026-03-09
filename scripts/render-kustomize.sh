#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

overlay="${1:-}"
if [[ -z "$overlay" ]]; then
  echo "usage: $0 <kustomize-path>" >&2
  exit 1
fi

if [[ ! -f "$overlay/kustomization.yaml" ]]; then
  echo "missing kustomization.yaml in $overlay" >&2
  exit 1
fi

if ! command -v kustomize >/dev/null 2>&1; then
  echo "kustomize is required to render $overlay" >&2
  exit 1
fi

uses_ksops=0
while IFS= read -r -d '' file; do
  if grep -qE '^kind:[[:space:]]*ksops[[:space:]]*$' "$file"; then
    uses_ksops=1
    break
  fi
done < <(find "$overlay" -type f \( -name '*.yml' -o -name '*.yaml' \) -print0)

if (( uses_ksops )) && ! command -v ksops >/dev/null 2>&1; then
  echo "ksops is required to render $overlay because it contains ksops generators" >&2
  exit 1
fi

kustomize build --enable-alpha-plugins --enable-exec "$overlay"
