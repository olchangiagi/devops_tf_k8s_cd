@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

for /f "usebackq delims=" %%A in (`powershell -NoProfile -Command "$b=kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}'; [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b))"`) do set "ARGOCD_PASSWORD=%%A"

echo Argo CD URL      : https://localhost:8080
echo Argo CD Username : admin
echo Argo CD Password : %ARGOCD_PASSWORD%
echo.
echo 새 CMD 창에서 Port Forward를 실행합니다.

start "Argo CD Port Forward" cmd /k kubectl -n argocd port-forward svc/argocd-server 8080:443
timeout /t 2 >nul
start "" https://localhost:8080

exit /b 0
