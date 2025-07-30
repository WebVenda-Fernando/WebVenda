# Context7 Cache Manager - Sistema de cache inteligente
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("get", "set", "clear", "stats", "cleanup")]
    [string]$Action,
    
    [string]$LibraryId = "",
    [string]$Topic = "",
    [string]$Data = "",
    [int]$MaxAge = 3600
)

# Configurações do cache
$cacheDir = ".kiro/cache/context7"
$maxCacheSize = 50MB
$maxEntries = 1000

# Criar diretório de cache se não existir
if (-not (Test-Path $cacheDir)) {
    New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
}

function Get-CacheKey {
    param([string]$LibraryId, [string]$Topic)
    $key = if ($Topic) { "$LibraryId-$Topic" } else { $LibraryId }
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($key)
    $hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash($bytes)
    return ($hash | ForEach-Object { $_.ToString("x2") }) -join ""
}

function Get-CacheFilePath {
    param([string]$CacheKey)
    return Join-Path $cacheDir "$CacheKey.json"
}

function Test-CacheValid {
    param([string]$FilePath, [int]$MaxAge)
    if (-not (Test-Path $FilePath)) { return $false }
    
    $fileAge = (Get-Date) - (Get-Item $FilePath).LastWriteTime
    return $fileAge.TotalSeconds -lt $MaxAge
}

function Get-CacheStats {
    $files = Get-ChildItem $cacheDir -Filter "*.json" -ErrorAction SilentlyContinue
    $totalSize = ($files | Measure-Object -Property Length -Sum).Sum
    $totalFiles = $files.Count
    
    return @{
        TotalEntries = $totalFiles
        TotalSize = $totalSize
        TotalSizeMB = [math]::Round($totalSize / 1MB, 2)
        MaxEntries = $maxEntries
        MaxSizeMB = [math]::Round($maxCacheSize / 1MB, 2)
        UsagePercent = [math]::Round(($totalFiles / $maxEntries) * 100, 1)
    }
}

function Cleanup-Cache {
    $files = Get-ChildItem $cacheDir -Filter "*.json" -ErrorAction SilentlyContinue | 
             Sort-Object LastAccessTime
    
    $stats = Get-CacheStats
    $removed = 0
    
    # Remover arquivos antigos se exceder limites
    if ($stats.TotalEntries -gt $maxEntries -or $stats.TotalSize -gt $maxCacheSize) {
        $filesToRemove = $files | Select-Object -First ([math]::Max(1, $files.Count - $maxEntries + 100))
        
        foreach ($file in $filesToRemove) {
            Remove-Item $file.FullName -Force
            $removed++
        }
    }
    
    # Remover arquivos expirados
    foreach ($file in $files) {
        if (-not (Test-CacheValid $file.FullName $MaxAge)) {
            Remove-Item $file.FullName -Force
            $removed++
        }
    }
    
    return $removed
}

# Executar ação
switch ($Action) {
    "get" {
        if (-not $LibraryId) {
            Write-Error "LibraryId é obrigatório para operação 'get'"
            exit 1
        }
        
        $cacheKey = Get-CacheKey $LibraryId $Topic
        $filePath = Get-CacheFilePath $cacheKey
        
        if (Test-CacheValid $filePath $MaxAge) {
            $cacheData = Get-Content $filePath -Raw | ConvertFrom-Json
            
            # Atualizar último acesso
            (Get-Item $filePath).LastAccessTime = Get-Date
            
            Write-Output $cacheData.data
            Write-Host "Cache hit: $LibraryId" -ForegroundColor Green
            exit 0
        } else {
            Write-Host "Cache miss: $LibraryId" -ForegroundColor Yellow
            exit 1
        }
    }
    
    "set" {
        if (-not $LibraryId -or -not $Data) {
            Write-Error "LibraryId e Data são obrigatórios para operação 'set'"
            exit 1
        }
        
        $cacheKey = Get-CacheKey $LibraryId $Topic
        $filePath = Get-CacheFilePath $cacheKey
        
        $cacheEntry = @{
            libraryId = $LibraryId
            topic = $Topic
            data = $Data
            timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            accessCount = 1
        }
        
        $cacheEntry | ConvertTo-Json -Depth 10 | Set-Content $filePath -Encoding UTF8
        Write-Host "Cached: $LibraryId" -ForegroundColor Green
        
        # Cleanup automático
        $removed = Cleanup-Cache
        if ($removed -gt 0) {
            Write-Host "Cleanup: $removed arquivos removidos" -ForegroundColor Cyan
        }
    }
    
    "clear" {
        if ($LibraryId) {
            # Limpar cache específico
            $cacheKey = Get-CacheKey $LibraryId $Topic
            $filePath = Get-CacheFilePath $cacheKey
            
            if (Test-Path $filePath) {
                Remove-Item $filePath -Force
                Write-Host "Cache removido: $LibraryId" -ForegroundColor Green
            } else {
                Write-Host "Cache não encontrado: $LibraryId" -ForegroundColor Yellow
            }
        } else {
            # Limpar todo o cache
            Remove-Item "$cacheDir\*.json" -Force -ErrorAction SilentlyContinue
            Write-Host "Todo o cache foi limpo" -ForegroundColor Green
        }
    }
    
    "stats" {
        $stats = Get-CacheStats
        
        Write-Host "=== CONTEXT7 CACHE STATS ===" -ForegroundColor Cyan
        $usageText = "$($stats.TotalEntries)/$($stats.MaxEntries) ($($stats.UsagePercent)%)"
        Write-Host "Entradas: $usageText" -ForegroundColor White
        Write-Host "Tamanho: $($stats.TotalSizeMB)MB/$($stats.MaxSizeMB)MB" -ForegroundColor White
        Write-Host "Diretório: $cacheDir" -ForegroundColor Gray
        
        # Mostrar arquivos mais acessados
        $files = Get-ChildItem $cacheDir -Filter "*.json" -ErrorAction SilentlyContinue |
                 Sort-Object LastAccessTime -Descending |
                 Select-Object -First 5
        
        if ($files) {
            Write-Host "`nMais recentes:" -ForegroundColor Cyan
            foreach ($file in $files) {
                $data = Get-Content $file.FullName -Raw | ConvertFrom-Json
                $age = (Get-Date) - $file.LastWriteTime
                $ageText = [math]::Round($age.TotalMinutes, 1)
                Write-Host "  $($data.libraryId) - ${ageText}min" -ForegroundColor Gray
            }
        }
    }
    
    "cleanup" {
        $removed = Cleanup-Cache
        Write-Host "Cleanup concluído: $removed arquivos removidos" -ForegroundColor Green
        
        $stats = Get-CacheStats
        Write-Host "Entradas restantes: $($stats.TotalEntries)" -ForegroundColor Cyan
    }
}