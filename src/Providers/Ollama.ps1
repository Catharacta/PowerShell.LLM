function Invoke-Ollama {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,
        [string]$Model = "llama3"
    )

    # 設定を安全に取得
    $config = $null
    if (Get-Command Get-LLMConfig -ErrorAction SilentlyContinue) {
        try {
            $config = Get-LLMConfig -Provider "ollama"
        }
        catch {
            Write-LLMLog "Ollama: failed to load config - $($_.Exception.Message)" "WARN"
        }
    }

    # ✅ Nullでも安全に動作するように
    $apiUrl = if ($config -and $config.Url) { 
        $config.Url 
    } else { 
        "http://localhost:11434/api/generate" 
    }

    # ログ出力（これがテストで検出される）
    Write-LLMLog "Ollama: attempting request to $apiUrl (model: $Model)" "INFO"

    $body = @{
        model  = $Model
        prompt = $Prompt
        stream = $false
    } | ConvertTo-Json -Depth 5

    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Body $body -Method Post -ContentType "application/json" -ErrorAction Stop

        if ($response.response) {
            $preview = $response.response.Substring(0, [Math]::Min(80, $response.response.Length))
            Write-LLMLog "Ollama: received response (preview: $preview...)" "DEBUG"
            return $response.response
        }
        else {
            throw "Ollama: Invalid response from API."
        }
    }
    catch {
        Write-LLMLog "Ollama: request failed - $($_.Exception.Message)" "ERROR"
        Handle-LLMError -ErrorRecord $_ -Context "Ollama"
        throw
    }
}
