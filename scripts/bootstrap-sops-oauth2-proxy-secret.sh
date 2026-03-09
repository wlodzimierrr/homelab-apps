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
if [[ "$env_name" != "dev" ]]; then
  echo "usage: $0 [dev]"
  exit 1
fi

secret_path="apps/homelab-web/envs/${env_name}/oauth2-proxy-secret.enc.yaml"
generator_path="apps/homelab-web/envs/${env_name}/oauth2-proxy-secret-generator.yaml"
kustomization_path="apps/homelab-web/envs/${env_name}/kustomization.yaml"

read -rp "OAUTH2_PROXY_CLIENT_ID: " client_id
if [[ -z "$client_id" ]]; then
  echo "OAUTH2_PROXY_CLIENT_ID cannot be empty"
  exit 1
fi

read -rsp "OAUTH2_PROXY_CLIENT_SECRET: " client_secret
echo
if [[ -z "$client_secret" ]]; then
  echo "OAUTH2_PROXY_CLIENT_SECRET cannot be empty"
  exit 1
fi

read -rp "Generate a new cookie secret? [Y/n]: " rotate_cookie_secret
rotate_cookie_secret="${rotate_cookie_secret:-Y}"

cookie_secret=""
if [[ "$rotate_cookie_secret" =~ ^[Yy]$ ]]; then
  cookie_secret="$(openssl rand -base64 32 | tr -d '\n')"
else
  read -rsp "OAUTH2_PROXY_COOKIE_SECRET: " cookie_secret
  echo
  if [[ -z "$cookie_secret" ]]; then
    echo "OAUTH2_PROXY_COOKIE_SECRET cannot be empty"
    exit 1
  fi
fi

tmp_plain="$(mktemp)"
cat > "$tmp_plain" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: oauth2-proxy-secret
  namespace: homelab-web
type: Opaque
stringData:
  OAUTH2_PROXY_CLIENT_ID: ${client_id}
  OAUTH2_PROXY_CLIENT_SECRET: ${client_secret}
  OAUTH2_PROXY_COOKIE_SECRET: ${cookie_secret}
EOF

cp "$tmp_plain" "$secret_path"
sops --encrypt --in-place "$secret_path"
rm -f "$tmp_plain"

cat > "$generator_path" <<'EOF'
apiVersion: viaduct.ai/v1
kind: ksops
metadata:
  name: oauth2-proxy-secret-generator
  annotations:
    config.kubernetes.io/function: |
      exec:
        path: ksops
files:
  - oauth2-proxy-secret.enc.yaml
EOF

if ! grep -qE '^[[:space:]]*-[[:space:]]*oauth2-proxy-secret-generator\.yaml[[:space:]]*$' "$kustomization_path"; then
  awk '
    /^generators:/ && inserted == 0 { print; print "  - oauth2-proxy-secret-generator.yaml"; inserted = 1; next }
    /^commonLabels:/ && inserted == 0 { print "generators:"; print "  - oauth2-proxy-secret-generator.yaml"; inserted = 1 }
    { print }
  ' "$kustomization_path" > "${kustomization_path}.tmp"
  mv "${kustomization_path}.tmp" "$kustomization_path"
fi

echo "created: $secret_path"
echo "created: $generator_path"
echo "updated: $kustomization_path"
echo "next: ./scripts/check-secrets-guardrails.sh && ./scripts/render-kustomize.sh apps/homelab-web/envs/${env_name} >/dev/null"
