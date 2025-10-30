# tests/Core/ErrorHandling.Tests.ps1
Import-Module "$PSScriptRoot/../../src/PowerShell.LLM.psd1" -Force

Describe "ErrorHandling.ps1" {
    BeforeEach {
        $global:LLMLogBuffer = @()
    }

    It "creates structured error object" {
        $err = Handle-LLMError -Message "Bad Request" -Code 400
        $err | Should -Not -BeNullOrEmpty
        $err.Message | Should -Be "Bad Request"
        $err.Code | Should -Be 400
        $err.Status | Should -Be "Error"
    }

    It "logs the error when handled" {
        Handle-LLMError -Message "Test log" -Code 500
        $global:LLMLogBuffer[-1] | Should -Match "Test log"
    }
}
