# tests/Providers/MockLLM.Tests.ps1
Import-Module "$PSScriptRoot/../../src/PowerShell.LLM.psd1" -Force

Describe "MockLLM Provider" {
    It "should have Invoke-MockLLM function" {
        Get-Command Invoke-MockLLM -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
    }

    It "should return mock response" {
        $result = Invoke-MockLLM -Prompt "hello" -Model "mock-model"
        $result | Should -Match "mock"
    }

    It "should write debug log" {
        $global:LLMLogBuffer = @()
        Invoke-MockLLM -Prompt "testing" -Model "mock-model"
        ($global:LLMLogBuffer | Out-String) | Should -Match "MockLLM"
    }
}
