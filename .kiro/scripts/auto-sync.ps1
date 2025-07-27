# Script de sincronização automática com GitHub
param(
    [string]$CommitMessage = "Auto-update via Kiro - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
)

# Carregar configuração
$configPath = ".kiro/settings/github-config.json"
if (Test-Path $configPath) {
    $config = Get-Content $configPath | ConvertFrom-Json
    
    if (-not $config.automation.enabled) {
        Write-Host "Sincronização automática desabilitada" -ForegroundColor Yellow
        exit 0
    }
} else {
    Write-Host "Arquivo de configuração não encontrado: $configPath" -ForegroundColor Red
    exit 1
}

Write-Host "=== SINCRONIZAÇÃO AUTOMÁTICA ===" -ForegroundColor Green

# Verificar se há mudanças
$status = git status --porcelain
if (-not $status) {
    Write-Host "Nenhuma mudança detectada" -ForegroundColor Yellow
    exit 0
}

Write-Host "Mudanças detectadas:" -ForegroundColor Cyan
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
    Write-Host "✓ Sincronização concluída com sucesso!" -ForegroundColor Green
} else {
    Write-Host "⚠ Erro na sincronização, tentando resolver..." -ForegroundColor Yellow
    
    # Tentar pull e merge em caso de conflito
    Write-Host "Fazendo pull com rebase..." -ForegroundColor Yellow
    git pull origin main --rebase
    
    Write-Host "Tentando push novamente..." -ForegroundColor Yellow
    git push origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Conflitos resolvidos e sincronização concluída!" -ForegroundColor Green
    } else {
        Write-Host "✗ Erro persistente na sincronização" -ForegroundColor Red
        exit 1
    }
}