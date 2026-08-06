#!/usr/bin/env bash
set -Eeuo pipefail

ARGOCD_VERSION="${ARGOCD_VERSION:-v3.4.6}"
INSTALL_URL="https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "[ERROR] kubectl 명령을 찾을 수 없습니다." >&2
  exit 1
fi

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f "${INSTALL_URL}"

kubectl wait \
  --for=condition=Available \
  deployment \
  --all \
  -n argocd \
  --timeout=15m

kubectl rollout status \
  statefulset/argocd-application-controller \
  -n argocd \
  --timeout=15m

echo "[OK] Argo CD ${ARGOCD_VERSION} 설치 완료"
