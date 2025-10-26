function Invoke-Ollama {
    param(
        [string]$Prompt,
        [string]$Model = "llama3"
    )

    $uri = "http://localhost:11434/api/generate"
    $body = @{ model = $Model; prompt = $Prompt } | ConvertTo-Json

    try {
        $response = Invoke-RestMethod -Uri $uri -Method Post -Body $body -ContentType "application/json"
        return $response.response
    }
    catch {
        Write-Error "Ollama呼び出しに失敗しました: $_"
    }
}
