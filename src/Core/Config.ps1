# src/Core/Config.ps1
function Get-LLMConfig {
    param(
        [string]$Provider = "openai"
    )

    $configPath = Join-Path $HOME ".config/PowerShell.LLM/config.json"

    if (Test-Path $configPath) {
        $json = Get-Content $configPath -Raw | ConvertFrom-Json
        return $json.$Provider
    }

    # Fallback to environment variable
    $envVar = "LLM_API_KEY_$($Provider.ToUpper())"
    if ($env:$envVar) {
        return @{ ApiKey = $env:$envVar }
    }

    throw "❌ APIキーが設定されていません。`$env:$envVar` または $configPath を確認してください。"
}
