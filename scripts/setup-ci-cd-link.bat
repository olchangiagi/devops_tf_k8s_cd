@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

if "%~2"=="" (
  echo 사용법: %~nx0 GitHub_ID\tf-k8s-ci GitHub_ID\tf-k8s-cd
  exit /b 1
)

set "CI_REPOSITORY=%~1"
set "CI_REPOSITORY=%CI_REPOSITORY:\=/%"
set "CD_REPOSITORY=%~2"
set "CD_REPOSITORY=%CD_REPOSITORY:\=/%"

where gh >nul 2>&1
if errorlevel 1 (
  echo [ERROR] GitHub CLI^(gh^)가 필요합니다.
  exit /b 1
)

if not defined CD_REPOSITORY_TOKEN (
  echo [ERROR] 먼저 다음 환경변수를 설정하세요:
  echo set "CD_REPOSITORY_TOKEN=발급한_토큰"
  exit /b 1
)

gh auth status
if errorlevel 1 exit /b 1

gh variable set CD_REPOSITORY ^
  --repo "%CI_REPOSITORY%" ^
  --body "%CD_REPOSITORY%"
if errorlevel 1 exit /b 1

echo %CD_REPOSITORY_TOKEN% | gh secret set CD_REPOSITORY_TOKEN --repo "%CI_REPOSITORY%"
if errorlevel 1 exit /b 1

echo [OK] %CI_REPOSITORY%에 CD_REPOSITORY 변수와 CD_REPOSITORY_TOKEN Secret을 등록했습니다.
exit /b 0
