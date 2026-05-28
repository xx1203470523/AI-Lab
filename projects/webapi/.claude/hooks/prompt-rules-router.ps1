# UserPromptSubmit: 根据关键词把对应 rules 文件路径注入到 AI 上下文
# 不阻断输入；命中即提示 AI 阅读对应 rule。
#
# 工作机制：
#   1. 同目录上一级（.claude/）的 router-rules.json 描述 keywords -> rule paths 映射
#   2. _rule_base 是相对 .claude/ 的 rules 目录位置（默认 ../../rules）
#   3. 命中后输出 hookSpecificOutput.additionalContext，AI 看到后会主动 Read 文件

. "$PSScriptRoot\..\lib\ps-utf8.ps1"

$json = Read-StdinJson -AllowEmpty
if ($null -eq $json) { exit 0 }
$prompt = $json.prompt
if (-not $prompt) { exit 0 }

$configPath = Join-Path $PSScriptRoot "..\router-rules.json"
if (-not (Test-Path $configPath)) { exit 0 }

try {
    $configRaw = Get-Content -Path $configPath -Raw -Encoding UTF8
    $config = $configRaw | ConvertFrom-Json
} catch {
    exit 0
}

$claudeRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$ruleBase = if ($config._rule_base) { $config._rule_base } else { "../rules" }
$rulesRoot = (Resolve-Path (Join-Path $claudeRoot $ruleBase) -ErrorAction SilentlyContinue).Path
if (-not $rulesRoot) { exit 0 }

$matchedGroups = New-Object System.Collections.ArrayList

foreach ($g in $config.groups) {
    foreach ($kw in $g.keywords) {
        if ([string]::IsNullOrWhiteSpace($kw)) { continue }
        if ($prompt -match [regex]::Escape($kw)) {
            [void]$matchedGroups.Add($g)
            break
        }
    }
}

if ($matchedGroups.Count -eq 0) { exit 0 }

$lines = New-Object System.Collections.ArrayList
[void]$lines.Add("检测到关键词命中以下规则，请优先阅读对应 rules 文件再开始操作：")
[void]$lines.Add("")

$seenPaths = @{}
foreach ($g in $matchedGroups) {
    $gName = $g.name
    $gHint = $g.hint
    [void]$lines.Add("[$gName] $gHint")
    foreach ($rel in $g.paths) {
        $abs = Join-Path $rulesRoot $rel
        if ($seenPaths.ContainsKey($abs)) { continue }
        $seenPaths[$abs] = $true
        if (Test-Path $abs) {
            [void]$lines.Add("  - $abs")
        } else {
            [void]$lines.Add("  - $abs (缺失)")
        }
    }
    [void]$lines.Add("")
}

$ctx = [string]::Join("`n", $lines.ToArray())

$result = @{
    hookSpecificOutput = @{
        hookEventName = "UserPromptSubmit"
        additionalContext = $ctx
    }
} | ConvertTo-Json -Depth 4

Write-Stdout $result
exit 0
