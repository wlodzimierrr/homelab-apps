#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

if ! command -v sops >/dev/null 2>&1; then
  echo "sops is required but not installed."
  exit 1
fi

if [[ ! -f .sops.yaml ]]; then
  echo "missing workloads/.sops.yaml"
  exit 1
fi

if grep -q 'age1REPLACE_WITH_YOUR_PUBLIC_KEY' .sops.yaml; then
  echo "replace placeholder age recipient in workloads/.sops.yaml first"
  exit 1
fi

env_name="${1:-dev}"
if [[ "$env_name" != "dev" && "$env_name" != "prod" ]]; then
  echo "usage: $0 [dev|prod]"
  exit 1
fi

secret_path="apps/homelab-api/envs/${env_name}/postgres-secret.enc.yaml"
generator_path="apps/homelab-api/envs/${env_name}/postgres-secret-generator.yaml"
kustomization_path="apps/homelab-api/envs/${env_name}/kustomization.yaml"

read -rp "POSTGRES_DB [homelab]: " postgres_db
postgres_db="${postgres_db:-homelab}"

read -rp "POSTGRES_USER [homelab]: " postgres_user
postgres_user="${postgres_user:-homelab}"

read -rsp "POSTGRES_PASSWORD: " postgres_password
echo
if [[ -z "$postgres_password" ]]; then
  echo "POSTGRES_PASSWORD cannot be empty"
  exit 1
fi

tmp_plain="$(mktemp)"
cat > "$tmp_plain" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: homelab-api-postgres
  namespace: homelab-api
type: Opaque
stringData:
  POSTGRES_DB: ${postgres_db}
  POSTGRES_USER: ${postgres_user}
  POSTGRES_PASSWORD: ${postgres_password}
EOF

cp "$tmp_plain" "$secret_path"
sops --encrypt --in-place "$secret_path"
rm -f "$tmp_plain"

cat > "$generator_path" <<'EOF'
apiVersion: viaduct.ai/v1
kind: ksops
metadata:
  name: postgres-secret-generator
  annotations:
    config.kubernetes.io/function: |
      exec:
        path: ksops
files:
  - postgres-secret.enc.yaml
EOF

if grep -qE '^[[:space:]]*-[[:space:]]*postgres-secret\.enc\.yaml[[:space:]]*$' "$kustomization_path"; then
  awk '
    /^[[:space:]]*-[[:space:]]*postgres-secret\.enc\.yaml[[:space:]]*$/ { next }
    { print }
  ' "$kustomization_path" > "${kustomization_path}.tmp"
  mv "${kustomization_path}.tmp" "$kustomization_path"
fi

if ! grep -qE '^[[:space:]]*-[[:space:]]*postgres-secret-generator\.yaml[[:space:]]*$' "$kustomization_path"; then
  awk '
    /^generators:/ && inserted == 0 { print; print "  - postgres-secret-generator.yaml"; inserted = 1; next }
    /^commonLabels:/ && inserted == 0 { print "generators:"; print "  - postgres-secret-generator.yaml"; inserted = 1 }
    { print }
  ' "$kustomization_path" > "${kustomization_path}.tmp"
  mv "${kustomization_path}.tmp" "$kustomization_path"
fi

echo "created: $secret_path"
echo "created: $generator_path"
echo "updated: $kustomization_path"
echo "next: ./scripts/check-secrets-guardrails.sh && ./scripts/render-kustomize.sh apps/homelab-api/envs/${env_name} >/dev/null"
