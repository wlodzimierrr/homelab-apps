#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

required_files=(
  "bootstrap/argocd-oidc.yaml"
  "apps/homelab-web/envs/dev/oauth2-proxy.yaml"
  "apps/homelab-web/envs/dev/middleware-oauth2.yaml"
  "apps/homelab-web/envs/dev/networkpolicy-allow-ingress-oauth2-proxy.yaml"
  "apps/homelab-web/envs/dev/networkpolicy-allow-egress-oauth2-proxy.yaml"
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "missing required file: $file" >&2
    exit 1
  fi
done

"$repo_root/scripts/render-kustomize.sh" apps/homelab-web/envs/dev >/dev/null

echo "sso manifest validation passed"
