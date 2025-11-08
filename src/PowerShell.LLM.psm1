# ===============================
# PowerShell.LLM.psm1
# ===============================

# --- Load Core modules ---
Get-ChildItem -Path (Join-Path $PSScriptRoot "Core") -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# --- Load Providers ---
Get-ChildItem -Path (Join-Path $PSScriptRoot "Providers") -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# --- Load Commands ---
Get-ChildItem -Path (Join-Path $PSScriptRoot "Commands") -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# ===============================
# === 自動エクスポート設定 ===
# ===============================

# 環境変数で「開発モード」を切り替え可能
#   $env:PSLLM_DEV = "1" のときは内部関数も公開
$devMode = $env:PSLLM_DEV -eq "1"

# すべての関数を取得
$allFunctions = (Get-Command -Module $ExecutionContext.SessionState.Module) |
    Where-Object { $_.CommandType -eq 'Function' } |
    Select-Object -ExpandProperty Name

# 内部関数（_で始まる）をフィルタリング
if ($devMode) {
    Write-Verbose "🔧 Development mode: exporting ALL functions (including internal)"
    $exportFunctions = $allFunctions
} else {
    $exportFunctions = $allFunctions | Where-Object { $_ -notmatch '^_' }
}

# 公開
Export-ModuleMember -Function $exportFunctions

# ===============================
# === ロード完了メッセージ ===
# ===============================
if ($devMode) {
    Write-Host "✅ PowerShell.LLM module loaded in DEV MODE (internal functions visible)"
} else {
    Write-Verbose "✅ PowerShell.LLM module loaded"
}
