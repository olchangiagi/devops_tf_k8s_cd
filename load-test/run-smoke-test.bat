```bat
@echo off
setlocal EnableExtensions DisableDelayedExpansion

rem ============================================================
rem Run k6 smoke test with Docker on Windows
rem Usage:
rem   load-test\run-smoke-test.bat http://ALB_ADDRESS
rem ============================================================

set "TARGET_URL=%~1"
set "SCRIPT_DIR=%~dp0"

if "%TARGET_URL%"=="" (
    echo.
    echo [ERROR] Target URL is required.
    echo.
    echo Usage:
    echo   load-test\run-smoke-test.bat http://ALB_ADDRESS
    echo.
    exit /b 1
)

where docker >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Docker command was not found.
    echo Install and start Docker Desktop.
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

if not exist "%SCRIPT_DIR%smoke-test.js" (
    echo.
    echo [ERROR] smoke-test.js was not found.
    echo Expected file:
    echo   %SCRIPT_DIR%smoke-test.js
    echo.
    exit /b 1
)

echo.
echo ============================================================
echo k6 Smoke Test
echo ============================================================
echo Target: %TARGET_URL%
echo.

docker run --rm ^
  -e TARGET_URL="%TARGET_URL%" ^
  -v "%SCRIPT_DIR%:/scripts:ro" ^
  grafana/k6:latest run /scripts/smoke-test.js

set "RESULT=%ERRORLEVEL%"

echo.
if "%RESULT%"=="0" (
    echo [OK] Smoke test completed successfully.
) else (
    echo [ERROR] Smoke test failed. Exit code: %RESULT%
)

endlocal
exit /b %RESULT%
```
