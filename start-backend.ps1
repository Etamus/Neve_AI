# Backend da Neve AI - usa Python do venv local
$env:PYTHONIOENCODING = "utf-8"
$rootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Join-Path $rootDir "backend"
$pythonExe = Join-Path $rootDir "backend\open_webui\venv\Scripts\python.exe"

# Forca Python a usar codigo-fonte em vez do pacote instalado no venv
$env:PYTHONPATH = $backendDir

# Desabilita autenticacao (login automatico)
$env:WEBUI_AUTH = "False"

# Verifica se o venv existe
if (-not (Test-Path $pythonExe)) {
    Write-Host "ERRO: venv nao encontrado em $pythonExe" -ForegroundColor Red
    Write-Host "Execute: python -m venv .venv && .venv\Scripts\pip install -r backend\requirements.txt"
    Read-Host "Pressione Enter para sair"
    exit 1
}

# Cria pasta models se nao existir
$modelsDir = Join-Path $rootDir "models"
if (-not (Test-Path $modelsDir)) {
    New-Item $modelsDir -ItemType Directory -Force | Out-Null
}

# Libera porta 8080 caso esteja em uso
$ocupados = (Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue).OwningProcess | Sort-Object -Unique
if ($ocupados) {
    $ocupados | Where-Object { $_ -ne 0 } | ForEach-Object {
        Write-Host "Liberando porta 8080 (PID $_)..."
        Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep 2
}

Write-Host "Iniciando backend Neve AI na porta 8080..." -ForegroundColor Cyan
Write-Host "Modelos GGUF: $modelsDir"
Write-Host "Pressione Ctrl+C para parar`n"

Set-Location $backendDir
& $pythonExe -m uvicorn open_webui.main:app --host 0.0.0.0 --port 8080
