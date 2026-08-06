#!/usr/bin/env bash
# macOS/Linux에서 Grafana admin 비밀번호를 Secret에서 복호화해 출력한다.
set -euo pipefail

kubectl get secret \
  -n monitoring \
  kube-prometheus-stack-grafana \
  -o jsonpath='{.data.admin-password}' | base64 --decode
printf '\n'
