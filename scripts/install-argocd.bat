@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

if not defined ARGOCD_VERSION set "ARGOCD_VERSION=v3.4.6"
set "INSTALL_URL=https://raw.githubusercontent.com/argoproj/argo-cd/%ARGOCD_VERSION%/manifests/install.yaml"

where kubectl >nul 2>&1
if errorlevel 1 (
  echo [ERROR] kubectl 명령을 찾을 수 없습니다.
  exit /b 1
)

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
if errorlevel 1 exit /b 1

kubectl apply -n argocd --server-side --force-conflicts -f "%INSTALL_URL%"
if errorlevel 1 exit /b 1

kubectl wait --for=condition=Available deployment --all -n argocd --timeout=15m
if errorlevel 1 exit /b 1

kubectl rollout status statefulset/argocd-application-controller -n argocd --timeout=15m
if errorlevel 1 exit /b 1

echo [OK] Argo CD %ARGOCD_VERSION% 설치 완료
exit /b 0
