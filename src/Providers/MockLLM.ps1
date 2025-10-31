# src/Providers/MockLLM.ps1

function Invoke-MockLLM {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,

        [string]$Model = "mock"
    )

    try {
        Write-LLMLog "MockLLM: received prompt '$Prompt'" "INFO"

        Start-Sleep -Milliseconds 300

        $response = "🧠 Mock response for: $Prompt"
        Write-LLMLog "MockLLM: returning simulated output" "DEBUG"

        return $response
    }
    catch {
        Handle-LLMError -ErrorRecord $_ -Context "Invoke-MockLLM"
        return $null
    }
}
