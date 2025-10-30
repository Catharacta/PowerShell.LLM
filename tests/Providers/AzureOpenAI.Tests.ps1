# tests/Providers/AzureOpenAI.Tests.ps1
Import-Module "$PSScriptRoot/../../src/PowerShell.LLM.psd1" -Force

Describe "AzureOpenAI Provider" {
    BeforeAll {
        $env:LLM_API_KEY_AZUREOPENAI = "test-azure-key"
        $env:AZURE_OPENAI_ENDPOINT = "https://mock.azure.com"
    }

    It "should have Invoke-AzureOpenAI function" {
        Get-Command Invoke-AzureOpenAI -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
    }

    It "throws clear error if endpoint missing" {
        Remove-Item Env:\AZURE_OPENAI_ENDPOINT -ErrorAction SilentlyContinue
        { Invoke-AzureOpenAI -Prompt "hi" -Model "gpt-4" } | Should -Throw
        $env:AZURE_OPENAI_ENDPOINT = "https://mock.azure.com"
    }

    It "logs activity when executed" {
        $global:LLMLogBuffer = @()
        try { Invoke-AzureOpenAI -Prompt "hi" -Model "gpt-4" } catch {}
        ($global:LLMLogBuffer | Out-String) | Should -Match "Azure"
    }
}
