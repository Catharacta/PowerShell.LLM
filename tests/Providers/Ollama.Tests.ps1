# tests/Providers/Ollama.Tests.ps1
Import-Module "$PSScriptRoot/../../src/PowerShell.LLM.psd1" -Force

Describe "Ollama Provider" {
    It "should have Invoke-Ollama function" {
        Get-Command Invoke-Ollama -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
    }

    It "should handle missing Ollama endpoint gracefully" {
        { Invoke-Ollama -Prompt "ping" -Model "llama3" } | Should -Throw
    }

    It "should log attempt even on failure" {
        $global:LLMLogBuffer = @()
        try { Invoke-Ollama -Prompt "test" -Model "llama3" } catch {}
        ($global:LLMLogBuffer | Out-String) | Should -Match "Ollama"
    }
}
