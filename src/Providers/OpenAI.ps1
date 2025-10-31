# src/Providers/OpenAI.ps1

function Invoke-OpenAI {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,

        [string]$Model = "gpt-4o-mini"
    )

    try {
        # --- 設定を取得 ---
        $config = Get-LLMConfig -Provider "openai"

        $apiKey = $null

        # 優先順位: config → 環境変数
        if ($config -and $config.ApiKey) {
            $apiKey = $config.ApiKey
        } elseif ($env:OPENAI_API_KEY) {
            $apiKey = $env:OPENAI_API_KEY
        }

        if (-not $apiKey) {
            throw [System.Exception] "❌ OpenAI APIキーが見つかりません。`OPENAI_API_KEY` または設定ファイルを確認してください。"
        }

        # --- APIリクエスト準備 ---
        $uri = "https://api.openai.com/v1/chat/completions"
        $headers = @{
            "Authorization" = "Bearer $apiKey"
            "Content-Type"  = "application/json"
        }

        $body = @{
            model    = $Model
            messages = @(@{ role = "user"; content = $Prompt })
        } | ConvertTo-Json -Depth 5

        Write-LLMLog "Sending request to OpenAI ($Model)..." "INFO"

        # --- APIコール ---
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Body $body -Method Post -ErrorAction Stop

        # --- レスポンス処理 ---
        if ($response.choices) {
            $text = $response.choices[0].message.content
            Write-LLMLog "Response received: $($text.Substring(0, [Math]::Min(80, $text.Length)))..." "DEBUG"
            return $text
        } else {
            throw [System.Exception] "OpenAIからの応答が不正です。"
        }
    }
    catch {
        Handle-LLMError -ErrorRecord $_ -Context "Invoke-OpenAI"
        return $null
    }
}
