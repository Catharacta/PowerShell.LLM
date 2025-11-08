# src/Providers/Anthropic.ps1
# ==============================
# Anthropic (Claude) Provider
# ==============================

function Invoke-Anthropic {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,

        [string]$Model = "claude-3-opus-20240229"
    )

    try {
        # --- Load config & API key ---
        $config = $null
        if (Get-Command Get-LLMConfig -ErrorAction SilentlyContinue) {
            $config = Get-LLMConfig -Provider "anthropic"
        }

        $apiKey = $config.ApiKey
        if (-not $apiKey) {
            $apiKey = $env:ANTHROPIC_API_KEY
        }

        if (-not $apiKey) {
            throw "Anthropic API key not found. Please set `$env:ANTHROPIC_API_KEY` or use config.json."
        }

        # ✅ 呼び出しログを先頭で出す（テストでこれを検証している）
        Write-LLMLog -Level "INFO" -Message "Invoke-Anthropic called with model '$Model'"

        # --- Prepare request ---
        $uri = "https://api.anthropic.com/v1/messages"
        $headers = @{
            "x-api-key"        = $apiKey
            "content-type"     = "application/json"
            "anthropic-version" = "2023-06-01"
        }

        $body = @{
            model      = $Model
            max_tokens = 512
            messages   = @(@{ role = "user"; content = $Prompt })
        } | ConvertTo-Json -Depth 5

        Write-LLMLog -Level "INFO" -Message "Anthropic: POST $uri"

        # --- API call ---
        try {
            $response = Invoke-RestMethod -Uri $uri -Headers $headers -Body $body -Method Post -ErrorAction Stop
        }
        catch {
            Handle-LLMError -Message "Anthropic request failed" -Exception $_.Exception -Context "Anthropic"
            throw
        }

        # --- Parse response ---
        $content = $response.content[0].text
        if (-not $content) {
            throw "Invalid response from Anthropic API."
        }

        Write-LLMLog -Level "DEBUG" -Message "Anthropic response: $($content.Substring(0, [Math]::Min(80, $content.Length)))..."
        return $content
    }
    catch {
        Handle-LLMError -Message $_.Exception.Message -Exception $_.Exception -Context "Anthropic"
        throw
    }
}
