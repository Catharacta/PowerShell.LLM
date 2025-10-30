# tests/Providers/OpenAI.Tests.ps1
Import-Module "$PSScriptRoot/../../src/PowerShell.LLM.psd1" -Force

Describe "OpenAI Provider" {
    BeforeAll {
        $env:LLM_API_KEY_OPENAI = "test-key"
    }

    It "should have Invoke-OpenAI function" {
        Get-Command Invoke-OpenAI -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
    }

    It "should throw clear error if API key missing" {
        Remove-Item Env:\LLM_API_KEY_OPENAI -ErrorAction SilentlyContinue
        { Invoke-OpenAI -Prompt "hi" -Model "gpt-4o-mini" } | Should -Throw
        $env:LLM_API_KEY_OPENAI = "test-key"
    }

    It "should log message when called" {
        $global:LLMLogBuffer = @()
        try {
            Invoke-OpenAI -Prompt "test message" -Model "gpt-4o-mini"
        } catch {}
        ($global:LLMLogBuffer | Out-String) | Should -Match "Invoke-OpenAI"
    }
}
