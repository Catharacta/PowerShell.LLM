function Invoke-MockLLM {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,

        [string]$Model = "mock-model"
    )

    Write-Verbose "Mock LLM called with model: $Model"

    return "Mock response (model: $Model): You said '$Prompt'"
}

Export-ModuleMember -Function Invoke-MockLLM