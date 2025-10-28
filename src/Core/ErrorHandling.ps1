# src/Core/ErrorHandling.ps1
function Invoke-Safe {
    param(
        [scriptblock]$Script,
        [string]$Context = "Unknown"
    )

    try {
        & $Script
    }
    catch {
        Write-Error "[$Context] でエラーが発生しました: $_"
        Write-Debug $_.ScriptStackTrace
        return $null
    }
}
