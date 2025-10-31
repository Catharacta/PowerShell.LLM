# src/Commands/Test-LLMConnection.ps1
using module ../Core/Logger.ps1
using module ../Core/Config.ps1

function Test-LLMConnection {
    [CmdletBinding()]
    param(
        [string]$Provider = "OpenAI"
    )

    Write-LLMLog -Message "Testing LLM connection for provider: $Provider" -Level "Info"

    try {
        $config = Get-LLMConfig -Provider $Provider
        $apiKey = $config.ApiKey
        if (-not $apiKey) { throw "APIキーが取得できません。" }

        switch ($Provider.ToLower()) {
            "openai" {
                $uri = "https://api.openai.com/v1/models"
                $headers = @{ "Authorization" = "Bearer $apiKey" }
                $null = Invoke-RestMethod -Uri $uri -Headers $headers -ErrorAction Stop
            }
            "ollama" {
                $uri = "http://localhost:11434/api/tags"
                $null = Invoke-RestMethod -Uri $uri -ErrorAction Stop
            }
            default {
                throw "未対応のプロバイダ: $Provider"
            }
        }

        Write-Host "✅ $Provider に正常に接続できました。" -ForegroundColor Green
        Write-LLMLog -Message "$Provider connection test passed." -Level "Info"
        return $true
    }
    catch {
        Write-Host "❌ $Provider への接続に失敗しました。" -ForegroundColor Red
        Write-LLMLog -Message "$Provider connection test failed: $($_.Exception.Message)" -Level "Error"
        return $false
    }
    finally {
        Flush-LLMLogs
    }
}
