@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

rem Grafana Secret의 Base64 비밀번호를 PowerShell로 복호화한다.
for /f "delims=" %%A in ('kubectl get secret -n monitoring kube-prometheus-stack-grafana -o jsonpath^="{.data.admin-password}"') do set "ENCODED_PASSWORD=%%A"

if not defined ENCODED_PASSWORD (
  echo [ERROR] Grafana 비밀번호 Secret을 찾을 수 없습니다.
  exit /b 1
)

powershell -NoProfile -Command "[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('%ENCODED_PASSWORD%'))"
