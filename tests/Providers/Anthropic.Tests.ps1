# tests/Providers/Anthropic.Tests.ps1
Import-Module "$PSScriptRoot/../../src/PowerShell.LLM.psd1" -Force

Describe "Anthropic Provider" {
    BeforeAll {
        $env:LLM_API_KEY_ANTHROPIC = "mock-key"
    }

    It "should have Invoke-Anthropic function" {
        Get-Command Invoke-Anthropic -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
    }

    It "should throw if no API key" {
        Remove-Item Env:\LLM_API_KEY_ANTHROPIC -ErrorAction SilentlyContinue
        { Invoke-Anthropic -Prompt "Hello" -Model "claude-3" } | Should -Throw
        $env:LLM_API_KEY_ANTHROPIC = "mock-key"
    }

    It "should log invocation" {
        $global:LLMLogBuffer = @()
        try { Invoke-Anthropic -Prompt "Ping" -Model "claude-3" } catch {}
        ($global:LLMLogBuffer | Out-String) | Should -Match "Anthropic"
    }
}
