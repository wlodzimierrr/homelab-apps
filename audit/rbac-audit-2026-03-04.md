# RBAC Audit Report - 2026-03-04

## Scope

- Repository: `workloads`
- Areas reviewed:
  - `apps/**`
  - `platform/**`
  - `environments/**`
  - `bootstrap/**`
- Target ticket: `T3.1.2 Audit and tighten Kubernetes service account permissions`

## Audit commands

```bash
rg -n "kind:\s*(ServiceAccount|Role|ClusterRole|RoleBinding|ClusterRoleBinding)|cluster-admin|\*" -S apps platform environments bootstrap
```

```bash
./scripts/check-rbac-guardrails.sh
```

## Findings

### RBAC objects present for app workloads

- `apps/homelab-api/base/serviceaccount-backend.yaml` (`ServiceAccount`)
- `apps/homelab-web/base/serviceaccount-web.yaml` (`ServiceAccount`)
- `apps/homelab-api/base/role-backend-kube-api-read.yaml` (`Role`)
- `apps/homelab-api/base/rolebinding-backend-kube-api-read.yaml` (`RoleBinding`)

### Risk checks

- No `ClusterRoleBinding` in `apps/**`.
- No `cluster-admin` role references in `apps/**`.
- No wildcard (`*`) verbs/resources/apiGroups in app RBAC manifests.
- App RBAC remains namespace-scoped (`Role` + `RoleBinding`) for `homelab-api`.

## Tightening actions completed

- Added guardrail script: `scripts/check-rbac-guardrails.sh`
  - Fails if app manifests introduce:
    - `ClusterRoleBinding`
    - `cluster-admin` references
    - wildcard RBAC tokens (`*`)

## Conclusion

- Acceptance criterion 1 met: no cluster-admin bindings for app workloads.
- Acceptance criterion 2 met: RBAC audit report committed.
