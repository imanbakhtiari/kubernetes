#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Force delete a Kubernetes namespace by removing finalizers from all namespaced resources,
then removing namespace finalizers, then deleting the namespace immediately.

USAGE:
  force-delete-namespace.sh [--include-crds --crd-match <pattern> ...] <namespace>

OPTIONS:
  --include-crds
      Also delete cluster-scoped CRDs that match one or more --crd-match patterns.
      NOTE: CRDs are NOT namespaced. This is optional and OFF by default.

  --crd-match <pattern>
      Pattern used to select CRDs for deletion. You can pass this option multiple times.
      Matching is substring-based against the CRD name (e.g., "velero.io" matches "backups.velero.io").

      Examples:
        --crd-match velero.io
        --crd-match snapshot.storage.k8s.io
        --crd-match longhorn.io

  -h, --help
      Show this help.

EXAMPLES:
  # Force delete namespace only (default behavior)
  ./force-delete-namespace.sh velero

  # Force delete namespace AND delete Velero CRDs
  ./force-delete-namespace.sh --include-crds --crd-match velero.io velero

  # Force delete namespace AND delete multiple CRD groups
  ./force-delete-namespace.sh --include-crds \
    --crd-match velero.io \
    --crd-match snapshot.storage.k8s.io \
    velero

SAFETY:
  - This script removes ALL finalizers from ALL namespaced resources in the given namespace.
  - With --include-crds, it deletes CRDs cluster-wide that match your patterns. Use carefully.
EOF
}

INCLUDE_CRDS="false"
CRD_MATCHES=()

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --include-crds)
      INCLUDE_CRDS="true"
      shift
      ;;
    --crd-match)
      [[ $# -lt 2 ]] && { echo "ERROR: --crd-match requires a value"; exit 1; }
      CRD_MATCHES+=("$2")
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "ERROR: Unknown option: $1"
      echo
      usage
      exit 1
      ;;
    *)
      # first non-flag is namespace; remainder is error
      NS="$1"
      shift
      if [[ $# -gt 0 ]]; then
        echo "ERROR: Unexpected extra arguments: $*"
        echo
        usage
        exit 1
      fi
      ;;
  esac
done

NS="${NS:-}"

if [[ -z "$NS" ]]; then
  usage
  exit 1
fi

echo "⚠️  FORCE DELETING NAMESPACE: $NS"
echo "----------------------------------"

# Sanity check kubectl connectivity
kubectl version --short >/dev/null 2>&1 || {
  echo "ERROR: kubectl cannot reach the cluster."
  exit 1
}

# 1) Remove finalizers from ALL namespaced resources in the namespace
echo "🔨 Removing finalizers from all namespaced resources in '$NS'..."

# Iterate over all namespaced resource kinds that support list
while read -r kind; do
  [[ -z "$kind" ]] && continue
  # List objects; if none, skip quietly
  kubectl get "$kind" -n "$NS" -o name 2>/dev/null | while read -r obj; do
    [[ -z "$obj" ]] && continue
    echo "  - Patching $obj"
    kubectl patch -n "$NS" "$obj" --type=merge -p '{"metadata":{"finalizers":[]}}' 2>/dev/null || true
  done
done < <(kubectl api-resources --verbs=list --namespaced -o name 2>/dev/null)

# 2) Remove namespace finalizers
echo "🔨 Removing namespace finalizers..."
kubectl patch ns "$NS" --type=merge -p '{"spec":{"finalizers":[]}}' 2>/dev/null || true

# 3) Force delete namespace
echo "💣 Deleting namespace (force, grace=0)..."
kubectl delete ns "$NS" --grace-period=0 --force 2>/dev/null || true

# 4) Optionally delete CRDs (cluster-scoped) by pattern
if [[ "$INCLUDE_CRDS" == "true" ]]; then
  if [[ ${#CRD_MATCHES[@]} -eq 0 ]]; then
    echo "ERROR: --include-crds was set but no --crd-match patterns were provided."
    echo "Refusing to delete CRDs without explicit patterns."
    exit 1
  fi

  echo "🧨 Deleting CRDs matching patterns: ${CRD_MATCHES[*]}"
  ALL_CRDS="$(kubectl get crd -o name 2>/dev/null || true)"

  for pat in "${CRD_MATCHES[@]}"; do
    echo "  Pattern: $pat"
    echo "$ALL_CRDS" | grep -F "$pat" | while read -r crd; do
      [[ -z "$crd" ]] && continue
      echo "   - Deleting $crd"
      kubectl delete "$crd" --grace-period=0 --force 2>/dev/null || true
    done
  done
else
  echo "ℹ️  CRD deletion is disabled (default). Use --include-crds with --crd-match to delete CRDs."
fi

echo "✅ Done."

