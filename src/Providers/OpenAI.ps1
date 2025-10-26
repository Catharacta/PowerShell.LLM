function Invoke-OpenAI {
    param(
        [string]$Prompt,
        [string]$Model
    )

    if (-not $env:OPENAI_API_KEY) {
        throw "環境変数 OPENAI_API_KEY が設定されていません。"
    }

    $uri = "https://api.openai.com/v1/chat/completions"
    $body = @{
        model = $Model
        messages = @(@{ role = "user"; content = $Prompt })
    } | ConvertTo-Json -Depth 4

    $headers = @{
        "Authorization" = "Bearer $env:OPENAI_API_KEY"
        "Content-Type"  = "application/json"
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post -Body $body
        return $response.choices[0].message.content
    }
    catch {
        Write-Error "OpenAI API呼び出しに失敗しました: $_"
    }
}
