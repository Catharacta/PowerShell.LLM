# tests/Core/Logger.Tests.ps1
Import-Module "$PSScriptRoot/../../src/PowerShell.LLM.psd1" -Force

Describe "Logger.ps1" {
    BeforeEach {
        $global:LLMLogLevel = "INFO"
        $global:LLMLogBuffer = @()
    }

    It "writes logs to buffer" {
        Write-LLMLog -Level "INFO" -Message "test message"
        $global:LLMLogBuffer | Should -Not -BeNullOrEmpty
        $global:LLMLogBuffer[-1] | Should -Match "test message"
    }

    It "respects log level filtering" {
        $global:LLMLogLevel = "ERROR"
        Write-LLMLog -Level "DEBUG" -Message "should be skipped"
        ($global:LLMLogBuffer | Where-Object { $_ -match "skipped" }) | Should -BeNullOrEmpty
    }

    It "saves logs to session cache" {
        Write-LLMLog -Level "INFO" -Message "session test"
        $global:LLMLogBuffer[-1] | Should -Match "session test"
    }
}
