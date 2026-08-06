#!/usr/bin/env bash
set -Eeuo pipefail

PASSWORD="$(
  kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath='{.data.password}' | base64 --decode
)"

echo "Argo CD URL      : https://localhost:8080"
echo "Argo CD Username : admin"
echo "Argo CD Password : ${PASSWORD}"
echo
echo "종료하려면 Ctrl+C를 누르세요."

kubectl -n argocd port-forward svc/argocd-server 8080:443
