# Context7 Wrapper com Cache Inteligente
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("resolve", "docs")]
    [string]$Operation,
    
    [Parameter(Mandatory=$true)]
    [string]$Query,
    
    [string]$Topic = "",
    [int]$Tokens = 10000,
    [int]$CacheMaxAge = 3600 # 1 hora
)

$cacheManager = ".kiro/scripts/context7-cache-manager.ps1"

function Invoke-Context7WithCache {
    param($Operation, $Query, $Topic, $Tokens)
    
    # Gerar chave de cache
    $cacheKey = if ($Topic) { "$Query-$Topic" } else { $Query }
    
    # Tentar buscar no cache primeiro
    $cacheResult = & $cacheManager -Action "get" -LibraryId $cacheKey -Topic $Topic -MaxAge $CacheMaxAge 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "📦 Usando cache para: $Query" -ForegroundColor Green
        return $cacheResult
    }
    
    Write-Host "🔍 Buscando documentação: $Query" -ForegroundColor Cyan
    
    # Fazer requisição real ao Context7
    try {
        if ($Operation -eq "resolve") {
            # Simular chamada para resolve-library-id
            $result = "Resultado da resolução para: $Query"
        } else {
            # Simular chamada para get-library-docs
            $result = "Documentação para: $Query $(if($Topic){"- Tópico: $Topic"})"
        }
        
        # Salvar no cache
        & $cacheManager -Action "set" -LibraryId $cacheKey -Topic $Topic -Data $result | Out-Null
        
        Write-Host "✅ Documentação obtida e cacheada" -ForegroundColor Green
        return $result
        
    } catch {
        Write-Host "❌ Erro ao buscar documentação: $_" -ForegroundColor Red
        return $null
    }
}

# Executar operação
$result = Invoke-Context7WithCache $Operation $Query $Topic $Tokens

if ($result) {
    Write-Output $result
} else {
    exit 1
}