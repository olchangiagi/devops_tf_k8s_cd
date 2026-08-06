@echo off
setlocal EnableExtensions
chcp 65001 >nul

rem Grafana Pod가 Ready 상태가 될 때까지 최대 10분 대기한다.
kubectl wait --for=condition=Ready pod ^
  -l app.kubernetes.io/name=grafana ^
  -n monitoring ^
  --timeout=600s
if errorlevel 1 (
  echo [ERROR] Grafana Pod가 Ready 상태가 되지 않았습니다.
  exit /b 1
)

rem 브라우저에서 http://localhost:3000 으로 접속할 수 있다.
kubectl port-forward ^
  -n monitoring ^
  svc/kube-prometheus-stack-grafana ^
  3000:80
