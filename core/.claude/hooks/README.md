# Rules 路由 Hook 模板说明

> 用 UserPromptSubmit hook 把 rules 文件按关键词按需注入 AI 上下文，让 ai-lab 的 rules 不再是孤儿文档。

## 设计动机

Claude Code 没有 `.claude/rules/` 这个原生加载机制。任意 `.md` 文件不会被自动读。要让 rules 在合适的时机被 AI 看到，只有三个机制可选：

1. **CLAUDE.md** — 全文塞 system prompt（你不想用）
2. **SKILL.md** — 关键词触发整段 skill（rules 不是流程，不适合）
3. **Hook** — 关键词命中时主动注入 "请阅读 X.md" 提示

本模板走第 3 条路：rules 文件保留原貌，hook 做关键词→文件的路由。

## 工作流

```
用户输入: "改一下 Service 实现，再写一个 Report"
    ↓
UserPromptSubmit hook (prompt-rules-router.ps1) 触发
    ↓
读 .claude/router-rules.json → 关键词扫描
    ↓
命中 service-layer + report-module 两组
    ↓
向 AI 注入 additionalContext:
    [service-layer] 命中 Service 层关键词，建议先读 02-service-layer.md
      - <绝对路径>/02-service-layer.md
    [report-module] 命中报表模块关键词...
      - <绝对路径>/04-report-module.md
    ↓
AI 看到提示后用 Read 工具读对应 rules，再开始作业
```

## 文件构成

| 文件 | 角色 |
|---|---|
| `.claude/hooks/prompt-rules-router.ps1` | hook 主脚本（三个项目内容相同） |
| `.claude/router-rules.json` | 关键词→rules 映射（**项目特定**，是唯一需要按项目维护的部分） |
| `.claude/lib/ps-utf8.ps1` | PS5.1 UTF-8 共享前导（与现有 hook 共用） |
| `.claude/settings.sample.json` | 启用样本，复制后改名 settings.json |

`router-rules.json` 字段约定：
- `_rule_base`：rules 目录相对 `.claude/` 的位置，默认 `../rules`
- `groups[]`：每组一个主题
  - `name`：组名（注入提示时显示）
  - `keywords[]`：触发关键词数组（任一命中即触发整组）
  - `paths[]`：相对 `_rule_base` 的 rules 文件路径数组
  - `hint`：注入提示中显示的简短说明

## 启用方式

### 方式 A：项目内启用（团队共享）

把模板复制到真实项目：

```powershell
$proj = "D:\Project\WMS\IMTC.WMS.AdminWebApi"
$tpl  = "D:\Project\WMS\ai-lab\projects\webapi"

# rules 文件本身（如真实项目还没有）
Copy-Item -Recurse "$tpl\rules" "$proj\rules"

# hook 脚本
New-Item -ItemType Directory -Force "$proj\.claude\hooks","$proj\.claude\lib" | Out-Null
Copy-Item "$tpl\.claude\hooks\prompt-rules-router.ps1" "$proj\.claude\hooks\"
Copy-Item "$tpl\.claude\lib\ps-utf8.ps1" "$proj\.claude\lib\"
Copy-Item "$tpl\.claude\router-rules.json" "$proj\.claude\"

# settings.json：把 sample 内容并入现有 settings.json 的 hooks.UserPromptSubmit
```

启用后，`.claude/router-rules.json` 中 `_rule_base` 决定 rules 文件位置——默认 `../rules` 表示项目根的 `rules/` 目录。

### 方式 B：个人启用（跨项目你自己用）

把模板复制到 `~/.claude/`：

```powershell
$home_claude = "$env:USERPROFILE\.claude"
$tpl = "D:\Project\WMS\ai-lab\projects\webapi"

New-Item -ItemType Directory -Force "$home_claude\hooks","$home_claude\lib","$home_claude\rules" | Out-Null
Copy-Item "$tpl\.claude\hooks\prompt-rules-router.ps1" "$home_claude\hooks\"
Copy-Item "$tpl\.claude\lib\ps-utf8.ps1" "$home_claude\lib\"
Copy-Item "$tpl\.claude\router-rules.json" "$home_claude\"
Copy-Item -Recurse "$tpl\rules\*" "$home_claude\rules\"

# 在 ~/.claude/settings.json hooks.UserPromptSubmit 中追加：
#   { "type": "command", "command": "powershell",
#     "args": ["-NoProfile", "-File", "~\\.claude\\hooks\\prompt-rules-router.ps1"],
#     "timeout": 3 }
```

注意：个人启用时 `_rule_base` 要改成 `rules`（相对 `~/.claude/`），因为 hook 是从 `~/.claude/hooks/` 推算根，rules 文件就在 `~/.claude/rules/`。

## 自定义关键词 / 添加新规则

只改 `router-rules.json`，**hook 脚本不需要动**：

```jsonc
{
  "_rule_base": "../rules",
  "groups": [
    {
      "name": "my-new-topic",
      "keywords": ["新关键词1", "新关键词2", "english-keyword"],
      "paths": ["my-new-rule.md"],
      "hint": "命中关键词时显示给 AI 的简短说明。"
    }
  ]
}
```

关键词匹配逻辑：
- 大小写敏感（PowerShell `-match` 默认大小写不敏感，配合 `[regex]::Escape` 把关键词当字面量处理）
- 任意命中即触发整组（不需要全部命中）
- 同组只触发一次（命中第一个关键词后跳出）
- 多组可同时触发（注入提示按命中顺序拼接）

## 故障排查

**完全没注入提示**：
- 真实项目的 `.claude/settings.json` 是否注册了 `UserPromptSubmit` hook
- `router-rules.json` 路径相对 hook 是否正确（hook 找 `..\router-rules.json`）
- `_rule_base` 拼出的目录是否存在（hook 用 `Resolve-Path -ErrorAction SilentlyContinue`，路径不存在就静默退出）

**注入了但中文乱码**：
- `prompt-rules-router.ps1` 是否有 UTF-8 BOM（PS5.1 没 BOM 会按 GBK 解析中文字面量）
- `lib/ps-utf8.ps1` 是否存在并被 dot-source

**注入了但路径写错**：
- `router-rules.json` 里的 `paths` 是相对 `_rule_base` 的，不是相对 `.claude/`
- hook 输出里如果显示 `(缺失)`，说明拼出的绝对路径文件不存在

**关键词命中过多**（一次命中 4 个组以上）：
- 在 `keywords` 里把过于宽泛的词去掉（如把 `"add"` 改为 `"add entity"`）
- 把多个相似 group 合并

## 现有项目（IMTC.WMS）模板对照

| 项目 | rules 数量 | 已划分 group | 触发样例 |
|---|---|---|---|
| webapi | 4 (01~04) | domain-layer / service-layer / controller-layer / report-module | "新增 Service" → 自动提示 02-service-layer.md |
| wmsweb | 4 | page-structure / component-pattern / api-layer / state-management | "用 pinia 管 store" → 自动提示 state-management.md |
| pda | 1 (综合) | nvue-page / request-network / scan-label / voice-navigator / menu-version | "新增 nvue 扫码页" → 自动提示阅读 01-pda-patterns.md（多次） |

PDA 因 rules 文件只有一份但内容多主题，group 全部指向同一个文件——AI 看到提示后会按章节阅读，等价于"切片导航"。
