# src/Core/Config.ps1
function Get-LLMConfig {
    param(
        [string]$Provider = "openai"
    )

    # 設定ファイルのパス
    $configPath = Join-Path $HOME ".config/PowerShell.LLM/config.json"

    # === 設定ファイルがある場合 ===
    if (Test-Path $configPath) {
        try {
            $json = Get-Content $configPath -Raw | ConvertFrom-Json
            if ($json.$Provider) {
                return $json.$Provider
            }
        }
        catch {
            Write-Warning "⚠️ 設定ファイルの読み込みに失敗しました: $_"
        }
    }

    # === 環境変数のフォールバック ===
    # 環境変数名例: LLM_API_KEY_OPENAI
    $envVarName = "LLM_API_KEY_$($Provider.ToUpper())"
    $apiKey = [Environment]::GetEnvironmentVariable($envVarName, "Process") `
           ?? [Environment]::GetEnvironmentVariable($envVarName, "User") `
           ?? [Environment]::GetEnvironmentVariable($envVarName, "Machine")

    if ($apiKey) {
        return @{ ApiKey = $apiKey }
    }

    throw "❌ APIキーが設定されていません。環境変数 `$envVarName` または設定ファイル $configPath を確認してください。"
}
