@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
chcp 65001 >nul
title Neve AI

echo.
echo  ==========================================
echo    Neve AI - Iniciando...
echo  ==========================================
echo.

REM Encerra processos anteriores na porta 8080
echo  Encerrando processos anteriores...
powershell -NoProfile -Command "(Get-NetTCPConnection -LocalPort 8080 -EA SilentlyContinue).OwningProcess | Where-Object { $_ -and $_ -ne 0 } | Sort-Object -Unique | ForEach-Object { Stop-Process -Id $_ -Force -EA SilentlyContinue }"
timeout /t 2 /nobreak >nul

REM Inicia o backend (serve o frontend de producao na mesma porta)
echo  Iniciando backend (porta 8080)...
start "Neve AI - Backend" powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-backend.ps1"

REM Aguarda o backend responder (testa a cada 3s, ate 120s)
echo  Aguardando backend carregar (pode demorar 20-60s)...
set TRIES=0
:WAIT_BACKEND
timeout /t 3 /nobreak >nul
powershell -NoProfile -Command "try { Invoke-WebRequest -Uri 'http://127.0.0.1:8080/health' -UseBasicParsing -TimeoutSec 2 | Out-Null; exit 0 } catch { exit 1 }" >nul 2>&1
if %errorlevel% == 0 goto BACKEND_OK
set /a TRIES=TRIES+1
if !TRIES! lss 40 (
    echo  Aguardando... ^(!TRIES!/40^)
    goto WAIT_BACKEND
)
echo  AVISO: Backend nao respondeu em 120s. Continuando mesmo assim.

:BACKEND_OK
echo  Backend pronto!
echo.
echo  ==========================================
echo    Neve AI esta rodando!
echo    Acesse: http://localhost:8080
echo  ==========================================
echo.
start "" http://localhost:8080
ENDLOCAL
exit
