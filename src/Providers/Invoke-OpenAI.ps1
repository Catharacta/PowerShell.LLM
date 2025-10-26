function Invoke-OpenAI {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,

        [string]$Model = "gpt-4o-mini",

        [string]$ApiKey = $env:OPENAI_API_KEY,

        [string]$Endpoint = "https://api.openai.com/v1/chat/completions"
    )

    if (-not $ApiKey) {
        throw "OPENAI_API_KEY environment variable not set."
    }

    Write-Verbose "Calling OpenAI API with model: $Model"

    $body = @{
        model = $Model
        messages = @(
            @{ role = "user"; content = $Prompt }
        )
    } | ConvertTo-Json -Depth 5

    try {
        $response = Invoke-RestMethod -Uri $Endpoint `
                                      -Headers @{ "Authorization" = "Bearer $ApiKey" } `
                                      -ContentType "application/json" `
                                      -Method POST `
                                      -Body $body

        return $response.choices[0].message.content
    }
    catch {
        throw "OpenAI request failed: $_"
    }
}

Export-ModuleMember -Function Invoke-OpenAI
