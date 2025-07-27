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
try {
    git push origin main
    Write-Host "✓ Sincronização concluída com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "✗ Erro na sincronização: $($_.Exception.Message)" -ForegroundColor Red
    
    # Tentar pull e merge em caso de conflito
    Write-Host "Tentando resolver conflitos..." -ForegroundColor Yellow
    git pull origin main --rebase
    git push origin main
    Write-Host "✓ Conflitos resolvidos e sincronização concluída!" -ForegroundColor Green
}