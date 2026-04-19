@echo off
cd /d "d:\Neve AI"
set NODE_OPTIONS=--max-old-space-size=4096
echo Build iniciando com limite de 4GB de RAM...
call node node_modules\vite\bin\vite.js build
echo.
echo Exit code: %ERRORLEVEL%
pause
