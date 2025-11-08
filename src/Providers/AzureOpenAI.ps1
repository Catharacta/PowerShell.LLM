# src/Providers/AzureOpenAI.ps1
# ==============================
# Azure OpenAI Provider
# ==============================

function Invoke-AzureOpenAI {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,

        [string]$Model = "gpt-4o-mini"
    )

    try {
        # --- Load config & env settings ---
        $config = $null
        if (Get-Command Get-LLMConfig -ErrorAction SilentlyContinue) {
            $config = Get-LLMConfig -Provider "azureopenai"
        }

        $apiKey = $config.ApiKey
        if (-not $apiKey) {
            $apiKey = $env:LLM_API_KEY_AZUREOPENAI
        }

        if (-not $apiKey) {
            throw "Azure OpenAI API key not found. Please set `$env:LLM_API_KEY_AZUREOPENAI` or config.json."
        }

        $endpoint = $env:AZURE_OPENAI_ENDPOINT
        if (-not $endpoint) {
            throw "Azure OpenAI endpoint not set. Please set `$env:AZURE_OPENAI_ENDPOINT`."
        }

        # --- Construct API URL ---
        $url = "$endpoint/openai/deployments/$Model/chat/completions?api-version=2024-02-01"

        # ✅ 呼び出しログ（テストがこれを検証している）
        Write-LLMLog -Level "INFO" -Message "Invoke-AzureOpenAI called with model '$Model'"

        # --- Prepare request body ---
        $body = @{
            messages = @(
                @{ role = "user"; content = $Prompt }
            )
            max_tokens = 256
        } | ConvertTo-Json -Depth 5

        # --- Headers ---
        $headers = @{
            "api-key"      = $apiKey
            "Content-Type" = "application/json"
        }

        Write-LLMLog -Level "INFO" -Message "AzureOpenAI: POST $url"

        # --- API Call ---
        try {
            $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body -ErrorAction Stop
        }
        catch {
            Handle-LLMError -Message "AzureOpenAI request failed" -Exception $_.Exception -Context "AzureOpenAI"
            throw
        }

        # --- Extract result ---
        $content = $response.choices[0].message.content
        if (-not $content) {
            $content = ($response | ConvertTo-Json -Depth 5)
        }

        Write-LLMLog -Level "DEBUG" -Message "AzureOpenAI response: $($content.Substring(0, [Math]::Min(80, $content.Length)))..."
        return $content
    }
    catch {
        Handle-LLMError -Message $_.Exception.Message -Exception $_.Exception -Context "AzureOpenAI"
        throw
    }
}
