function Invoke-Ollama {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,

        [string]$Model = "llama3",

        [string]$Endpoint = "http://localhost:11434/api/generate"
    )

    Write-Verbose "Calling Ollama with model: $Model"

    $body = @{
        model = $Model
        prompt = $Prompt
    } | ConvertTo-Json -Depth 3

    try {
        $response = Invoke-RestMethod -Uri $Endpoint `
                                      -Method POST `
                                      -ContentType "application/json" `
                                      -Body $body

        # Ollamaはstreamを返す場合があるため、結果処理を調整
        if ($response.response) {
            return $response.response
        } elseif ($response.output) {
            return ($response.output | ForEach-Object { $_.response }) -join ""
        } else {
            return $response
        }
    }
    catch {
        throw "Ollama request failed: $_"
    }
}

Export-ModuleMember -Function Invoke-Ollama
