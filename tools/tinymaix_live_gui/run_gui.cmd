@echo off
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8
set PYTHONDONTWRITEBYTECODE=1
if defined TINYMAIX_PYTHON goto configured
if exist "C:\Users\65274\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe" (
 set "TINYMAIX_PYTHON=C:\Users\65274\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
) else (
 set "TINYMAIX_PYTHON=python"
)
:configured
for %%I in ("%TINYMAIX_PYTHON%") do if exist "%%~dpIpythonw.exe" (
 start "" "%%~dpIpythonw.exe" -B "%~dp0desktop.py" %*
 exit /b 0
)
"%TINYMAIX_PYTHON%" -B "%~dp0desktop.py" %*
if errorlevel 1 pause
