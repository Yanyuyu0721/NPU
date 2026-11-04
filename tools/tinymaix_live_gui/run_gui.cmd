@echo off
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8
set PYTHONDONTWRITEBYTECODE=1
if defined TINYMAIX_PYTHON goto configured
if exist "%~dp0..\..\.venv\Scripts\python.exe" (
 set "TINYMAIX_PYTHON=%~dp0..\..\.venv\Scripts\python.exe"
) else if exist "%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe" (
 set "TINYMAIX_PYTHON=%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
) else (
 set "TINYMAIX_PYTHON=python"
)
:configured
for /f "delims=" %%I in ('where "%TINYMAIX_PYTHON%" 2^>nul') do if exist "%%~dpIpythonw.exe" (
 start "" "%%~dpIpythonw.exe" -B "%~dp0desktop.py" %*
 exit /b 0
)
"%TINYMAIX_PYTHON%" -B "%~dp0desktop.py" %*
if errorlevel 1 pause
