@echo off
tools\bas2tap-win\bas2tap.exe -q -w -sIntruders -a10 basic-code\Intruders.txt basic-code\Intruders.tap
if errorlevel 1 (
    echo Build failed.
    pause
    exit /b 1
)
tools\fuse\fuse.exe basic-code\Intruders.tap
