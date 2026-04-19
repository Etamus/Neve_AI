# Neve AI - Instalador Completo v2
# Detecta hardware, faz perguntas relevantes e instala as dependencias
# otimizadas para o sistema de cada usuario.
#
# PRE-REQUISITOS:
#   Python 3.11/3.12  https://python.org/downloads
#   Node.js 18+       https://nodejs.org

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding
$Host.UI.RawUI.WindowTitle = 'Neve AI - Instalador'

$ROOT     = Split-Path $MyInvocation.MyCommand.Path -Parent
$VENV_DIR = "$ROOT\backend\neveai\venv"
$VENV_PY  = "$VENV_DIR\Scripts\python.exe"
$BACKEND  = "$ROOT\backend"

if (-not (Test-Path "$ROOT\logs")) { New-Item "$ROOT\logs" -ItemType Directory | Out-Null }
$LOG = "$ROOT\logs\install.log"
'' | Set-Content $LOG

function Write-Step ($num, $text) { Write-Host "  [$num] $text" -ForegroundColor Cyan }
function Write-Ok   ($text) { Write-Host "  [OK] $text" -ForegroundColor Green }
function Write-Info ($text) { Write-Host "  [INFO] $text" -ForegroundColor Gray }
function Write-Warn ($text) { Write-Host "  [AVISO] $text" -ForegroundColor Yellow }
function Write-Err  ($text) { Write-Host "  [ERRO] $text" -ForegroundColor Red }

Write-Host ''
Write-Host '  ================================================' -ForegroundColor Cyan
Write-Host '     NEVE AI - INSTALADOR COMPLETO v2' -ForegroundColor White
Write-Host '  ================================================' -ForegroundColor Cyan
Write-Host ''

# =============================================================================
# 1. PRE-REQUISITOS
# =============================================================================
Write-Step '1/7' 'Verificando pre-requisitos...'

$missing = $false

try {
    $pyVer = (python --version 2>&1).ToString().Trim()
    Write-Ok "Python: $pyVer"
} catch {
    Write-Err 'Python nao encontrado. Instale Python 3.11 ou 3.12 em https://python.org/downloads'
    $missing = $true
}

try {
    $nodeVer = (node --version 2>&1).ToString().Trim()
    Write-Ok "Node.js: $nodeVer"
} catch {
    Write-Err 'Node.js nao encontrado. Instale Node.js 18+ em https://nodejs.org'
    $missing = $true
}

if ($missing) {
    Write-Host ''
    Write-Err 'Instale os programas acima e execute o instalador novamente.'
    $null = Read-Host 'Pressione Enter para fechar'
    exit 1
}
Write-Host ''

# =============================================================================
# 2. DETECCAO DE HARDWARE
# =============================================================================
Write-Step '2/7' 'Detectando hardware...'

$gpuVendor    = 'CPU'
$gpuName      = ''
$cudaVer      = 'nenhum'
$torchIndex   = 'https://download.pytorch.org/whl/cpu'
$llamaAsset   = 'cpu'       # sufixo do asset: cpu, cuda-12.4, cuda-13.1, vulkan, hip-radeon
$useFlashAttn = $false
$useOnnxGpu   = $false
$vramGb       = 0

# Detecta NVIDIA via nvidia-smi
try {
    $nOut = nvidia-smi --query-gpu=name --format=csv,noheader 2>&1
    if ($LASTEXITCODE -eq 0 -and "$nOut" -notmatch 'failed|not found') {
        $gpuVendor = 'NVIDIA'
        $gpuName   = ("$nOut" -split "`n")[0].Trim()
        Write-Ok "GPU NVIDIA detectada: $gpuName"
    }
} catch {}

# Detecta AMD via WMI (se nao encontrou NVIDIA)
if ($gpuVendor -eq 'CPU') {
    try {
        $gpus = Get-CimInstance Win32_VideoController |
                Select-Object -ExpandProperty Name -EA SilentlyContinue
        $amdGpu = $gpus | Where-Object { $_ -match 'AMD|Radeon|RX\s' } | Select-Object -First 1
        if ($amdGpu) {
            $gpuVendor = 'AMD'
            $gpuName   = $amdGpu.Trim()
            Write-Ok "GPU AMD detectada: $gpuName"
        }
    } catch {}
}

if ($gpuVendor -eq 'CPU') {
    Write-Info 'Nenhuma GPU NVIDIA ou AMD detectada (modo CPU).'
}
Write-Host ''

# =============================================================================
# 3. PERGUNTAS DE HARDWARE
# =============================================================================
Write-Step '3/7' 'Configurando para seu hardware...'
Write-Host ''

if ($gpuVendor -eq 'NVIDIA') {

    # Auto-detectar serie baseado no nome da GPU
    $autoSeries = $null
    if     ($gpuName -match 'RTX\s*5\d{3}|5[06789]\d{2} Ti| 50\d{2}')    { $autoSeries = '1' }
    elseif ($gpuName -match 'RTX\s*4\d{3}|4[0-9]\d{2} Ti| 40\d{2}')      { $autoSeries = '2' }
    elseif ($gpuName -match 'RTX\s*3\d{3}|3[0-9]\d{2} Ti| 30\d{2}')      { $autoSeries = '3' }
    elseif ($gpuName -match 'RTX\s*2\d{3}|2[0-9]\d{2} Ti| 20\d{2}')      { $autoSeries = '4' }
    elseif ($gpuName -match 'GTX\s*16\d{2}|1[6-9]\d{2} (Ti|Super|SUPER)') { $autoSeries = '5' }
    elseif ($gpuName -match 'GTX\s*10\d{2}|GTX\s*9\d{2}|GTX\s*7\d{2}')   { $autoSeries = '6' }

    Write-Host '  +---------------------------------------------------------+' -ForegroundColor DarkCyan
    Write-Host "  |  GPU: $gpuName" -ForegroundColor White
    Write-Host '  |' -ForegroundColor DarkCyan
    Write-Host '  |  Qual e a SERIE da sua GPU NVIDIA?' -ForegroundColor White
    Write-Host '  |' -ForegroundColor DarkCyan
    Write-Host '  |   [1] RTX 50xx  - Blackwell    (5060, 5070, 5080, 5090)' -ForegroundColor White
    Write-Host '  |   [2] RTX 40xx  - Ada Lovelace (4060, 4070, 4080, 4090)' -ForegroundColor White
    Write-Host '  |   [3] RTX 30xx  - Ampere       (3060, 3070, 3080, 3090)' -ForegroundColor White
    Write-Host '  |   [4] RTX 20xx  - Turing       (2060, 2070, 2080)' -ForegroundColor White
    Write-Host '  |   [5] GTX 16xx  - Turing       (1650, 1660, 1660 Ti)' -ForegroundColor White
    Write-Host '  |   [6] GTX 10xx  - Pascal ou mais antigo' -ForegroundColor DarkGray
    Write-Host '  |   [7] Profissional (RTX A-series, Quadro, Tesla)' -ForegroundColor DarkGray
    Write-Host '  +---------------------------------------------------------+' -ForegroundColor DarkCyan

    if ($autoSeries) {
        Write-Host "  [AUTO] Serie detectada automaticamente: opcao $autoSeries" -ForegroundColor DarkYellow
        Write-Host '  (Pressione Enter para confirmar ou digite outro numero)' -ForegroundColor DarkGray
    }

    $seriesChoice = (Read-Host '  Serie').Trim()
    if ([string]::IsNullOrWhiteSpace($seriesChoice) -and $autoSeries) {
        $seriesChoice = $autoSeries
    }

    switch ($seriesChoice) {
        '1' {
            $cudaVer      = 'CUDA 13.1 (Blackwell)'
            $torchIndex   = 'https://download.pytorch.org/whl/cu128'
            $llamaAsset   = 'cuda-13.1'
            $useFlashAttn = $true
            $useOnnxGpu   = $true
            Write-Ok 'RTX 50xx (Blackwell, SM 12.0) -> CUDA 13.1, PyTorch cu128, Flash Attention 3'
        }
        '2' {
            $cudaVer      = 'CUDA 12.8 (Ada Lovelace)'
            $torchIndex   = 'https://download.pytorch.org/whl/cu128'
            $llamaAsset   = 'cuda-12.4'
            $useFlashAttn = $true
            $useOnnxGpu   = $true
            Write-Ok 'RTX 40xx (Ada, SM 8.9) -> CUDA 12.8, PyTorch cu128, Flash Attention 2/3'
        }
        '3' {
            $cudaVer      = 'CUDA 12.8 (Ampere)'
            $torchIndex   = 'https://download.pytorch.org/whl/cu128'
            $llamaAsset   = 'cuda-12.4'
            $useFlashAttn = $true
            $useOnnxGpu   = $true
            Write-Ok 'RTX 30xx (Ampere, SM 8.6) -> CUDA 12.8, PyTorch cu128, Flash Attention 2'
        }
        '4' {
            $cudaVer    = 'CUDA 12.6 (Turing)'
            $torchIndex = 'https://download.pytorch.org/whl/cu126'
            $llamaAsset = 'cuda-12.4'
            $useOnnxGpu = $true
            Write-Ok 'RTX 20xx (Turing, SM 7.5) -> CUDA 12.6, PyTorch cu126 (Flash Attention nao recomendado)'
        }
        '5' {
            $cudaVer    = 'CUDA 12.4 (Turing)'
            $torchIndex = 'https://download.pytorch.org/whl/cu124'
            $llamaAsset = 'cuda-12.4'
            $useOnnxGpu = $true
            Write-Ok 'GTX 16xx (Turing, SM 7.5) -> CUDA 12.4, PyTorch cu124'
        }
        '6' {
            $cudaVer    = 'CUDA 12.4 (Pascal)'
            $torchIndex = 'https://download.pytorch.org/whl/cu124'
            $llamaAsset = 'cuda-12.4'
            Write-Ok 'GTX 10xx (Pascal, SM 6.x) -> CUDA 12.4 (sem Flash Attention)'
        }
        '7' {
            $cudaVer      = 'CUDA 12.8 (Profissional)'
            $torchIndex   = 'https://download.pytorch.org/whl/cu128'
            $llamaAsset   = 'cuda-12.4'
            $useFlashAttn = $true
            $useOnnxGpu   = $true
            Write-Ok 'GPU Profissional -> CUDA 12.8'
        }
        default {
            Write-Warn "Selecao invalida ('$seriesChoice'), usando configuracao CPU."
            $gpuVendor = 'CPU'
        }
    }

    if ($gpuVendor -eq 'NVIDIA') {
        # VRAM
        Write-Host ''
        $vramInput = Read-Host '  Quantos GB de VRAM tem sua GPU? (ex: 8, 12, 16, 24  --  Enter para pular)'
        if ($vramInput -match '^\d+$') {
            $vramGb = [int]$vramInput
            Write-Info "VRAM: ${vramGb}GB"
        }

        # Flash Attention (opt-in, so para Ampere+)
        if ($useFlashAttn) {
            Write-Host ''
            Write-Host '  +------------------------------------------------------------------+' -ForegroundColor DarkCyan
            Write-Host '  |  Flash Attention acelera modelos de embedding/RAG/imagens.       |' -ForegroundColor White
            Write-Host '  |  Requer ~10 min extras de compilacao + MSVC Build Tools.         |' -ForegroundColor DarkGray
            Write-Host '  |  Se voce nao usa RAG / stable diffusion, pode pular.             |' -ForegroundColor DarkGray
            Write-Host '  +------------------------------------------------------------------+' -ForegroundColor DarkCyan
            $faChoice = (Read-Host '  Instalar Flash Attention? (s/N)').Trim()
            if ($faChoice -notmatch '^[sS]$') { $useFlashAttn = $false }
        }
    }

} elseif ($gpuVendor -eq 'AMD') {

    Write-Host '  GPU AMD detectada. Escolha o backend para llama.cpp:' -ForegroundColor White
    Write-Host '   [1] HIP/ROCm  - Melhor desempenho, suporte limitado no Windows' -ForegroundColor White
    Write-Host '   [2] Vulkan    - Compativel com a maioria das GPUs AMD no Windows' -ForegroundColor White
    Write-Host '   [3] CPU apenas' -ForegroundColor DarkGray
    Write-Host ''
    $amdChoice = (Read-Host '  Escolha (1/2/3)').Trim()
    switch ($amdChoice) {
        '1' {
            $llamaAsset = 'hip-radeon'
            $torchIndex = 'https://download.pytorch.org/whl/rocm6.3'
            Write-Ok 'AMD HIP/ROCm selecionado. PyTorch cu ROCm 6.3.'
        }
        '2' {
            $llamaAsset = 'vulkan'
            Write-Ok 'AMD Vulkan selecionado. PyTorch CPU (Vulkan apenas para llama.cpp).'
        }
        default {
            Write-Ok 'CPU apenas selecionado.'
        }
    }

} else {

    $confirm = (Read-Host '  Sem GPU detectada. Continuar com CPU apenas? (s/N)').Trim()
    if ($confirm -notmatch '^[sS]$') {
        Write-Host '  Instalacao cancelada.'
        exit 0
    }
}

Write-Host ''

# =============================================================================
# 4. BAIXAR LLAMA.CPP MAIS RECENTE (GitHub API)
# =============================================================================
Write-Step '4/7' 'Baixando llama.cpp mais recente do GitHub...'
Write-Host ''

$llamaDir = "$ROOT\llamacpp-server\bin"
foreach ($d in @("$ROOT\llamacpp-server", $llamaDir)) {
    if (-not (Test-Path $d)) { New-Item $d -ItemType Directory | Out-Null }
}

try {
    Write-Info 'Consultando GitHub API...'
    $rel = Invoke-RestMethod 'https://api.github.com/repos/ggml-org/llama.cpp/releases/latest' `
                             -Headers @{ 'User-Agent' = 'Neve-Installer/2.0' }
    $tag = $rel.tag_name
    Write-Info "Versao mais recente: $tag"

    # Asset principal (binarios do llama-server, llama-cli, etc.)
    $binName = "llama-$tag-bin-win-$llamaAsset-x64.zip"
    $binObj  = $rel.assets | Where-Object { $_.name -eq $binName } | Select-Object -First 1

    if (-not $binObj) {
        Write-Warn "Asset '$binName' nao encontrado. Usando CPU como fallback..."
        $binName = "llama-$tag-bin-win-cpu-x64.zip"
        $binObj  = $rel.assets | Where-Object { $_.name -eq $binName } | Select-Object -First 1
    }

    if ($binObj) {
        $sizeMB = [math]::Round($binObj.size / 1MB, 0)
        Write-Info "Baixando $binName ($sizeMB MB)..."
        $tmpZip = "$env:TEMP\neve_llama_bin.zip"
        Invoke-WebRequest $binObj.browser_download_url -OutFile $tmpZip -UseBasicParsing

        Write-Info 'Extraindo...'
        # Remove executaveis e DLLs antigos
        Get-ChildItem $llamaDir -Filter '*.exe' -EA SilentlyContinue | Remove-Item -Force
        Get-ChildItem $llamaDir -Filter '*.dll' -EA SilentlyContinue | Remove-Item -Force

        $extractTemp = "$env:TEMP\neve_llama_ext"
        if (Test-Path $extractTemp) { Remove-Item $extractTemp -Recurse -Force }
        Expand-Archive $tmpZip -DestinationPath $extractTemp -Force

        # Copia tudo para llamaDir (independente de subpastas no zip)
        Get-ChildItem $extractTemp -Recurse -File |
            ForEach-Object { Copy-Item $_.FullName $llamaDir -Force }

        Remove-Item $extractTemp -Recurse -Force
        Remove-Item $tmpZip -Force
        Write-Ok "llama.cpp $tag instalado em llamacpp-server\bin"
    } else {
        Write-Warn 'Asset nao encontrado. Pulando download do llama.cpp.'
    }

    # CUDA Runtime DLLs (so para builds CUDA)
    if ($llamaAsset -match '^cuda-') {
        $dllName = "cudart-llama-bin-win-$llamaAsset-x64.zip"
        $dllObj  = $rel.assets | Where-Object { $_.name -eq $dllName } | Select-Object -First 1
        if ($dllObj) {
            $sizeMB = [math]::Round($dllObj.size / 1MB, 0)
            Write-Info "Baixando CUDA Runtime DLLs: $dllName ($sizeMB MB)..."
            $tmpDll = "$env:TEMP\neve_llama_dll.zip"
            Invoke-WebRequest $dllObj.browser_download_url -OutFile $tmpDll -UseBasicParsing
            $extractDll = "$env:TEMP\neve_llama_dll_ext"
            if (Test-Path $extractDll) { Remove-Item $extractDll -Recurse -Force }
            Expand-Archive $tmpDll -DestinationPath $extractDll -Force
            Get-ChildItem $extractDll -Recurse -File |
                ForEach-Object { Copy-Item $_.FullName $llamaDir -Force }
            Remove-Item $extractDll -Recurse -Force
            Remove-Item $tmpDll -Force
            Write-Ok 'CUDA Runtime DLLs instaladas.'
        }
    }

} catch {
    Write-Warn "Nao foi possivel baixar llama.cpp automaticamente: $_"
    Write-Info 'Baixe manualmente em: https://github.com/ggml-org/llama.cpp/releases'
    Write-Info "  -> Procure pelo asset: llama-bXXXX-bin-win-$llamaAsset-x64.zip"
}

Write-Host ''

# =============================================================================
# 5. CRIAR VENV PYTHON (sempre recriado do zero)
# =============================================================================
Write-Step '5/7' 'Recriando ambiente Python (venv)...'

if (Test-Path $VENV_DIR) {
    Write-Info 'Removendo venv existente...'
    try {
        Remove-Item $VENV_DIR -Recurse -Force -EA Stop
        Write-Ok 'venv antigo removido.'
    } catch {
        Write-Err "Nao foi possivel remover o venv: $_"
        Write-Err 'Feche todos os processos Python e execute novamente.'
        $null = Read-Host 'Pressione Enter para fechar'; exit 1
    }
}

Write-Info 'Criando novo venv...'
python -m venv $VENV_DIR *>> $LOG
if ($LASTEXITCODE -ne 0) {
    Write-Err "Falha ao criar venv. Log: $LOG"
    $null = Read-Host 'Pressione Enter para fechar'; exit 1
}
Write-Ok "venv criado em $VENV_DIR"
Write-Host ''

# =============================================================================
# 6. DEPENDENCIAS PYTHON
# =============================================================================
Write-Step '6/7' 'Instalando dependencias Python...'

Write-Info 'Atualizando pip...'
& $VENV_PY -m pip install --upgrade pip *>> $LOG

# PyTorch + torchvision (sem pinagem de versao — sempre o mais recente compativel)
if ($torchIndex -ne 'https://download.pytorch.org/whl/cpu') {
    Write-Info "Instalando PyTorch ($cudaVer) -- ~2-3GB, pode demorar..."
} else {
    Write-Info 'Instalando PyTorch (CPU)...'
}
& $VENV_PY -m pip install torch torchvision --index-url $torchIndex *>> $LOG
if ($LASTEXITCODE -ne 0) {
    Write-Err "Falha ao instalar PyTorch. Log: $LOG"
    $null = Read-Host 'Pressione Enter para fechar'; exit 1
}
Write-Ok 'PyTorch instalado.'

# Flash Attention (opcional, Ampere/Ada/Blackwell)
if ($useFlashAttn) {
    Write-Info 'Compilando Flash Attention (~5-15 min)...'
    & $VENV_PY -m pip install flash-attn --no-build-isolation *>> $LOG
    if ($LASTEXITCODE -eq 0) {
        Write-Ok 'Flash Attention instalado.'
    } else {
        Write-Warn 'Flash Attention falhou (precisa de MSVC Build Tools). Continuando sem ela.'
    }
}

# diffusers (Stable Diffusion — latest)
Write-Info 'Instalando diffusers (Stable Diffusion)...'
& $VENV_PY -m pip install diffusers *>> $LOG
if ($LASTEXITCODE -eq 0) { Write-Ok 'diffusers instalado.' } else { Write-Warn 'diffusers falhou (opcional).' }

# Dependencias principais do backend
Write-Info 'Instalando dependencias backend (~5-15 min)...'
& $VENV_PY -m pip install -r "$BACKEND\requirements.txt" *>> $LOG
if ($LASTEXITCODE -ne 0) {
    Write-Warn "Algumas dependencias opcionais podem ter falhado. Log: $LOG"
} else {
    Write-Ok 'Dependencias backend instaladas.'
}

# onnxruntime-gpu (substitui a versao CPU do requirements.txt, melhora OCR/embeddings)
if ($useOnnxGpu) {
    Write-Info 'Instalando onnxruntime-gpu (melhora OCR e embeddings com GPU)...'
    & $VENV_PY -m pip uninstall onnxruntime -y *>> $LOG
    & $VENV_PY -m pip install onnxruntime-gpu *>> $LOG
    if ($LASTEXITCODE -eq 0) {
        Write-Ok 'onnxruntime-gpu instalado (substituiu versao CPU).'
    } else {
        Write-Warn 'onnxruntime-gpu falhou. Reinstalando versao CPU...'
        & $VENV_PY -m pip install onnxruntime *>> $LOG
    }
}

Write-Host ''

# =============================================================================
# 7. FRONTEND (npm install + build + deploy)
# =============================================================================
Write-Step '7/7' 'Frontend: instalando pacotes e compilando...'

Set-Location $ROOT

Write-Info 'npm install...'
npm install *>> $LOG
if ($LASTEXITCODE -ne 0) {
    Write-Err "Falha no npm install. Log: $LOG"
    $null = Read-Host 'Pressione Enter para fechar'; exit 1
}
Write-Ok 'Pacotes npm instalados.'

Write-Info 'npm run build (~2-5 min)...'
npm run build *>> $LOG
if ($LASTEXITCODE -ne 0) {
    Write-Err "Falha no build do frontend. Log: $LOG"
    $null = Read-Host 'Pressione Enter para fechar'; exit 1
}
Write-Ok 'Frontend compilado.'

Write-Info 'Copiando frontend para backend static...'
$staticDir = "$BACKEND\neveai\static"
if (Test-Path $staticDir) { Remove-Item $staticDir -Recurse -Force }
Copy-Item "$ROOT\build\*" $staticDir -Recurse -Force
Write-Ok 'Frontend implantado.'
Write-Host ''

# =============================================================================
# ESTRUTURA DE PASTAS + .ENV
# =============================================================================
foreach ($d in @('logs','logs\webview2','logs\browser-app','models','mmproj',
                 'backend\data','backend\data\uploads','backend\data\vector_db',
                 'backend\data\cache','backend\data\tools')) {
    $p = "$ROOT\$d"
    if (-not (Test-Path $p)) {
        New-Item $p -ItemType Directory -Force | Out-Null
        Write-Info "Criado: $d"
    }
}

if (-not (Test-Path "$ROOT\.env")) {
    @"
# Frontend
VITE_RELATIVE_CONFIG=True
VITE_OPENWEBUI_BACKEND_URL=http://localhost:8080

# Backend
ENV=dev
PORT=8080
WEBUI_SECRET_KEY=troque-esta-chave-por-algo-seguro
WEBUI_AUTH=False
WEBUI_NAME=Neve AI
ENABLE_OLLAMA_API=False
ENABLE_OPENAI_API=False
ENABLE_WEB_SEARCH=False
ENABLE_IMAGE_GENERATION=False
ENABLE_WEBSOCKET_SUPPORT=True
ENABLE_COMMUNITY_SHARING=False
ENABLE_MESSAGE_RATING=False
BYPASS_MODEL_ACCESS_CONTROL=True
ENABLE_SIGNUP=True
ENABLE_LOGIN_FORM=True
SAFE_MODE=False
CORS_ALLOW_ORIGIN=http://localhost:8080
USER_AGENT=Neve AI
"@ | Set-Content "$ROOT\.env"
    Write-Ok '.env criado com configuracoes padrao.'
} else {
    Write-Info '.env ja existe, nao foi sobrescrito.'
}

# =============================================================================
# RESUMO FINAL
# =============================================================================
Write-Host ''
Write-Host '  ================================================' -ForegroundColor Cyan
Write-Host '     INSTALACAO CONCLUIDA COM SUCESSO!' -ForegroundColor Green
Write-Host '  ================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host '  Versoes instaladas:' -ForegroundColor White
Write-Host "    $(python --version 2>&1)" -ForegroundColor DarkGray
Write-Host "    $(node --version 2>&1)" -ForegroundColor DarkGray

$torchOut = & $VENV_PY -c "import torch; v=torch.__version__; cuda='(CUDA '+torch.version.cuda+')' if torch.cuda.is_available() else '(CPU)'; print('PyTorch '+v+' '+cuda)" 2>$null
if ($torchOut) { Write-Host "    $torchOut" -ForegroundColor DarkGray }

if ($vramGb -gt 0) { Write-Host "    VRAM: ${vramGb}GB ($gpuName)" -ForegroundColor DarkGray }
if ($llamaAsset -ne 'cpu') { Write-Host "    llama.cpp: $llamaAsset" -ForegroundColor DarkGray }
Write-Host ''
Write-Host '  Para iniciar o Neve AI execute: iniciar.bat' -ForegroundColor Green
Write-Host "  Log completo disponivel em: logs\install.log" -ForegroundColor DarkGray
Write-Host ''

Write-Host '  ================================================' -ForegroundColor DarkGray
Write-Host '  O que REMOVER antes de distribuir o projeto:' -ForegroundColor DarkGray
Write-Host '    backend\neveai\venv\   ~6 GB  (recriado pelo instalar)' -ForegroundColor DarkGray
Write-Host '    node_modules\              ~950 MB (recriado pelo npm install)' -ForegroundColor DarkGray
Write-Host '    build\                     ~160 MB (recriado pelo npm build)' -ForegroundColor DarkGray
Write-Host '    .svelte-kit\               ~190 MB (cache compilador)' -ForegroundColor DarkGray
Write-Host '    models\ mmproj\            (usuario baixa os seus proprios)' -ForegroundColor DarkGray
Write-Host '  ================================================' -ForegroundColor DarkGray
Write-Host ''

$null = Read-Host 'Pressione Enter para fechar'
