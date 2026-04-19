@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
chcp 65001 >nul 2>&1
title Neve AI - Instalador
color 0B

:: ============================================================
::  NEVE AI — INSTALADOR DE DEPENDENCIAS
::  Instala venv, pip requirements, npm packages e build frontend.
::
::  PRE-REQUISITOS (ja devem estar instalados):
::    - Python 3.11 ou 3.12
::    - Node.js 18+
::    - Git
::
::  COMO USAR:
::    1. Clique duas vezes neste arquivo (ou execute como Admin)
::    2. Aguarde a instalacao completa
::    3. Execute start_neve.bat para iniciar
:: ============================================================

echo.
echo  ============================================
echo     NEVE AI - INSTALADOR DE DEPENDENCIAS
echo  ============================================
echo.

SET "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%" || exit /b 1

:: Cria pasta de logs
if not exist "%PROJECT_DIR%logs" mkdir "%PROJECT_DIR%logs"
SET "LOG=%PROJECT_DIR%logs\install_%date:~6,4%%date:~3,2%%date:~0,2%.log"

echo  [INFO] Diretorio do projeto: %PROJECT_DIR%
echo  [INFO] Log: %LOG%
echo.

:: ============================================================
:: 1. VERIFICAR PRE-REQUISITOS
:: ============================================================
echo  [1/5] Verificando pre-requisitos...

SET "MISSING=0"

where python >nul 2>&1
if %errorLevel% neq 0 (
    echo  [ERRO] Python nao encontrado. Instale Python 3.11 ou 3.12.
    SET "MISSING=1"
) else (
    for /f "tokens=2 delims= " %%v in ('python --version 2^>^&1') do echo  [OK] Python %%v
)

where node >nul 2>&1
if %errorLevel% neq 0 (
    echo  [ERRO] Node.js nao encontrado. Instale Node.js 18+.
    SET "MISSING=1"
) else (
    for /f "tokens=1" %%v in ('node --version') do echo  [OK] Node.js %%v
)

where git >nul 2>&1
if %errorLevel% neq 0 (
    echo  [ERRO] Git nao encontrado. Instale Git.
    SET "MISSING=1"
) else (
    for /f "tokens=3" %%v in ('git --version') do echo  [OK] Git %%v
)

if "!MISSING!"=="1" (
    echo.
    echo  [ERRO] Instale os programas acima antes de continuar.
    pause
    exit /b 1
)
echo.

:: ============================================================
:: 2. CRIAR VENV PYTHON + INSTALAR DEPENDENCIAS BACKEND
:: ============================================================
echo  [2/5] Configurando ambiente Python (venv)...

SET "VENV_DIR=%PROJECT_DIR%backend\open_webui\venv"
SET "PIP=%VENV_DIR%\Scripts\pip.exe"
SET "PYTHON_VENV=%VENV_DIR%\Scripts\python.exe"

if not exist "%VENV_DIR%\Scripts\python.exe" (
    echo  [CRIANDO] Virtual environment...
    python -m venv "%VENV_DIR%" >> "%LOG%" 2>&1
    if !errorLevel! neq 0 (
        echo  [ERRO] Falha ao criar venv.
        pause
        exit /b 1
    )
    echo  [OK] venv criado.
) else (
    echo  [OK] venv ja existe.
)

echo  [INSTALANDO] Dependencias Python (isso pode demorar 5-15 min)...
"%PIP%" install --upgrade pip >> "%LOG%" 2>&1
"%PIP%" install -r "%PROJECT_DIR%backend\requirements.txt" >> "%LOG%" 2>&1
if !errorLevel! neq 0 (
    echo  [AVISO] Algumas dependencias podem ter falhado (algumas sao opcionais).
    echo          Verifique o log: %LOG%
) else (
    echo  [OK] Dependencias Python instaladas.
)
echo.

:: ============================================================
:: 3. INSTALAR DEPENDENCIAS FRONTEND (npm)
:: ============================================================
echo  [3/5] Instalando dependencias frontend (npm)...

cd /d "%PROJECT_DIR%"

:: Garante que npm está no PATH
where npm >nul 2>&1
if %errorLevel% neq 0 (
    SET "PATH=%PATH%;C:\Program Files\nodejs"
)

call npm install >> "%LOG%" 2>&1
if !errorLevel! neq 0 (
    echo  [ERRO] Falha no npm install. Verifique o log.
    pause
    exit /b 1
)
echo  [OK] Dependencias frontend instaladas.
echo.

:: ============================================================
:: 4. BUILD DO FRONTEND
:: ============================================================
echo  [4/5] Compilando frontend (isso pode demorar 2-5 min)...

call npm run build >> "%LOG%" 2>&1
if !errorLevel! neq 0 (
    echo  [ERRO] Falha no build do frontend. Verifique o log.
    pause
    exit /b 1
)

:: Copia build para o backend (static serve)
if exist "%PROJECT_DIR%build" (
    echo  [COPIANDO] Build para backend\open_webui\static...
    if exist "%PROJECT_DIR%backend\open_webui\static" (
        rmdir /s /q "%PROJECT_DIR%backend\open_webui\static" >nul 2>&1
    )
    xcopy "%PROJECT_DIR%build" "%PROJECT_DIR%backend\open_webui\static\" /E /I /Q /Y >> "%LOG%" 2>&1
    echo  [OK] Frontend compilado e copiado.
) else (
    echo  [AVISO] Pasta build nao encontrada. O frontend pode nao ter compilado corretamente.
)
echo.

:: ============================================================
:: 5. VERIFICAR SCRIPT DE INICIALIZACAO
:: ============================================================
echo  [5/5] Verificando script de inicializacao...

if exist "%PROJECT_DIR%start_neve.bat" (
    echo  [OK] start_neve.bat encontrado.
) else (
    echo  [AVISO] start_neve.bat nao encontrado na raiz do projeto.
    echo          Crie manualmente ou copie de um backup.
)
echo.

:: ============================================================
:: RESUMO FINAL
:: ============================================================
echo.
echo  ============================================
echo     INSTALACAO CONCLUIDA!
echo  ============================================
echo.
echo  Para iniciar o Neve AI:
echo    1. Execute "start_neve.bat"
echo    2. Acesse http://localhost:8080
echo.
echo  Log completo: %LOG%
echo.
echo  Versoes instaladas:
echo  ---

:: Mostra versoes
python --version 2>&1
node --version 2>&1
git --version 2>&1
"%PIP%" --version 2>&1

echo.
echo  ============================================
echo.
pause
