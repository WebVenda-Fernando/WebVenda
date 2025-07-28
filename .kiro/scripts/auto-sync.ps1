# Script de sincronizacao automatica com GitHub
param(
    [string]$CommitMessage = "Auto-update via Kiro - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
)

# Carregar configuracao
$configPath = ".kiro/settings/github-config.json"
if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Json
    
    if (-not $config.automation.enabled) {
        Write-Host "Sincronizacao automatica desabilitada" -ForegroundColor Yellow
        exit 0
    }
} else {
    Write-Host "Arquivo de configuracao nao encontrado: $configPath" -ForegroundColor Red
    exit 1
}

Write-Host "=== SINCRONIZACAO AUTOMATICA ===" -ForegroundColor Green

# Verificar se ha mudancas
$status = git status --porcelain
if (-not $status) {
    Write-Host "Nenhuma mudanca detectada" -ForegroundColor Yellow
    exit 0
}

Write-Host "Mudancas detectadas:" -ForegroundColor Cyan
git status --short

# Adicionar arquivos (respeitando .gitignore)
Write-Host "Adicionando arquivos..." -ForegroundColor Cyan
git add .

# Commit
Write-Host "Fazendo commit..." -ForegroundColor Cyan
git commit -m "$CommitMessage"

# Push
Write-Host "Enviando para GitHub..." -ForegroundColor Cyan
$pushResult = git push origin main 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Sincronizacao concluida com sucesso!" -ForegroundColor Green
} else {
    Write-Host "Erro na sincronizacao, tentando resolver..." -ForegroundColor Yellow
    
    # Tentar pull e merge em caso de conflito
    Write-Host "Fazendo pull com rebase..." -ForegroundColor Yellow
    git pull origin main --rebase
    
    Write-Host "Tentando push novamente..." -ForegroundColor Yellow
    git push origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Conflitos resolvidos e sincronizacao concluida!" -ForegroundColor Green
    } else {
        Write-Host "Erro persistente na sincronizacao" -ForegroundColor Red
        exit 1
    }
}
