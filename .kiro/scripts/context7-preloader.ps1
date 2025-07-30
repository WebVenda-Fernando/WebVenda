# Context7 Preloader - Carrega bibliotecas populares em background
param(
    [switch]$Force = $false
)

$configPath = ".kiro/settings/context7-config.json"
$cacheManager = ".kiro/scripts/context7-cache-manager.ps1"

if (-not (Test-Path $configPath)) {
    Write-Host "❌ Configuração do Context7 não encontrada" -ForegroundColor Red
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json

if (-not $config.performance.preloadPopular) {
    Write-Host "⏭️ Preload desabilitado na configuração" -ForegroundColor Yellow
    exit 0
}

Write-Host "🚀 Iniciando preload de bibliotecas populares..." -ForegroundColor Cyan

$preloaded = 0
$skipped = 0
$errors = 0

foreach ($library in $config.popularLibraries) {
    try {
        # Verificar se já está em cache e válido
        $cacheResult = & $cacheManager -Action "get" -LibraryId $library 2>$null
        
        if ($LASTEXITCODE -eq 0 -and -not $Force) {
            Write-Host "Cache válido: $library" -ForegroundColor Green
            $skipped++
            continue
        }
        
        Write-Host "Preloading $library..." -ForegroundColor Yellow
        
        # Simular busca da biblioteca (em implementação real, usar MCP)
        Start-Sleep -Milliseconds 500
        
        $mockData = @{
            library = $library
            description = "Documentação pré-carregada para $library"
            timestamp = Get-Date
            preloaded = $true
        } | ConvertTo-Json
        
        # Salvar no cache
        & $cacheManager -Action "set" -LibraryId $library -Data $mockData | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Preloaded: $library" -ForegroundColor Green
            $preloaded++
        } else {
            Write-Host "Erro ao cachear: $library" -ForegroundColor Red
            $errors++
        }
        
    } catch {
        Write-Host "Erro no preload de ${library}: $_" -ForegroundColor Red
        $errors++
    }
}

# Relatório final
Write-Host "`n=== PRELOAD CONCLUÍDO ===" -ForegroundColor Cyan
Write-Host "✅ Preloaded: $preloaded" -ForegroundColor Green
Write-Host "⏭️ Skipped: $skipped" -ForegroundColor Yellow
Write-Host "❌ Errors: $errors" -ForegroundColor Red

# Mostrar estatísticas do cache
& $cacheManager -Action "stats"