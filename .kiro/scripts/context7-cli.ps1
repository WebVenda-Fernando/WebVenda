# Context7 CLI - Interface de linha de comando para gerenciar cache
param(
    [Parameter(Position=0)]
    [ValidateSet("cache", "preload", "stats", "clear", "config", "help")]
    [string]$Command = "help",
    
    [Parameter(Position=1)]
    [string]$Target = "",
    
    [switch]$Force = $false,
    [switch]$Verbose = $false
)

$cacheManager = ".kiro/scripts/context7-cache-manager.ps1"
$preloader = ".kiro/scripts/context7-preloader.ps1"
$configPath = ".kiro/settings/context7-config.json"

function Show-Help {
    Write-Host "=== CONTEXT7 CACHE CLI ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Comandos disponíveis:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  cache <action>   " -NoNewline -ForegroundColor Yellow
    Write-Host "Gerenciar cache (get|set|clear|stats|cleanup)"
    Write-Host "  preload          " -NoNewline -ForegroundColor Yellow
    Write-Host "Pré-carregar bibliotecas populares"
    Write-Host "  stats            " -NoNewline -ForegroundColor Yellow
    Write-Host "Mostrar estatísticas do cache"
    Write-Host "  clear [library]  " -NoNewline -ForegroundColor Yellow
    Write-Host "Limpar cache (específico ou total)"
    Write-Host "  config           " -NoNewline -ForegroundColor Yellow
    Write-Host "Mostrar configuração atual"
    Write-Host "  help             " -NoNewline -ForegroundColor Yellow
    Write-Host "Mostrar esta ajuda"
    Write-Host ""
    Write-Host "Exemplos:" -ForegroundColor Cyan
    Write-Host "  .\context7-cli.ps1 stats              # Ver estatísticas"
    Write-Host "  .\context7-cli.ps1 preload -Force     # Forçar preload"
    Write-Host "  .\context7-cli.ps1 clear react        # Limpar cache do React"
    Write-Host "  .\context7-cli.ps1 cache cleanup      # Limpeza automática"
    Write-Host ""
}

function Show-Config {
    if (Test-Path $configPath) {
        $config = Get-Content $configPath | ConvertFrom-Json
        
        Write-Host "=== CONFIGURAÇÃO CONTEXT7 ===" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Cache:" -ForegroundColor Yellow
        Write-Host "  Habilitado: $($config.cache.enabled)" -ForegroundColor White
        Write-Host "  Max Age: $($config.cache.maxAge)s" -ForegroundColor White
        Write-Host "  Max Entries: $($config.cache.maxEntries)" -ForegroundColor White
        Write-Host "  Max Size: $($config.cache.maxSize)" -ForegroundColor White
        Write-Host ""
        Write-Host "Performance:" -ForegroundColor Yellow
        Write-Host "  Preload Popular: $($config.performance.preloadPopular)" -ForegroundColor White
        Write-Host "  Background Refresh: $($config.performance.backgroundRefresh)" -ForegroundColor White
        Write-Host ""
        Write-Host "Bibliotecas Populares:" -ForegroundColor Yellow
        $config.popularLibraries | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
    } else {
        Write-Host "❌ Arquivo de configuração não encontrado: $configPath" -ForegroundColor Red
    }
}

# Executar comando
switch ($Command) {
    "cache" {
        if (-not $Target) {
            Write-Host "❌ Ação do cache não especificada" -ForegroundColor Red
            Write-Host "Ações disponíveis: get, set, clear, stats, cleanup" -ForegroundColor Yellow
            exit 1
        }
        
        $args = @("-Action", $Target)
        if ($Verbose) { $args += "-Verbose" }
        
        & $cacheManager @args
    }
    
    "preload" {
        $args = @()
        if ($Force) { $args += "-Force" }
        
        & $preloader @args
    }
    
    "stats" {
        & $cacheManager -Action "stats"
    }
    
    "clear" {
        if ($Target) {
            & $cacheManager -Action "clear" -LibraryId $Target
        } else {
            Write-Host "⚠️ Isso irá limpar TODO o cache. Continuar? (y/N): " -NoNewline -ForegroundColor Yellow
            $confirm = Read-Host
            if ($confirm -eq "y" -or $confirm -eq "Y") {
                & $cacheManager -Action "clear"
            } else {
                Write-Host "❌ Operação cancelada" -ForegroundColor Red
            }
        }
    }
    
    "config" {
        Show-Config
    }
    
    "help" {
        Show-Help
    }
    
    default {
        Write-Host "❌ Comando desconhecido: $Command" -ForegroundColor Red
        Show-Help
        exit 1
    }
}