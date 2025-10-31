# src/Providers/Ollama.ps1
# ===========================
# Local Ollama Provider
# ===========================

function Invoke-Ollama {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,

        [string]$Model = "llama3"
    )

    try {
        # --- Load config ---
        $config = $null
        if (Get-Command Get-LLMConfig -ErrorAction SilentlyContinue) {
            $config = Get-LLMConfig -Provider "ollama"
        }

        $apiUrl = if ($config.Url) { $config.Url } else { "http://localhost:11434/api/generate" }

        Write-LLMLog "Ollama" "POST $apiUrl" "INFO"

        # --- Build request body ---
        $body = @{
            model  = $Model
            prompt = $Prompt
            stream = $false
        } | ConvertTo-Json -Depth 5

        # --- Send request ---
        try {
            $response = Invoke-RestMethod -Uri $apiUrl -Body $body -Method Post -ContentType "application/json" -ErrorAction Stop
        }
        catch {
            Handle-LLMError -Provider "Ollama" -ErrorRecord $_
            throw
        }

        # --- Parse response ---
        if ($response.response) {
            $preview = $response.response.Substring(0, [Math]::Min(80, $response.response.Length))
            Write-LLMLog "Ollama" "Response: $preview..." "DEBUG"
            return $response.response
        }
        else {
            throw "Invalid response from Ollama API."
        }
    }
    catch {
        Handle-LLMError -Provider "Ollama" -ErrorRecord $_
        throw
    }
}
