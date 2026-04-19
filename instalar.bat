@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
chcp 65001 >nul 2>&1
title Neve AI - Instalador
color 0B

:: ============================================================
::  NEVE AI — INSTALADOR COMPLETO
::  Recria o ambiente do zero: venv Python, PyTorch CUDA,
::  dependencias backend, build do frontend.
::
::  PRE-REQUISITOS (devem estar instalados antes):
::    - Python 3.11 ou 3.12  ->  python.org/downloads
::    - Node.js 18+           ->  nodejs.org
::
::  GPU NVIDIA (para geracao de imagens):
::    - Nenhum driver CUDA adicional e necessario.
::    - PyTorch ja inclui suas proprias DLLs CUDA 12.8.
::    - Sem GPU, a geracao de imagens sera muito lenta.
::
::  COMO USAR:
::    1. Execute este arquivo (duplo clique ou terminal admin)
::    2. Aguarde ~10-20 min (depende da internet)
::    3. Execute iniciar.bat para iniciar
:: ============================================================

echo.
echo  ============================================
echo     NEVE AI - INSTALADOR COMPLETO
echo  ============================================
echo.

SET "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%" || (echo  [ERRO] Nao foi possivel entrar em %PROJECT_DIR% & pause & exit /b 1)

:: Pasta de logs
if not exist "%PROJECT_DIR%logs" mkdir "%PROJECT_DIR%logs"
SET "LOG=%PROJECT_DIR%logs\install.log"
echo. > "%LOG%"

echo  [INFO] Diretorio do projeto: %PROJECT_DIR%
echo  [INFO] Log completo em: %LOG%
echo.

:: ============================================================
:: 1. VERIFICAR PRE-REQUISITOS
:: ============================================================
echo  [1/6] Verificando pre-requisitos...

SET "MISSING=0"

where python >nul 2>&1
if %errorLevel% neq 0 (
    echo  [ERRO] Python nao encontrado. Instale Python 3.11 ou 3.12 em python.org
    SET "MISSING=1"
) else (
    for /f "tokens=2 delims= " %%v in ('python --version 2^>^&1') do (
        echo  [OK] Python %%v
    )
)

where node >nul 2>&1
if %errorLevel% neq 0 (
    echo  [ERRO] Node.js nao encontrado. Instale Node.js 18+ em nodejs.org
    SET "MISSING=1"
) else (
    for /f "tokens=1" %%v in ('node --version') do echo  [OK] Node.js %%v
)

if "!MISSING!"=="1" (
    echo.
    echo  [ERRO] Instale os programas acima e execute o instalador novamente.
    pause
    exit /b 1
)
echo.

:: ============================================================
:: 2. DETECTAR GPU NVIDIA
:: ============================================================
echo  [2/6] Verificando GPU NVIDIA...

SET "USE_CUDA=N"
nvidia-smi >nul 2>&1
if %errorLevel% equ 0 (
    for /f "tokens=*" %%g in ('nvidia-smi --query-gpu=name --format=csv,noheader 2^>nul') do (
        echo  [OK] GPU detectada: %%g
        SET "USE_CUDA=Y"
    )
) else (
    echo  [INFO] GPU NVIDIA nao detectada.
)

if "!USE_CUDA!"=="Y" (
    echo  [INFO] PyTorch sera instalado com CUDA 12.8 ^(necessario para Stable Diffusion^).
) else (
    echo  [AVISO] PyTorch sera instalado sem CUDA. Geracao de imagens sera muito lenta.
    echo.
    SET /p CONFIRM_CPU=  Deseja continuar sem GPU NVIDIA? (S/N): 
    if /i "!CONFIRM_CPU!" neq "S" (
        echo  Instalacao cancelada.
        pause
        exit /b 0
    )
)
echo.

:: ============================================================
:: 3. CRIAR VENV LIMPO (SEMPRE RECRIA DO ZERO)
:: ============================================================
echo  [3/6] Recriando ambiente Python (venv)...

SET "VENV_DIR=%PROJECT_DIR%backend\open_webui\venv"
SET "PYTHON_VENV=%VENV_DIR%\Scripts\python.exe"

if exist "%VENV_DIR%" (
    echo  [APAGANDO] venv existente em %VENV_DIR%...
    rmdir /s /q "%VENV_DIR%" >nul 2>&1
    if exist "%VENV_DIR%" (
        echo  [ERRO] Nao foi possivel remover o venv.
        echo         Feche todos os processos Python e execute novamente.
        pause
        exit /b 1
    )
    echo  [OK] venv antigo removido.
)

echo  [CRIANDO] Novo venv com Python do sistema...
python -m venv "%VENV_DIR%" >> "%LOG%" 2>&1
if !errorLevel! neq 0 (
    echo  [ERRO] Falha ao criar venv. Verifique o log: %LOG%
    pause
    exit /b 1
)
echo  [OK] venv criado em %VENV_DIR%.
echo.

:: ============================================================
:: 4. INSTALAR DEPENDENCIAS PYTHON
:: ============================================================
echo  [4/6] Instalando dependencias Python...

echo  [pip] Atualizando pip...
"%PYTHON_VENV%" -m pip install --upgrade pip >> "%LOG%" 2>&1

:: --- PyTorch (com ou sem CUDA) ---
if "!USE_CUDA!"=="Y" (
    echo  [pip] Instalando PyTorch 2.11.0 + CUDA 12.8 ^(~2.5GB, pode demorar^)...
    "%PYTHON_VENV%" -m pip install ^
        torch==2.11.0+cu128 ^
        torchvision==0.26.0+cu128 ^
        --index-url https://download.pytorch.org/whl/cu128 ^
        >> "%LOG%" 2>&1
) else (
    echo  [pip] Instalando PyTorch CPU...
    "%PYTHON_VENV%" -m pip install ^
        torch torchvision ^
        --index-url https://download.pytorch.org/whl/cpu ^
        >> "%LOG%" 2>&1
)
if !errorLevel! neq 0 (
    echo  [ERRO] Falha ao instalar PyTorch. Verifique: %LOG%
    pause
    exit /b 1
)
echo  [OK] PyTorch instalado.

:: --- Diffusers (Stable Diffusion SDXL Turbo) ---
echo  [pip] Instalando diffusers 0.37.1 ^(Stable Diffusion^)...
"%PYTHON_VENV%" -m pip install diffusers==0.37.1 >> "%LOG%" 2>&1
if !errorLevel! neq 0 (
    echo  [AVISO] Falha ao instalar diffusers. Geracao de imagens indisponivel.
) else (
    echo  [OK] diffusers instalado.
)

:: --- Demais dependencias do backend ---
echo  [pip] Instalando todas as dependencias backend ^(5-15 min^)...
"%PYTHON_VENV%" -m pip install -r "%PROJECT_DIR%backend\requirements.txt" >> "%LOG%" 2>&1
if !errorLevel! neq 0 (
    echo  [AVISO] Algumas dependencias opcionais podem ter falhado.
    echo         Verifique o log: %LOG%
) else (
    echo  [OK] Dependencias backend instaladas.
)
echo.

:: ============================================================
:: 5. DEPENDENCIAS FRONTEND + BUILD
:: ============================================================
echo  [5/6] Instalando dependencias frontend e compilando...

cd /d "%PROJECT_DIR%"

:: Garante que npm esta no PATH
where npm >nul 2>&1
if %errorLevel% neq 0 (
    SET "PATH=%PATH%;C:\Program Files\nodejs"
)

echo  [npm] npm install...
call npm install >> "%LOG%" 2>&1
if !errorLevel! neq 0 (
    echo  [ERRO] Falha no npm install. Verifique o log: %LOG%
    pause
    exit /b 1
)
echo  [OK] Pacotes npm instalados.

echo  [npm] npm run build ^(2-5 min^)...
call npm run build >> "%LOG%" 2>&1
if !errorLevel! neq 0 (
    echo  [ERRO] Falha no build do frontend. Verifique o log: %LOG%
    pause
    exit /b 1
)
echo  [OK] Frontend compilado em build\.

echo  [npm] Copiando frontend para backend\open_webui\static...
if exist "%PROJECT_DIR%backend\open_webui\static" (
    rmdir /s /q "%PROJECT_DIR%backend\open_webui\static" >nul 2>&1
)
xcopy /E /Y /Q "%PROJECT_DIR%build\*" "%PROJECT_DIR%backend\open_webui\static\" >> "%LOG%" 2>&1
echo  [OK] Frontend implantado no backend.
echo.

:: ============================================================
:: 6. ESTRUTURA DE PASTAS + .ENV PADRÃO
:: ============================================================
echo  [6/6] Preparando estrutura e configuracoes...

for %%d in (
    "logs"
    "logs\webview2"
    "logs\browser-app"
    "models"
    "mmproj"
    "backend\data"
    "backend\data\uploads"
    "backend\data\vector_db"
    "backend\data\cache"
    "backend\data\tools"
) do (
    if not exist "%PROJECT_DIR%%%~d" (
        mkdir "%PROJECT_DIR%%%~d" >nul 2>&1
        echo  [CRIADO] %%~d
    )
)

:: Cria .env apenas se nao existir ainda
if not exist "%PROJECT_DIR%.env" (
    echo  [CRIANDO] .env com configuracoes padrao...
    (
        echo # Frontend
        echo VITE_RELATIVE_CONFIG=True
        echo VITE_OPENWEBUI_BACKEND_URL=http://localhost:8080
        echo.
        echo # Backend
        echo ENV=dev
        echo PORT=8080
        echo WEBUI_SECRET_KEY=troque-esta-chave-por-algo-seguro
        echo WEBUI_AUTH=False
        echo WEBUI_NAME=Neve AI
        echo ENABLE_OLLAMA_API=False
        echo ENABLE_OPENAI_API=False
        echo ENABLE_WEB_SEARCH=False
        echo ENABLE_IMAGE_GENERATION=False
        echo ENABLE_WEBSOCKET_SUPPORT=True
        echo ENABLE_COMMUNITY_SHARING=False
        echo ENABLE_MESSAGE_RATING=False
        echo BYPASS_MODEL_ACCESS_CONTROL=True
        echo ENABLE_SIGNUP=True
        echo ENABLE_LOGIN_FORM=True
        echo SAFE_MODE=False
        echo CORS_ALLOW_ORIGIN=http://localhost:8080
        echo USER_AGENT=Neve AI
    ) > "%PROJECT_DIR%.env"
    echo  [OK] .env criado.
) else (
    echo  [OK] .env ja existe — nao foi sobrescrito.
)

:: ============================================================
:: RESUMO FINAL
:: ============================================================
echo.
echo  ============================================
echo     INSTALACAO CONCLUIDA COM SUCESSO!
echo  ============================================
echo.

:: Exibe versoes instaladas
echo  Versoes instaladas:
echo  --------------------------------------------------
python --version 2>&1
node --version 2>&1
"%PYTHON_VENV%" -c "import torch; v=torch.__version__; print('PyTorch ' + v + (' (CUDA ' + torch.version.cuda + ')' if torch.cuda.is_available() else ' (CPU)'))" 2>nul
"%PYTHON_VENV%" -c "import diffusers; print('diffusers ' + diffusers.__version__)" 2>nul
echo  --------------------------------------------------
echo.
echo  Para iniciar o Neve AI, execute:
echo.
echo    iniciar.bat
echo.
echo  Log completo: %LOG%
echo.
echo  ============================================
echo   O que REMOVER antes de distribuir:
echo  ============================================
echo.
echo   .venv\                  ~800 MB  (venv nao utilizado - pode apagar)
echo   backend\open_webui\venv\ ~6 GB   (recriado pelo instalar.bat)
echo   node_modules\            ~950 MB  (recriado pelo npm install)
echo   build\                   ~160 MB  (recriado pelo npm run build)
echo   .svelte-kit\             ~190 MB  (cache do compilador)
echo   models\                  (modelos GGUF - usuario baixa os seus)
echo   mmproj\                  (modelos mmproj - usuario baixa os seus)
echo   logs\                    (logs de execucao - gerados ao iniciar)
echo   backend\data\            (banco de dados e uploads do usuario)
echo.
echo   Mantenha: src\ backend\ static\ iniciar.bat instalar.bat
echo             neve_window.py llamacpp-server\ .env package.json
echo.
ENDLOCAL
pause
