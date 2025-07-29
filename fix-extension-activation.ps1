# Script para corrigir eventos de ativacao desnecessarios em extensoes
param(
    [switch]$DryRun = $false
)

Write-Host "Corrigindo eventos de ativacao em extensoes..." -ForegroundColor Cyan

$extensionsPath = "$env:USERPROFILE\.kiro\extensions"
$fixedCount = 0

# Lista de problemas identificados
$problemExtensions = @(
    "$extensionsPath\prisma.prisma-6.7.0-universal\package.json",
    "$extensionsPath\ckolkman.vscode-postgres-1.4.3-universal\package.json",
    "$extensionsPath\msjsdiag.vscode-react-native-1.13.0-universal\package.json",
    "$extensionsPath\redhat.vscode-yaml-1.18.0-universal\package.json"
)

function Fix-PackageJson {
    param($filePath)
    
    if (-not (Test-Path $filePath)) {
        Write-Warning "Arquivo nao encontrado: $filePath"
        return $false
    }
    
    try {
        $content = Get-Content $filePath -Raw | ConvertFrom-Json
        $modified = $false
        
        # Verificar se tem activationEvents
        if ($content.activationEvents) {
            $originalEvents = $content.activationEvents
            $newEvents = @()
            
            # Filtrar eventos desnecessarios
            foreach ($event in $originalEvents) {
                # Manter apenas eventos essenciais
                if ($event -eq "onStartupFinished" -or $event -match "^onView:") {
                    $newEvents += $event
                }
            }
            
            # Se removemos eventos, atualizar
            if ($newEvents.Count -lt $originalEvents.Count) {
                if ($newEvents.Count -eq 0) {
                    # Remover completamente se vazio
                    $content.PSObject.Properties.Remove('activationEvents')
                } else {
                    $content.activationEvents = $newEvents
                }
                $modified = $true
            }
        }
        
        if ($modified -and -not $DryRun) {
            $content | ConvertTo-Json -Depth 10 | Set-Content $filePath -Encoding UTF8
            Write-Host "Corrigido: $(Split-Path $filePath -Leaf)" -ForegroundColor Green
            return $true
        } elseif ($modified -and $DryRun) {
            Write-Host "Seria corrigido: $(Split-Path $filePath -Leaf)" -ForegroundColor Yellow
            return $true
        }
        
    } catch {
        Write-Error "Erro ao processar $filePath : $_"
        return $false
    }
    
    return $false
}

# Processar cada extensao problematica
foreach ($extensionPath in $problemExtensions) {
    if (Fix-PackageJson $extensionPath) {
        $fixedCount++
    }
}

Write-Host ""
Write-Host "Resumo:" -ForegroundColor Cyan
Write-Host "   Extensoes processadas: $($problemExtensions.Count)"
Write-Host "   Correcoes aplicadas: $fixedCount"

if ($DryRun) {
    Write-Host ""
    Write-Host "Execute sem -DryRun para aplicar as correcoes" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "Correcoes concluidas! Reinicie o Kiro para aplicar as mudancas." -ForegroundColor Green
}