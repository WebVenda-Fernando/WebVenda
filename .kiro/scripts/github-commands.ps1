# Comandos GitHub para Kiro
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("setup", "sync", "status", "config", "switch-account")]
    [string]$Command
)

function Show-GitHubStatus {
    Write-Host "=== STATUS DO REPOSITÓRIO GITHUB ===" -ForegroundColor Green
    
    # Verificar se é um repositório Git
    if (-not (Test-Path ".git")) {
        Write-Host "✗ Não é um repositório Git" -ForegroundColor Red
        return
    }
    
    # Mostrar informações básicas
    Write-Host "Branch atual:" -ForegroundColor Cyan
    git branch --show-current
    
    Write-Host "`nRemotes configurados:" -ForegroundColor Cyan
    git remote -v
    
    Write-Host "`nStatus dos arquivos:" -ForegroundColor Cyan
    git status --short
    
    Write-Host "`nÚltimos commits:" -ForegroundColor Cyan
    git log --oneline -5
    
    # Verificar configuração
    if (Test-Path ".kiro/settings/github-config.json") {
        $config = Get-Content ".kiro/settings/github-config.json" | ConvertFrom-Json
        Write-Host "`nConfiguração atual:" -ForegroundColor Cyan
        Write-Host "Username: $($config.github.username)" -ForegroundColor White
        Write-Host "Email: $($config.github.email)" -ForegroundColor White
        Write-Host "Repositório: $($config.github.repositories.current)" -ForegroundColor White
        Write-Host "Auto-sync: $($config.automation.enabled)" -ForegroundColor White
    }
}

function Show-GitHubConfig {
    Write-Host "=== CONFIGURAÇÃO GITHUB ===" -ForegroundColor Green
    
    if (Test-Path ".kiro/settings/github-config.json") {
        $config = Get-Content ".kiro/settings/github-config.json" | ConvertFrom-Json
        $config | ConvertTo-Json -Depth 10 | Write-Host
    } else {
        Write-Host "Nenhuma configuração encontrada. Execute #github-setup primeiro." -ForegroundColor Yellow
    }
}

function Sync-GitHub {
    Write-Host "=== SINCRONIZAÇÃO MANUAL ===" -ForegroundColor Green
    & ".kiro/scripts/auto-sync.ps1"
}

function Switch-GitHubAccount {
    Write-Host "=== TROCAR CONTA GITHUB ===" -ForegroundColor Green
    Write-Host "Isso irá reconfigurar sua conta GitHub atual." -ForegroundColor Yellow
    
    $confirm = Read-Host "Deseja continuar? (s/N)"
    if ($confirm -eq "s" -or $confirm -eq "S") {
        & ".kiro/scripts/github-account-setup.ps1"
    } else {
        Write-Host "Operação cancelada." -ForegroundColor Yellow
    }
}

# Executar comando
switch ($Command) {
    "setup" { & ".kiro/scripts/github-account-setup.ps1" }
    "sync" { Sync-GitHub }
    "status" { Show-GitHubStatus }
    "config" { Show-GitHubConfig }
    "switch-account" { Switch-GitHubAccount }
}