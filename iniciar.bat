@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
chcp 65001 >nul
title Neve AI

echo.
echo  ==========================================
echo    Neve AI - Iniciando...
echo  ==========================================
echo.

SET "ROOT=%~dp0"
SET "VENV_PY=%ROOT%backend\neveai\venv\Scripts\python.exe"
SET "VENV_PYW=%ROOT%backend\neveai\venv\Scripts\pythonw.exe"
SET "BACKEND=%ROOT%backend"

:: Verifica se o venv existe
if not exist "%VENV_PY%" (
    echo  [ERRO] Ambiente Python nao encontrado.
    echo         Execute instalar.bat primeiro.
    pause
    exit /b 1
)

:: Encerra processos anteriores na porta 8080
echo  Encerrando processos anteriores...
powershell -NoProfile -Command "(Get-NetTCPConnection -LocalPort 8080 -EA SilentlyContinue).OwningProcess | Where-Object { $_ -and $_ -ne 0 } | Sort-Object -Unique | ForEach-Object { Stop-Process -Id $_ -Force -EA SilentlyContinue }"

:: Inicia o backend (serve o frontend de producao na mesma porta)
echo  Iniciando backend (porta 8080)...
start "Neve AI - Backend" powershell -NoProfile -ExecutionPolicy Bypass -Command "$env:PYTHONIOENCODING='utf-8'; $env:PYTHONPATH='%BACKEND%'; Set-Location '%BACKEND%'; & '%VENV_PY%' -m uvicorn neveai.main:app --host 0.0.0.0 --port 8080"

:: Aguarda o backend responder (testa a cada 1s, ate 120s)
echo  Aguardando backend carregar...
set TRIES=0
:WAIT_BACKEND
timeout /t 1 /nobreak >nul
powershell -NoProfile -Command "try{Invoke-WebRequest -Uri 'http://127.0.0.1:8080/health' -UseBasicParsing -TimeoutSec 1|Out-Null;exit 0}catch{exit 1}" >nul 2>&1
if %errorlevel% == 0 goto BACKEND_OK
set /a TRIES=TRIES+1
if !TRIES! == 10 echo  Pode levar 20-60 segundos na primeira vez...
if !TRIES! lss 120 goto WAIT_BACKEND
echo  AVISO: Backend nao respondeu em 120s. Continuando mesmo assim.

:BACKEND_OK
echo  Backend pronto!
echo.
echo  ==========================================
echo    Neve AI esta rodando!
echo    Acesse: http://localhost:8080
echo  ==========================================
echo.
start "" "%VENV_PYW%" "%ROOT%neve_window.py"
ENDLOCAL
exit
