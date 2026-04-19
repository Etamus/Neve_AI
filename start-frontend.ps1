# Frontend da Neve AI
$rootDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Libera porta 5173 caso esteja em uso
$ocupados = (Get-NetTCPConnection -LocalPort 5173 -ErrorAction SilentlyContinue).OwningProcess | Sort-Object -Unique
if ($ocupados) {
    $ocupados | Where-Object { $_ -ne 0 } | ForEach-Object {
        Write-Host "Liberando porta 5173 (PID $_)..."
        Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep 2
}

Write-Host "Iniciando frontend Neve AI na porta 5173..." -ForegroundColor Cyan
Write-Host "Pressione Ctrl+C para parar`n"

Set-Location $rootDir
& "C:\Program Files\nodejs\npx.cmd" vite dev --host --port 5173
