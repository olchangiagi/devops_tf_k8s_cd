```bat
@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem ============================================================
rem Run k6 HPA load test with Docker on Windows
rem Usage:
rem   load-test\run-load-test.bat http://ALB_ADDRESS/test-path
rem ============================================================

set "TARGET_URL=%~1"
set "SCRIPT_DIR=%~dp0"

if "%TARGET_URL%"=="" (
    echo.
    echo [ERROR] Target URL is required.
    echo.
    echo Usage:
    echo   load-test\run-load-test.bat http://ALB_ADDRESS/test-path
    echo.
    exit /b 1
)

where docker >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Docker command was not found.
    echo Install Docker Desktop and check PATH.
    echo.
    exit /b 1
)

docker info >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Docker Desktop is not running.
    echo Start Docker Desktop and try again.
    echo.
    exit /b 1
)

if not exist "%SCRIPT_DIR%hpa-test.js" (
    echo.
    echo [ERROR] hpa-test.js was not found.
    echo Expected file:
    echo   %SCRIPT_DIR%hpa-test.js
    echo.
    exit /b 1
)

echo.
echo ============================================================
echo k6 HPA Load Test
echo ============================================================
echo Target: %TARGET_URL%
echo.

docker run --rm ^
  -e TARGET_URL="%TARGET_URL%" ^
  -v "%SCRIPT_DIR%:/scripts:ro" ^
  grafana/k6:latest run /scripts/hpa-test.js

set "RESULT=%ERRORLEVEL%"

echo.
if "%RESULT%"=="0" (
    echo [OK] Load test completed successfully.
) else (
    echo [ERROR] Load test failed. Exit code: %RESULT%
)

endlocal
exit /b %RESULT%
```
