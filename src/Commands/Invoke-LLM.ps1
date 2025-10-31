# ===============================================
# Invoke-LLM.ps1 - 統合 LLM 呼び出し + エラーハンドリング
# ===============================================

# --- 依存モジュールのロード確認 ---
if (-not (Get-Command Write-LLMLog -ErrorAction SilentlyContinue)) {
    Write-Warning "Logger not loaded — loading Core/Logger.ps1 manually..."
    . "$PSScriptRoot/../Core/Logger.ps1"
}
if (-not (Get-Command Handle-LLMError -ErrorAction SilentlyContinue)) {
    . "$PSScriptRoot/../Core/ErrorHandling.ps1"
}

function Invoke-LLM {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,

        [string]$Model = "gpt-4o-mini",

        [ValidateSet("openai", "ollama", "mock")]
        [string]$Provider = "openai"
    )

    Write-LLMLog -Level "INFO" -Message "Invoke-LLM started (Provider=$Provider, Model=$Model)"

    try {
        $result = switch ($Provider) {
            "openai" { Invoke-OpenAI -Prompt $Prompt -Model $Model }
            "ollama" { Invoke-Ollama -Prompt $Prompt -Model $Model }
            "mock"   { Invoke-MockLLM -Prompt $Prompt -Model $Model }
            default  { throw "Unknown provider: $Provider" }
        }

        Write-LLMLog -Level "INFO" -Message "✅ LLM call successful"
        return $result
    }
    catch {
        # 例外を共通ハンドラで処理
        Handle-LLMError -ErrorRecord $_ -Context "Invoke-LLM"
        return $null
    }
}
