#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

fail=0

echo "[check] scanning for plaintext Kubernetes Secret manifests in workloads/"
while IFS= read -r -d '' file; do
  if grep -qE '^kind:[[:space:]]*Secret[[:space:]]*$' "$file"; then
    if ! grep -qE '^sops:[[:space:]]*$' "$file"; then
      echo "[fail] plaintext Secret manifest detected (missing sops block): ${file#$repo_root/}"
      fail=1
    fi
  fi
done < <(find apps bootstrap platform environments -type f \( -name '*.yml' -o -name '*.yaml' \) -print0)

if (( fail )); then
  cat <<'EOF'
[result] FAIL
- Only SOPS-encrypted Secret manifests are allowed in workloads/.
- Convert plaintext Secret files to SOPS format (*.enc.yaml) before commit.
EOF
  exit 1
fi

echo "[result] PASS"
