function Invoke-OpenAI {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,
        [string]$Model = "gpt-4o-mini"
    )

    Write-LLMLog "Invoke-OpenAI called (model: $Model)" "INFO"

    try {
        $config = if (Get-Command Get-LLMConfig -ErrorAction SilentlyContinue) {
            Get-LLMConfig -Provider "openai"
        }

        $apiKey = $config?.ApiKey ?? $env:OPENAI_API_KEY
        if (-not $apiKey) {
            throw "❌ OpenAI APIキーが見つかりません。`OPENAI_API_KEY` または設定ファイルを確認してください。"
        }

        $uri = if ($config.Url) { $config.Url } else { "https://api.openai.com/v1/chat/completions" }

        $headers = @{
            "Authorization" = "Bearer $apiKey"
            "Content-Type"  = "application/json"
        }

        $body = @{
            model    = $Model
            messages = @(@{ role = "user"; content = $Prompt })
            stream   = $false
        } | ConvertTo-Json -Depth 5

        Write-LLMLog "OpenAI POST $uri" "DEBUG"

        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Body $body -Method Post -ErrorAction Stop

        if ($response.choices -and $response.choices[0].message.content) {
            $text = $response.choices[0].message.content
            Write-LLMLog "Invoke-OpenAI Response: $($text.Substring(0, [Math]::Min(80, $text.Length)))..." "DEBUG"
            return $text
        } else {
            throw "❌ OpenAI API応答にcontentが含まれていません。"
        }
    }
    catch {
        Handle-LLMError -ErrorRecord $_ -Context "Invoke-OpenAI"
        throw
    }
}
