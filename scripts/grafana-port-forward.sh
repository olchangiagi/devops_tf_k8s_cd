#!/usr/bin/env bash
# macOS/Linux에서 Grafana Service를 로컬 3000번 포트로 연결한다.
set -euo pipefail

# Grafana Pod가 Ready 상태가 될 때까지 최대 10분 대기한다.
kubectl wait --for=condition=Ready pod \
  -l app.kubernetes.io/name=grafana \
  -n monitoring \
  --timeout=600s

# 브라우저에서 http://localhost:3000 으로 접속할 수 있다.
kubectl port-forward \
  -n monitoring \
  svc/kube-prometheus-stack-grafana \
  3000:80
