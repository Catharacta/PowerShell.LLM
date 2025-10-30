# tests/Core/Config.Tests.ps1
Import-Module "$PSScriptRoot/../../src/PowerShell.LLM.psd1" -Force

Describe "Get-LLMConfig" {
    BeforeAll {
        $configDir = Join-Path $HOME ".config/PowerShell.LLM"
        $configPath = Join-Path $configDir "config.json"
        New-Item -ItemType Directory -Force -Path $configDir | Out-Null
    }

    It "returns provider config from file" {
        $json = @{ openai = @{ ApiKey = "file-key" } } | ConvertTo-Json
        $configPath = Join-Path $HOME ".config/PowerShell.LLM/config.json"
        $json | Out-File -FilePath $configPath -Encoding utf8

        $result = Get-LLMConfig -Provider "openai"
        $result.ApiKey | Should -Be "file-key"
    }

    It "returns config from environment variable if file missing" {
        $configPath = Join-Path $HOME ".config/PowerShell.LLM/config.json"
        Remove-Item $configPath -Force -ErrorAction SilentlyContinue

        $env:LLM_API_KEY_OPENAI = "env-key"
        $result = Get-LLMConfig -Provider "openai"
        $result.ApiKey | Should -Be "env-key"
    }

    It "throws when no config found" {
        $configPath = Join-Path $HOME ".config/PowerShell.LLM/config.json"
        Remove-Item $configPath -Force -ErrorAction SilentlyContinue
        Remove-Item Env:\LLM_API_KEY_OPENAI -ErrorAction SilentlyContinue

        { Get-LLMConfig -Provider "openai" } | Should -Throw
    }
}
