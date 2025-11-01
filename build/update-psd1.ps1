<#
.SYNOPSIS
  PowerShell.LLM.psd1 の FunctionsToExport を自動更新または検証します。

.DESCRIPTION
  src/ 以下の *.ps1 ファイルから関数を自動検出して、
  モジュールマニフェスト（.psd1）の FunctionsToExport を更新します。

  - 実行例:
    ./build/update-psd1.ps1
        → FunctionsToExport を自動更新し、変更を保存します。

    ./build/update-psd1.ps1 -CheckOnly
        → FunctionsToExport の差分を検出するだけ（CIでの検証用）。

.PARAMETER ModuleRoot
  モジュールのソースディレクトリ。デフォルトは ../src。

.PARAMETER ManifestPath
  更新対象の PSD1 ファイルパス。デフォルトは ../src/PowerShell.LLM.psd1。

.PARAMETER CheckOnly
  差分を検出するだけで書き換えは行わない（CI 用）。
#>

param(
    [string]$ModuleRoot = "$PSScriptRoot/../src",
    [string]$ManifestPath = "$PSScriptRoot/../src/PowerShell.LLM.psd1",
    [switch]$CheckOnly
)

Write-Host "🔍 Scanning PowerShell scripts for exported functions..." -ForegroundColor Cyan

# --- 1️⃣ 関数を自動収集 ---------------------------------------------------
$functionNames = @()

# 各 .ps1 ファイルから関数定義を抽出
Get-ChildItem -Path $ModuleRoot -Recurse -Filter '*.ps1' | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match 'function\s+([A-Za-z0-9\-_]+)') {
        $matches = [regex]::Matches($content, 'function\s+([A-Za-z0-9\-_]+)')
        foreach ($m in $matches) {
            $name = $m.Groups[1].Value
            # "_" で始まる関数は非公開扱い
            if ($name -notmatch '^_') {
                $functionNames += $name
            }
        }
    }
}

$functionNames = $functionNames | Sort-Object -Unique

Write-Host "✅ Found $($functionNames.Count) public functions."

# --- 2️⃣ 現在の psd1 の FunctionsToExport を取得 --------------------------
if (-not (Test-Path $ManifestPath)) {
    throw "❌ Manifest file not found: $ManifestPath"
}

$psd1Content = Get-Content -Raw -Path $ManifestPath
$manifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop
$currentExports = $manifest.FunctionsToExport

# --- 3️⃣ 差分を比較 -------------------------------------------------------
$added   = $functionNames | Where-Object { $_ -notin $currentExports }
$removed = $currentExports | Where-Object { $_ -notin $functionNames }

if ($CheckOnly) {
    if ($added.Count -eq 0 -and $removed.Count -eq 0) {
        Write-Host "✅ No changes detected in FunctionsToExport." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "⚠️  FunctionsToExport mismatch detected!" -ForegroundColor Yellow
        if ($added)   { Write-Host "  ➕ Added   : $($added -join ', ')" }
        if ($removed) { Write-Host "  ➖ Removed : $($removed -join ', ')" }
        Write-Host "`n💡 Run './build/update-psd1.ps1' to auto-fix this." -ForegroundColor Cyan
        exit 1
    }
}

# --- 4️⃣ psd1 を更新 --------------------------------------------------------
Write-Host "📝 Updating $ManifestPath..." -ForegroundColor Cyan

# FunctionsToExport = @() 部分を置換
$newList = "@(" + ($functionNames | ForEach-Object { "`n    '$_'" }) -join "" + "`n)"
$pattern = "(?ms)(FunctionsToExport\s*=\s*)@\(.*?\)"
$replacement = "`$1$newList"

$newContent = [regex]::Replace($psd1Content, $pattern, $replacement)

# バックアップ作成
Copy-Item $ManifestPath "$ManifestPath.bak" -Force
Set-Content -Path $ManifestPath -Value $newContent -Encoding UTF8

Write-Host "✅ FunctionsToExport updated successfully." -ForegroundColor Green
