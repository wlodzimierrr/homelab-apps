#!/usr/bin/env bash
set -euo pipefail

namespace="${1:-}"
deployment="${2:-}"
max_seconds="${3:-300}"

if [[ -z "$namespace" || -z "$deployment" ]]; then
  echo "usage: $0 <namespace> <deployment> [max_seconds]"
  exit 1
fi

start_epoch="$(date +%s)"
echo "[check] waiting for rollout: namespace=${namespace} deployment=${deployment} max=${max_seconds}s"
kubectl -n "$namespace" rollout status "deployment/${deployment}" --timeout="${max_seconds}s"
end_epoch="$(date +%s)"

elapsed="$((end_epoch - start_epoch))"
echo "[result] rollout completed in ${elapsed}s"

if (( elapsed > max_seconds )); then
  echo "[fail] rollout exceeded SLO (${elapsed}s > ${max_seconds}s)"
  exit 1
fi

echo "[pass] rollout within SLO"
