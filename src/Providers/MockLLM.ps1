# src/Providers/MockLLM.ps1
# ==============================
# Mock LLM Provider (for testing)
# ==============================

function Invoke-MockLLM {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,

        [string]$Model = "mock"
    )

    try {
        # ✅ 呼び出し検出ログ（テストがこのINFOログを探す）
        Write-LLMLog -Message "Invoke-MockLLM called with model '$Model'" -Level "INFO"

        # ✅ プロンプトを受け取ったログ
        Write-LLMLog -Message "MockLLM: received prompt '$Prompt'" -Level "INFO"

        # 模擬的な処理
        Start-Sleep -Milliseconds 300

        $response = "🧠 Mock response for: $Prompt"

        # ✅ 出力を返すログ
        Write-LLMLog -Message "MockLLM: returning simulated output" -Level "DEBUG"

        return $response
    }
    catch {
        Handle-LLMError -ErrorRecord $_ -Context "Invoke-MockLLM"
        return $null
    }
}
