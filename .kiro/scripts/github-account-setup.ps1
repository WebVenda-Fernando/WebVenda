# Script Interativo para Configuração de Nova Conta GitHub
Write-Host "=== CONFIGURAÇÃO DE NOVA CONTA GITHUB ===" -ForegroundColor Green
Write-Host ""

# Função para validar entrada
function Get-ValidInput {
    param([string]$Prompt, [bool]$Required = $true)
    do {
        $input = Read-Host $Prompt
        if ($Required -and [string]::IsNullOrWhiteSpace($input)) {
            Write-Host "Este campo é obrigatório!" -ForegroundColor Red
        }
    } while ($Required -and [string]::IsNullOrWhiteSpace($input))
    return $input
}

# Coletar informações da nova conta
Write-Host "Vamos configurar sua nova conta GitHub:" -ForegroundColor Cyan
Write-Host ""

$newUsername = Get-ValidInput "Digite o username da nova conta GitHub"
$newEmail = Get-ValidInput "Digite o email da nova conta GitHub"
$repoName = Get-ValidInput "Digite o nome do repositório para este projeto"

Write-Host ""
Write-Host "IMPORTANTE: Você precisa criar um Personal Access Token no GitHub" -ForegroundColor Yellow
Write-Host "1. Acesse: https://github.com/settings/tokens" -ForegroundColor White
Write-Host "2. Clique em 'Generate new token (classic)'" -ForegroundColor White
Write-Host "3. Selecione os escopos: repo, workflow, write:packages" -ForegroundColor White
Write-Host "4. Copie o token gerado" -ForegroundColor White
Write-Host ""

$token = Get-ValidInput "Cole aqui o Personal Access Token"
$organization = Read-Host "Organização (opcional, deixe vazio se for conta pessoal)"

# Salvar configuração
$config = @{
    github = @{
        username = $newUsername
        email = $newEmail
        token = $token
        defaultBranch = "main"
        autoCommit = $true
        autoSync = $true
        commitMessage = "Auto-update via Kiro"
        repositories = @{
            current = $repoName
            organization = $organization
        }
    }
    automation = @{
        enabled = $true
        syncInterval = "30m"
        autoCreateRepo = $true
        autoUpdateReadme = $true
        ignorePaths = @(
            "node_modules/",
            ".env",
            "*.log",
            ".kiro/cache/",
            ".kiro/temp/"
        )
    }
} | ConvertTo-Json -Depth 10

$config | Set-Content ".kiro/settings/github-config.json" -Encoding UTF8

Write-Host ""
Write-Host "✓ Configuração salva!" -ForegroundColor Green

# Executar configuração
Write-Host ""
Write-Host "Executando configuração automática..." -ForegroundColor Cyan

& ".kiro/scripts/github-setup.ps1" -Username $newUsername -Email $newEmail -Token $token -RepoName $repoName -Organization $organization

Write-Host ""
Write-Host "=== CONFIGURAÇÃO CONCLUÍDA ===" -ForegroundColor Green
Write-Host "Sua nova conta GitHub está configurada e o repositório foi criado!" -ForegroundColor White
Write-Host ""
Write-Host "Comandos disponíveis:" -ForegroundColor Cyan
Write-Host "• #github-sync - Sincronizar manualmente" -ForegroundColor White
Write-Host "• #github-status - Ver status do repositório" -ForegroundColor White
Write-Host "• #github-config - Ver configuração atual" -ForegroundColor White