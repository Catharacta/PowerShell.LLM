param(
    [string]$Repo = "Catharacta/PowerShell.LLM",
    [string]$IssuesPath = "../issues"
)

# === 現在スクリプトのディレクトリを特定 ===
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$IssuesFullPath = Join-Path $ScriptDir $IssuesPath

Write-Host "`n🔍 Searching for phases in: $IssuesFullPath"

# === フェーズ一覧を取得 ===
$GetPhaseScript = Join-Path $ScriptDir "get_phase_list.ps1"
Write-Host "📂 Will run: $GetPhaseScript"

$phaseOutput = & $GetPhaseScript 2>$null

if (-not $phaseOutput) {
    Write-Host "❌ No output from get_phase_list.ps1"
    exit 1
}

Write-Host "DEBUG: raw output from get_phase_list.ps1:"
Write-Host $phaseOutput
Write-Host ""

# === JSONを安全にパース ===
try {
    $parsed = $phaseOutput | ConvertFrom-Json -ErrorAction Stop
    $phases = @($parsed)
} catch {
    Write-Host "⚠️ JSON parse failed, fallback to raw string."
    $clean = $phaseOutput -replace '[\[\]"“”\r\n\s]', ''
    $phases = @($clean)
}

# === 検出結果チェック ===
if (-not $phases -or $phases.Count -eq 0) {
    Write-Host "❌ No valid phase folders found."
    exit 1
}

# === 選択肢を表示 ===
Write-Host "📘 Select a Phase to import:`n"
for ($i = 0; $i -lt $phases.Count; $i++) {
    Write-Host "[$($i + 1)] $($phases[$i])"
}

# === ユーザー選択 ===
$selection = Read-Host "`nEnter number (1-$($phases.Count))"
if ($selection -match '^\d+$' -and $selection -ge 1 -and $selection -le $phases.Count) {
    $phase = $phases[$selection - 1]
    Write-Host "`n✅ Selected phase: $phase"
} else {
    Write-Host "❌ Invalid selection."
    exit 1
}

# === YAMLファイルを探す ===
$yamlPath = Join-Path (Join-Path $IssuesFullPath $phase) "github-project-import.yml"

if (-not (Test-Path $yamlPath)) {
    Write-Host "❌ YAML not found at: $yamlPath"
    exit 1
}

# === 実行 ===
Write-Host "`n🚀 Creating labels and issues for $phase ..."
& "$ScriptDir/create_labels_and_issues.ps1" -Repo $Repo -Phase $phase
