# Script para atualizar README automaticamente
param(
    [string]$ProjectName = (Split-Path (Get-Location) -Leaf)
)

$readmePath = "README.md"
$currentDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Template do README
$readmeContent = @"
# $ProjectName

> Projeto gerenciado automaticamente pelo Kiro

## 📋 Descrição

Este projeto é mantido e sincronizado automaticamente com o GitHub através do Kiro IDE.

## 🚀 Tecnologias

- **Frontend**: Angular, Vue.js, Tailwind CSS
- **Backend**: Node.js, Prisma
- **Mobile**: Flutter/Dart
- **Database**: PostgreSQL
- **DevOps**: GitHub Actions, Docker

## 📁 Estrutura do Projeto

```
$ProjectName/
├── src/                 # Código fonte
├── prisma/             # Schema do banco de dados
├── .kiro/              # Configurações do Kiro
│   ├── settings/       # Configurações gerais
│   ├── scripts/        # Scripts de automação
│   └── hooks/          # Hooks de automação
├── package.json        # Dependências Node.js
├── angular.json        # Configuração Angular
├── pubspec.yaml        # Dependências Flutter
└── README.md           # Este arquivo
```

## 🔧 Configuração

### Pré-requisitos
- Node.js 18+
- Flutter SDK
- PostgreSQL
- Kiro IDE

### Instalação
```bash
# Instalar dependências Node.js
npm install

# Instalar dependências Flutter
flutter pub get

# Configurar banco de dados
npx prisma migrate dev
```

## 🤖 Automação

Este projeto utiliza automação via Kiro para:
- ✅ Sincronização automática com GitHub
- ✅ Commits automáticos ao salvar arquivos
- ✅ Atualização automática da documentação
- ✅ Integração contínua

## 📊 Status do Projeto

- **Última atualização**: $currentDate
- **Status**: Em desenvolvimento ativo
- **Sincronização**: Automática via Kiro

## 🔗 Links Úteis

- [Documentação do Kiro](https://kiro.ai/docs)
- [GitHub Repository](https://github.com/[username]/$ProjectName)

## 📝 Changelog

### Recente
- Configuração inicial do projeto
- Integração com GitHub via Kiro
- Setup de automação completa

---

*Este README é atualizado automaticamente pelo Kiro IDE*
"@

# Verificar se README existe e se precisa ser atualizado
if (Test-Path $readmePath) {
    $existingContent = Get-Content $readmePath -Raw
    
    # Verificar se já tem a seção de última atualização
    if ($existingContent -match "Última atualização.*: (.+)") {
        # Atualizar apenas a data
        $updatedContent = $existingContent -replace "Última atualização.*: .+", "Última atualização**: $currentDate"
        $updatedContent | Set-Content $readmePath -Encoding UTF8
        Write-Host "✓ README atualizado com nova data" -ForegroundColor Green
    } else {
        # README existe mas não tem automação, fazer backup
        Copy-Item $readmePath "$readmePath.backup"
        $readmeContent | Set-Content $readmePath -Encoding UTF8
        Write-Host "✓ README substituído (backup criado)" -ForegroundColor Yellow
    }
} else {
    # Criar novo README
    $readmeContent | Set-Content $readmePath -Encoding UTF8
    Write-Host "✓ README criado automaticamente" -ForegroundColor Green
}

# Atualizar configuração com informações do projeto
if (Test-Path ".kiro/settings/github-config.json") {
    $config = Get-Content ".kiro/settings/github-config.json" | ConvertFrom-Json
    $config.project = @{
        name = $ProjectName
        lastUpdated = $currentDate
        autoReadme = $true
    }
    $config | ConvertTo-Json -Depth 10 | Set-Content ".kiro/settings/github-config.json" -Encoding UTF8
}