<#
.SYNOPSIS
  PowerShell.LLM.psd1 の FunctionsToExport / CmdletsToExport を自動更新または検証します。

.DESCRIPTION
  src/ 以下の *.ps1 ファイルから関数・エクスポート候補を自動検出して、
  モジュールマニフェスト（.psd1）の FunctionsToExport / CmdletsToExport を更新します。

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

Write-Host "🔍 Scanning PowerShell scripts for exports..." -ForegroundColor Cyan

# --- 1️⃣ 関数とCmdletの自動収集 ------------------------------------------
$functions = @()
$cmdlets   = @()
$aliases   = @()

Get-ChildItem -Path $ModuleRoot -Recurse -Filter '*.ps1' | ForEach-Object {
    try {
        $content = Get-Content $_.FullName -Raw -ErrorAction Stop
    } catch {
        Write-Warning "⚠️  Failed to read file: $($_.FullName). Skipping."
        return
    }

    if (-not $content) {
        Write-Verbose "Skipping empty file: $($_.FullName)"
        return
    }

    # 関数定義を検出
    $funcMatches = [regex]::Matches($content, '(?im)^\s*function\s+([A-Za-z0-9\-_]+)')
    foreach ($m in $funcMatches) {
        $name = $m.Groups[1].Value
        if ($name -notmatch '^_') {
            $functions += $name
        }
    }

    # CmdletBinding を持つ関数を Cmdlets 扱い
    $cmdletMatches = [regex]::Matches($content, '(?im)^\s*function\s+([A-Za-z0-9\-_]+)\s*\{[^\}]*?\[CmdletBinding\(')
    foreach ($m in $cmdletMatches) {
        $name = $m.Groups[1].Value
        if ($name -notmatch '^_') {
            $cmdlets += $name
        }
    }

    # Alias 定義
    $aliasMatches = [regex]::Matches($content, '(?im)Set-Alias\s+([A-Za-z0-9\-_]+)')
    foreach ($m in $aliasMatches) {
        $aliases += $m.Groups[1].Value
    }
}

$functions = $functions | Sort-Object -Unique
$cmdlets   = $cmdlets   | Sort-Object -Unique
$aliases   = $aliases   | Sort-Object -Unique

Write-Host "✅ Found $($functions.Count) functions, $($cmdlets.Count) cmdlets, $($aliases.Count) aliases." -ForegroundColor Green

# --- 2️⃣ psd1 のロード -----------------------------------------------------
if (-not (Test-Path $ManifestPath)) {
    throw "❌ Manifest file not found: $ManifestPath"
}

$psd1Content = Get-Content -Raw -Path $ManifestPath
$manifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop

$currentFunc = @($manifest.FunctionsToExport)
$currentCmds = @($manifest.CmdletsToExport)
$currentAli  = @($manifest.AliasesToExport)

# --- 3️⃣ 差分チェック -------------------------------------------------------
$addedFunc = $functions | Where-Object { $_ -notin $currentFunc }
$removedFunc = $currentFunc | Where-Object { $_ -notin $functions }

$addedCmds = $cmdlets | Where-Object { $_ -notin $currentCmds }
$removedCmds = $currentCmds | Where-Object { $_ -notin $cmdlets }

if ($CheckOnly) {
    if ($addedFunc.Count -eq 0 -and $removedFunc.Count -eq 0 -and
        $addedCmds.Count -eq 0 -and $removedCmds.Count -eq 0) {
        Write-Host "✅ No changes detected in manifest exports." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "⚠️  Export definitions mismatch detected!" -ForegroundColor Yellow
        if ($addedFunc) { Write-Host "  ➕ [FunctionsToExport] Added   : $($addedFunc -join ', ')" }
        if ($removedFunc) { Write-Host "  ➖ [FunctionsToExport] Removed : $($removedFunc -join ', ')" }
        if ($addedCmds) { Write-Host "  ➕ [CmdletsToExport] Added   : $($addedCmds -join ', ')" }
        if ($removedCmds) { Write-Host "  ➖ [CmdletsToExport] Removed : $($removedCmds -join ', ')" }
        Write-Host "`n💡 Run './build/update-psd1.ps1' to auto-fix this." -ForegroundColor Cyan
        exit 1
    }
}

# --- 4️⃣ psd1 更新処理 -----------------------------------------------------
Write-Host "📝 Updating $ManifestPath..." -ForegroundColor Cyan

function Replace-ExportBlock {
    param($content, $key, $values)
    $newList = "@(" + ($values | ForEach-Object { "`n    '$_'" }) -join "" 
    $newList += "`n)"
    $pattern = "(?ms)($key\s*=\s*)@\(.*?\)"
    return [regex]::Replace($content, $pattern, "`$1$newList")
}

$newContent = $psd1Content
$newContent = Replace-ExportBlock $newContent 'FunctionsToExport' $functions
$newContent = Replace-ExportBlock $newContent 'CmdletsToExport' $cmdlets
$newContent = Replace-ExportBlock $newContent 'AliasesToExport' $aliases

# バックアップ作成
Copy-Item $ManifestPath "$ManifestPath.bak" -Force
Set-Content -Path $ManifestPath -Value $newContent -Encoding UTF8

Write-Host "✅ Manifest updated successfully." -ForegroundColor Green
