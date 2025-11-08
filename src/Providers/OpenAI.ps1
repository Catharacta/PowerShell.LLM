# src/Providers/OpenAI.ps1
# ===============================
# OpenAI Provider
# ===============================

function Invoke-OpenAI {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,
        [string]$Model = "gpt-4o-mini"
    )

    try {
        $config = $null
        if (Get-Command Get-LLMConfig -ErrorAction SilentlyContinue) {
            $config = Get-LLMConfig -Provider "openai"
        }

        $apiKey = if ($config -and $config.ApiKey) { $config.ApiKey } elseif ($env:OPENAI_API_KEY) { $env:OPENAI_API_KEY } else { $null }
        if (-not $apiKey) {
            throw [System.Exception] "❌ OpenAI APIキーが見つかりません。`OPENAI_API_KEY` または設定ファイルを確認してください。"
        }

        $uri = "https://api.openai.com/v1/chat/completions"
        $headers = @{
            "Authorization" = "Bearer $apiKey"
            "Content-Type"  = "application/json"
        }

        $body = @{
            model    = $Model
            messages = @(@{ role = "user"; content = $Prompt })
        } | ConvertTo-Json -Depth 5

        # ✅ 位置引数形式
        Write-LLMLog "Invoke-OpenAI called (model: $Model)" "INFO"
        Write-LLMLog "OpenAI POST $uri" "INFO"

        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Body $body -Method Post -ErrorAction Stop

        if ($response.choices) {
            $text = $response.choices[0].message.content
            Write-LLMLog "Invoke-OpenAI Response: $($text.Substring(0, [Math]::Min(80, $text.Length)))..." "DEBUG"
            return $text
        } else {
            throw [System.Exception] "OpenAIからの応答が不正です。"
        }
    }
    catch {
        Handle-LLMError -ErrorRecord $_ -Context "Invoke-OpenAI"
        throw
    }
}
