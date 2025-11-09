# src/Core/Config.ps1
# ==========================
# LLM Configuration Management
# ==========================

# 共通パスをスクリプトスコープで定義
if (-not $Script:LLMConfigPath) {
    $Script:LLMConfigPath = Join-Path $HOME ".config/PowerShell.LLM/config.json"
}

function Get-LLMConfig {
    [CmdletBinding()]
    param(
        [string]$Provider = "openai"
    )

    # === 設定ファイル読み込み ===
    if (Test-Path $Script:LLMConfigPath) {
        try {
            $json = Get-Content $Script:LLMConfigPath -Raw | ConvertFrom-Json
            if ($json.$Provider) {
                Write-LLMLog "Loaded config for provider '$Provider' from $Script:LLMConfigPath" "DEBUG"
                return $json.$Provider
            }
        }
        catch {
            Write-LLMLog "Failed to read config file: $($_.Exception.Message)" "WARN"
        }
    }

    # === 環境変数フォールバック ===
    $envVarName = "LLM_API_KEY_$($Provider.ToUpper())"
    $apiKey = [Environment]::GetEnvironmentVariable($envVarName, "Process") `
           ?? [Environment]::GetEnvironmentVariable($envVarName, "User") `
           ?? [Environment]::GetEnvironmentVariable($envVarName, "Machine")

    if ($apiKey) {
        Write-LLMLog "Using API key from environment variable '$envVarName'." "DEBUG"
        return @{ api_key = $apiKey }
    }

    Write-LLMLog "API key not found for provider '$Provider'." "ERROR"
    throw "❌ APIキーが設定されていません。環境変数 '$envVarName' または設定ファイル $Script:LLMConfigPath を確認してください。"
}

function Set-LLMConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Provider,
        [string]$ApiKey,
        [string]$Url,
        [string]$Model
    )

    $dir = Split-Path $Script:LLMConfigPath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }

    $config = @{}
    if (Test-Path $Script:LLMConfigPath) {
        try {
            $config = Get-Content $Script:LLMConfigPath -Raw | ConvertFrom-Json
        } catch {
            Write-LLMLog "Existing config parse failed. Creating new config file." "WARN"
        }
    }

    if (-not $config.$Provider) {
        $config | Add-Member -NotePropertyName $Provider -NotePropertyValue @{}
    }

    if ($ApiKey) { $config.$Provider.api_key = $ApiKey }
    if ($Url)    { $config.$Provider.url     = $Url }
    if ($Model)  { $config.$Provider.model   = $Model }

    try {
        $config | ConvertTo-Json -Depth 5 | Out-File $Script:LLMConfigPath -Encoding utf8
        Write-LLMLog "Configuration saved for provider '$Provider'." "INFO"
    }
    catch {
        Write-LLMLog "Failed to write config: $($_.Exception.Message)" "ERROR"
        throw
    }
}
