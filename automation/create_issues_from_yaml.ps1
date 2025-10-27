<#
.SYNOPSIS
  指定したフェーズのYAMLファイルからGitHub Issueとラベルを自動作成します。
.EXAMPLE
  ./automation/create_labels_and_issues.ps1 -Phase 2 -Repo "Catharacta/PowerShell.LLM"
#>

param(
    [Parameter(Mandatory)]
    [int]$Phase,

    [Parameter(Mandatory)]
    [string]$Repo
)

# --- GitHub CLI チェック ---
if (-not (Get-Command "gh" -ErrorAction SilentlyContinue)) {
    Write-Error "❌ GitHub CLI (gh) が見つかりません。インストールしてください。"
    exit 1
}

# --- YAML ファイルパス設定 ---
$yamlPath = Join-Path -Path (Join-Path $PSScriptRoot "phase$Phase") "github-project-import.yml"
if (-not (Test-Path $yamlPath)) {
    Write-Error "❌ YAML ファイルが見つかりません: $yamlPath"
    exit 1
}
Write-Host "📄 YAML 読み込み中: $yamlPath"

# --- YAML モジュール確認・ロード ---
if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Write-Host "📦 Installing powershell-yaml..."
    Install-Module powershell-yaml -Scope CurrentUser -Force -AllowClobber
}
Import-Module powershell-yaml

# --- YAML読み込み ---
try {
    $yamlContent = Get-Content $yamlPath -Raw | ConvertFrom-Yaml
} catch {
    throw "❌ YAML 解析エラー: $_"
}

# --- 既存ラベル取得 ---
$existingLabels = gh label list --repo $Repo --json name | ConvertFrom-Json | ForEach-Object { $_.name }

# --- ラベル作成 ---
$labelsToCreate = ($yamlContent.issues | ForEach-Object { $_.labels }) | Sort-Object -Unique
foreach ($label in $labelsToCreate) {
    if ($existingLabels -notcontains $label) {
        Write-Host "🏷️ 新規ラベル作成: $label"
        gh label create "$label" --repo $Repo --color "BFDADC" --description "Auto-created for phase $Phase" 2>$null
    } else {
        Write-Host "✅ 既存ラベル: $label"
    }
}

# --- Issue 作成 ---
foreach ($issue in $yamlContent.issues) {
    if (-not $issue.title) {
        Write-Warning "⚠️ YAML に title がありません。スキップします。"
        continue
    }

    $labelArgs = $issue.labels -join ","
    Write-Host "🧩 Issue 作成: $($issue.title)"
    try {
        gh issue create --repo $Repo --title "$($issue.title)" --body "$($issue.body)" --label "$labelArgs" | Out-Null
        Write-Host "✅ 作成成功: $($issue.title)"
    } catch {
        Write-Warning "⚠️ Issue 作成エラー: $($_.Exception.Message)"
    }
}

Write-Host "🎉 すべての Issue 作成が完了しました！"
