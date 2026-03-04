#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

echo "[rbac-guardrails] scanning workloads manifests..."

fail=0
rbac_files="$(rg -l --glob 'apps/**/*.yaml' 'kind:\s*(Role|ClusterRole|RoleBinding|ClusterRoleBinding)' apps || true)"

# 1) App workloads must not define cluster-admin bindings.
if rg -n --glob 'apps/**/*.yaml' 'kind:\s*ClusterRoleBinding|name:\s*cluster-admin' apps >/tmp/rbac_cluster_admin_hits.txt; then
  echo "[rbac-guardrails] FAIL: disallowed cluster-admin/ClusterRoleBinding in apps/"
  cat /tmp/rbac_cluster_admin_hits.txt
  fail=1
else
  echo "[rbac-guardrails] OK: no cluster-admin ClusterRoleBinding in apps/"
fi

# 2) Prevent wildcard RBAC rules in app roles.
if [[ -n "${rbac_files}" ]]; then
  if rg -n '^\s*-\s*"\*"\s*$|^\s*-\s*\*\s*$' ${rbac_files} >/tmp/rbac_wildcard_hits.txt; then
    echo "[rbac-guardrails] FAIL: wildcard RBAC token found in apps RBAC manifests"
    cat /tmp/rbac_wildcard_hits.txt
    fail=1
  else
    echo "[rbac-guardrails] OK: no wildcard RBAC tokens in apps RBAC manifests"
  fi
else
  echo "[rbac-guardrails] OK: no app RBAC manifests found to evaluate for wildcards"
fi

if [[ "$fail" -ne 0 ]]; then
  echo "[rbac-guardrails] result: FAILED"
  exit 1
fi

echo "[rbac-guardrails] result: PASSED"
