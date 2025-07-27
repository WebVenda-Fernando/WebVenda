# Script de configuração automática do GitHub para Kiro
param(
    [Parameter(Mandatory=$true)]
    [string]$Username,
    
    [Parameter(Mandatory=$true)]
    [string]$Email,
    
    [Parameter(Mandatory=$true)]
    [string]$Token,
    
    [Parameter(Mandatory=$true)]
    [string]$RepoName,
    
    [string]$Organization = ""
)

Write-Host "=== CONFIGURAÇÃO GITHUB PARA KIRO ===" -ForegroundColor Green

# 1. Configurar Git local para a nova conta
Write-Host "1. Configurando credenciais Git..." -ForegroundColor Cyan
git config user.name "$Username"
git config user.email "$Email"

# 2. Inicializar repositório se não existir
if (-not (Test-Path ".git")) {
    Write-Host "2. Inicializando repositório Git..." -ForegroundColor Cyan
    git init
    git branch -M main
}

# 3. Criar .gitignore otimizado
Write-Host "3. Criando .gitignore..." -ForegroundColor Cyan
@"
# Dependencies
node_modules/
.pnp
.pnp.js

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
lerna-debug.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/
*.lcov

# Build outputs
dist/
build/
out/

# IDE files
.vscode/settings.json
.idea/
*.swp
*.swo

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Kiro specific
.kiro/cache/
.kiro/logs/
.kiro/temp/

# Flutter/Dart
.dart_tool/
.packages
.pub-cache/
.pub/
build/
.flutter-plugins
.flutter-plugins-dependencies

# Angular
.angular/cache/
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8

# 4. Criar repositório no GitHub via API
Write-Host "4. Criando repositório no GitHub..." -ForegroundColor Cyan
$headers = @{
    "Authorization" = "token $Token"
    "Accept" = "application/vnd.github.v3+json"
}

$body = @{
    "name" = $RepoName
    "description" = "Projeto gerenciado automaticamente pelo Kiro"
    "private" = $false
    "auto_init" = $false
} | ConvertTo-Json

try {
    $repoUrl = if ($Organization) { 
        "https://api.github.com/orgs/$Organization/repos" 
    } else { 
        "https://api.github.com/user/repos" 
    }
    
    $response = Invoke-RestMethod -Uri $repoUrl -Method Post -Headers $headers -Body $body
    Write-Host "✓ Repositório criado: $($response.html_url)" -ForegroundColor Green
    
    # 5. Adicionar remote
    $remoteUrl = if ($Organization) {
        "https://github.com/$Organization/$RepoName.git"
    } else {
        "https://github.com/$Username/$RepoName.git"
    }
    
    git remote add origin $remoteUrl
    Write-Host "✓ Remote adicionado: $remoteUrl" -ForegroundColor Green
    
} catch {
    Write-Host "⚠ Erro ao criar repositório: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "Tentando adicionar remote para repositório existente..." -ForegroundColor Yellow
    
    $remoteUrl = if ($Organization) {
        "https://github.com/$Organization/$RepoName.git"
    } else {
        "https://github.com/$Username/$RepoName.git"
    }
    
    git remote add origin $remoteUrl 2>$null
}

# 6. Commit inicial
Write-Host "5. Fazendo commit inicial..." -ForegroundColor Cyan
git add .
git commit -m "Initial commit via Kiro setup"

# 7. Push para GitHub
Write-Host "6. Enviando para GitHub..." -ForegroundColor Cyan
git push -u origin main

Write-Host "=== CONFIGURAÇÃO CONCLUÍDA ===" -ForegroundColor Green
Write-Host "Repositório configurado e sincronizado com GitHub!" -ForegroundColor White