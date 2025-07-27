# Comando principal para integração GitHub + Kiro
param(
    [Parameter(Position=0)]
    [ValidateSet("setup", "sync", "status", "config", "switch", "help")]
    [string]$Action = "help"
)

function Show-Help {
    Write-Host "=== KIRO + GITHUB INTEGRATION ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Comandos disponíveis:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  setup        " -NoNewline -ForegroundColor Yellow
    Write-Host "Configurar nova conta GitHub"
    Write-Host "  sync         " -NoNewline -ForegroundColor Yellow  
    Write-Host "Sincronizar manualmente com GitHub"
    Write-Host "  status       " -NoNewline -ForegroundColor Yellow
    Write-Host "Ver status do repositório"
    Write-Host "  config       " -NoNewline -ForegroundColor Yellow
    Write-Host "Ver configuração atual"
    Write-Host "  switch       " -NoNewline -ForegroundColor Yellow
    Write-Host "Trocar conta GitHub"
    Write-Host "  help         " -NoNewline -ForegroundColor Yellow
    Write-Host "Mostrar esta ajuda"
    Write-Host ""
    Write-Host "Exemplos:" -ForegroundColor Cyan
    Write-Host "  .\github-kiro.ps1 setup     # Configurar nova conta"
    Write-Host "  .\github-kiro.ps1 sync      # Sincronizar agora"
    Write-Host "  .\github-kiro.ps1 status    # Ver status"
    Write-Host ""
    Write-Host "Automação:" -ForegroundColor Cyan
    Write-Host "• Sincronização automática ao salvar arquivos"
    Write-Host "• Commits automáticos com timestamps"
    Write-Host "• Atualização automática do README"
    Write-Host "• Criação automática de repositórios"
}

# Verificar se os scripts existem
$scriptsPath = ".kiro/scripts"
if (-not (Test-Path $scriptsPath)) {
    Write-Host "Erro: Diretório de scripts não encontrado!" -ForegroundColor Red
    Write-Host "Certifique-se de estar no diretório raiz do projeto." -ForegroundColor Yellow
    exit 1
}

# Executar ação
switch ($Action) {
    "setup" {
        Write-Host "Iniciando configuração da conta GitHub..." -ForegroundColor Green
        & "$scriptsPath/github-account-setup.ps1"
    }
    "sync" {
        Write-Host "Sincronizando com GitHub..." -ForegroundColor Green
        & "$scriptsPath/github-commands.ps1" -Command "sync"
    }
    "status" {
        & "$scriptsPath/github-commands.ps1" -Command "status"
    }
    "config" {
        & "$scriptsPath/github-commands.ps1" -Command "config"
    }
    "switch" {
        & "$scriptsPath/github-commands.ps1" -Command "switch-account"
    }
    "help" {
        Show-Help
    }
    default {
        Show-Help
    }
}