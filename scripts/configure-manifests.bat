@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul

set "ROOT_DIR=%~dp0.."
for %%I in ("%ROOT_DIR%") do set "ROOT_DIR=%%~fI"

if "%~1"=="" (
  if defined CI_INFRA_DIR (
    set "CI_INFRA_DIR=%CI_INFRA_DIR%"
  ) else (
    set "CI_INFRA_DIR=%ROOT_DIR%\..\tf-k8s-ci\infra"
  )
) else (
  set "CI_INFRA_DIR=%~1"
)

if "%~2"=="" (
  if defined INITIAL_IMAGE_TAG (
    set "IMAGE_TAG=%INITIAL_IMAGE_TAG%"
  ) else (
    set "IMAGE_TAG=dev-latest"
  )
) else (
  set "IMAGE_TAG=%~2"
)

for %%I in ("%CI_INFRA_DIR%") do set "CI_INFRA_DIR=%%~fI"
set "OVERLAY_FILE=%ROOT_DIR%\k8s\overlays\dev\kustomization.yaml"

where terraform >nul 2>&1
if errorlevel 1 (
  echo [ERROR] terraform 명령을 찾을 수 없습니다.
  exit /b 1
)

where python >nul 2>&1
if errorlevel 1 (
  echo [ERROR] python 명령을 찾을 수 없습니다.
  exit /b 1
)

if not exist "%CI_INFRA_DIR%" (
  echo [ERROR] tf-k8s-ci Terraform 디렉터리가 없습니다:
  echo         %CI_INFRA_DIR%
  exit /b 1
)

call :terraform_output WEB_REPO web_ecr_repository_url
if errorlevel 1 exit /b 1

call :terraform_output WAS_REPO was_ecr_repository_url
if errorlevel 1 exit /b 1

python "%ROOT_DIR%\scripts\update_images.py" ^
  --file "%OVERLAY_FILE%" ^
  --web-image "%WEB_REPO%" ^
  --was-image "%WAS_REPO%" ^
  --tag "%IMAGE_TAG%"

exit /b %ERRORLEVEL%

:terraform_output
set "%~1="
for /f "usebackq delims=" %%A in (`terraform -chdir^="%CI_INFRA_DIR%" output -raw %~2`) do set "%~1=%%A"
if not defined %~1 (
  echo [ERROR] Terraform output을 읽지 못했습니다: %~2
  exit /b 1
)
exit /b 0
