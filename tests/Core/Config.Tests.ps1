# tests/Core/Config.Tests.ps1
Import-Module "$PSScriptRoot/../../src/PowerShell.LLM.psd1" -Force

Describe "Config.ps1" {
    BeforeAll {
        # ✅ 一時ディレクトリを利用（実環境に干渉しない）
        $TestConfigDir = Join-Path $env:TEMP "LLMTestConfig"
        $TestConfigPath = Join-Path $TestConfigDir "config.json"

        if (-not (Test-Path $TestConfigDir)) {
            New-Item -ItemType Directory -Force -Path $TestConfigDir | Out-Null
        }

        # ✅ モジュールのスクリプトスコープに変数を上書きする
        $module = Get-Module PowerShell.LLM
        if ($module) {
            $setScript = {
                param($path)
                $Script:LLMConfigPath = $path
            }
            & $module $setScript $TestConfigPath
        }

        Remove-Item $TestConfigPath -Force -ErrorAction SilentlyContinue
    }

    Context "Get-LLMConfig" {
        It "returns provider config from file" {
            $json = @{ openai = @{ api_key = "file-key" } } | ConvertTo-Json -Depth 3
            $json | Out-File -FilePath $TestConfigPath -Encoding utf8

            $result = Get-LLMConfig -Provider "openai"
            $result.api_key | Should -Be "file-key"
        }

        It "returns config from environment variable if file missing" {
            Remove-Item $TestConfigPath -Force -ErrorAction SilentlyContinue
            $env:LLM_API_KEY_OPENAI = "env-key"

            $result = Get-LLMConfig -Provider "openai"
            $result.api_key | Should -Be "env-key"
        }

        It "throws when no config found" {
            Remove-Item $TestConfigPath -Force -ErrorAction SilentlyContinue
            Remove-Item Env:\LLM_API_KEY_OPENAI -ErrorAction SilentlyContinue

            { Get-LLMConfig -Provider "openai" } | Should -Throw
        }
    }

    Context "Set-LLMConfig" {
        It "writes configuration to file" {
            Remove-Item $TestConfigPath -Force -ErrorAction SilentlyContinue

            Set-LLMConfig -Provider "openai" -ApiKey "test-key" -Url "http://example.com" -Model "gpt-test"

            Test-Path $TestConfigPath | Should -BeTrue

            $json = Get-Content $TestConfigPath -Raw | ConvertFrom-Json
            $json.openai.api_key | Should -Be "test-key"
            $json.openai.url | Should -Be "http://example.com"
            $json.openai.model | Should -Be "gpt-test"
        }

        It "overwrites existing provider config" {
            Set-LLMConfig -Provider "openai" -ApiKey "key1"
            Set-LLMConfig -Provider "openai" -ApiKey "key2"

            $json = Get-Content $TestConfigPath -Raw | ConvertFrom-Json
            $json.openai.api_key | Should -Be "key2"
        }
    }

    AfterAll {
        Remove-Item $TestConfigDir -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item Env:\LLM_API_KEY_OPENAI -ErrorAction SilentlyContinue
    }
}
