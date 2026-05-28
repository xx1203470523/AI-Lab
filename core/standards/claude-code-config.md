# Claude Code 工程化配置学习笔记

## Purpose

本文用于记录从轻量 ai-lab 逐步理解 Claude Code 工程化配置的学习路径。

ai-lab 仍然是项目知识库，不是运行时配置中心。本文总结 `.claude/settings.json`、hooks、skills、agents 等机制的用途和边界，方便后续维护 ai-lab 时判断哪些经验应该沉淀为知识，哪些经验未来可以整理成配置样本。

---

## 1. 轻量 ai-lab 与工程化 `.claude`

| 维度 | 轻量 ai-lab | 工程化 `.claude` |
|------|-------------|------------------|
| 主要目标 | 降低搜索成本、沉淀业务知识 | 提高稳定性、减少误操作 |
| 典型文件 | README、rules、quick-ref、skills 文档 | settings、hooks、原生 skills、agents |
| 生效方式 | AI 按需读取 | Claude Code 运行时触发 |
| 维护成本 | 低，适合个人逐步积累 | 高，适合团队稳定化约束 |
| token 成本 | 更可控 | 常驻上下文和自动注入更多 |
| 适合内容 | 业务链路、领域规则、历史坑点 | 高频、可静态判断、风险高的约束 |

推荐理解方式：

```text
ai-lab 解决“AI 不知道项目上下文”的问题。
.claude 解决“AI 知道规则但可能忘记执行”的问题。
```

所以两者不是替代关系，而是分层关系：

```text
CLAUDE.md      = 轻入口
ai-lab/        = 知识库、业务链路、规则索引
.claude/       = Claude Code 运行时配置
logs/          = 执行历史和任务记忆
```

---

## 2. 从轻量到工程化的演进顺序

不要一开始就把所有东西都做成 hook 或 agent。

推荐顺序：

```text
第一阶段：维护 README、rules、quick-ref
↓
第二阶段：把高频问题沉淀为 ai-lab skill 文档
↓
第三阶段：把稳定高频任务包装成 .claude/skills
↓
第四阶段：把高风险且可静态判断的规则做成 hook
↓
第五阶段：把复杂审查沉淀为 agents
```

判断标准：

| 问题 | 更适合放哪里 |
|------|--------------|
| 业务链路、字段含义、实体关系 | ai-lab quick-ref / rules |
| 问题排查步骤、固定 checklist | ai-lab skills |
| 新增、修改、重构这类高频开发动作 | `.claude/skills` |
| 明确违规、可静态判断、需要立刻阻断 | `.claude/hooks` |
| 多文件审查、第二视角、专项 review | `.claude/agents` |

---

## 3. `.claude` 目录分层

常见结构：

```text
.claude/
  settings.json
  settings.local.json
  hooks/
  skills/
  agents/
  lib/
```

| 路径 | 用途 | 是否建议沉淀到 ai-lab |
|------|------|------------------------|
| `settings.json` | 项目级运行配置，注册 hooks、权限、环境行为 | 可以总结结构，不直接复制真实项目 |
| `settings.local.json` | 个人本地配置 | 不应沉淀 |
| `hooks/` | 自动化脚本，按事件触发 | 可以总结模式，成熟后再做样本 |
| `skills/` | Claude Code 原生技能 | 可以总结结构和使用规范 |
| `agents/` | 专项子代理 | 可以总结审查模式 |
| `lib/` | hook 共享工具库 | 可以总结通用能力，如 UTF-8 前导 |

当前 ai-lab 已在 `projects/webapi/.claude`、`projects/wmsweb/.claude`、`projects/pda/.claude` 保存项目级学习副本。它们用于研究和后续维护，不会自动作用于真实项目。`settings.sample.json` 仍使用 sample 命名，避免误认为它会直接生效。

---

## 4. settings.json 学习笔记

`settings.json` 是 Claude Code 项目级配置入口。

常见用途：

- 配置 `permissions.allow`，减少重复权限提示。
- 注册 hooks。
- 为不同子项目设置不同工具权限。
- 通过 hook 注入上下文或阻断高风险行为。

常见事件注册：

```text
SessionStart      会话开始
UserPromptSubmit  用户提交提示词后
PreToolUse        工具调用前
PostToolUse       工具调用后
Stop              回合结束前
PostCompact       上下文压缩后
```

维护建议：

- `permissions.allow` 只给最小必要权限。
- 不要把个人偏好写进公共 `settings.json`。
- 不要把 `settings.local.json` 放进 ai-lab。
- 不要无脑复制团队项目设置；先理解每个 hook 的目的。
- 对阻断型 hook，要先明确误判成本。

---

## 5. hooks 学习笔记

Hook 是 Claude Code 在特定事件发生时执行的脚本。

它适合做：

- 自动上下文注入。
- 自动提醒。
- 静态规则检查。
- 高风险操作阻断。
- 结束前补充检查。

### 5.1 常见 Hook 类型

| 事件 | 触发时机 | 适合用途 |
|------|----------|----------|
| `SessionStart` | 会话开始 | 注入当前分支、最近提交、未提交文件 |
| `UserPromptSubmit` | 用户提交提示词后 | 根据关键词提示使用 skill，或补充项目上下文 |
| `PreToolUse` | 工具执行前 | 阻断危险命令、错误文件类型、明显违规代码 |
| `PostToolUse` | 工具执行后 | lint、格式检查、变更后验证 |
| `Stop` | 回合结束前 | 检查是否写任务日志、是否遗漏验证 |
| `PostCompact` | 上下文压缩后 | 重注入关键约束 |

### 5.2 适合 hook 化的规则

```text
高频 + 风险大 + 可静态判断 + 误判成本可控
```

示例：

- 禁止 Bash 中嵌套调用 `powershell` / `pwsh`。
- 禁止 `.cs` 中新增 `Task.WhenAll` 包数据库操作。
- 禁止 Application 层直接注入 Repository。
- 禁止 PDA 项目新增普通 `.vue` 页面。
- Stop 时发现本轮有 Edit/Write 但没有任务日志，则提醒补写。

### 5.3 不适合 hook 化的规则

```text
复杂业务判断 + 需要上下文推理 + 误判会频繁打断
```

示例：

- 调拨完整业务链路。
- 某个字段在特定流程中的来源含义。
- 需要结合多个接口和数据库状态才能判断的问题。
- 低频且容易变化的临时流程。

这些更适合放在 ai-lab 的 `quick-ref`、`rules`、`skills` 中。

### 5.4 PowerShell Hook 注意事项

Windows PowerShell 5.1 默认会受系统 ANSI/GBK 编码影响，中文很容易乱码。

团队项目中验证有效的模式：

- `.ps1` 保存为 UTF-8 BOM。
- hook 顶部 dot-source 共享前导脚本。
- 用 `Read-StdinJson` 从 stdin 字节流按 UTF-8 解析 hook payload。
- 用 `Write-Stdout` 直接按 UTF-8 字节写 stdout。
- 不在每个 hook 里重复写编码设置。

这类内容适合先作为学习笔记沉淀；等熟悉后，再整理为 `ps-utf8.sample.ps1` 模板。

### 5.5 阻断与提醒

Hook 不一定都要阻断。

| 类型 | 适合场景 |
|------|----------|
| 提醒型 | 规则不够确定，只想补充上下文或建议 |
| 阻断型 | 规则明确，继续执行大概率产生错误 |

Stop hook 如果会阻断，需要防止死循环。例如检测到 `stop_hook_active` 时放行。

---

## 6. skills 学习笔记

ai-lab 中有两类 skill，容易混淆。

| 类型 | 路径 | 作用 |
|------|------|------|
| 知识库 skill | `core/skills/`、`projects/*/skills/` | 记录问题解决流程，供 AI 按需读取 |
| Claude Code 原生 skill | `.claude/skills/*/SKILL.md` | 可被 Claude Code 识别和调用 |

### 6.1 知识库 skill

适合记录：

- SQL 调优步骤。
- 死锁分析流程。
- 库存一致性排查。
- PDA 重复提交检查。
- 调拨完整业务流程。

它的目标是减少搜索成本，不负责自动触发。

### 6.2 Claude Code 原生 skill

适合封装高频开发动作：

| Skill | 适合场景 |
|-------|----------|
| `base` | 项目共享约束，通常不让用户直接调用 |
| `gen` | 新增实体、服务、控制器、模块 |
| `mod` | 修改、修复、调整现有代码 |
| `rf` | 重构、提取、拆分、简化 |
| `release` | 发布、打包、出包流程 |

原生 skill 通常包含 frontmatter：

```markdown
---
name: mod
description: "修改或修复现有代码..."
shell: powershell
version: 1.0.0
---
```

维护建议：

- `description` 写触发范围和关键词。
- `base` 放共享规则，避免 gen/mod/rf 重复。
- skill 中写流程和检查项，不写长篇业务知识。
- 业务链路继续放 ai-lab 的 quick-ref/rules/skills。
- 不要为低频任务创建 skill。

---

## 7. agents 学习笔记

Agent 是专项子代理配置，适合把某类任务交给独立上下文处理。

常见用途：

- 后端代码审查。
- 前端代码审查。
- PDA 代码审查。
- 安全审查。
- 大范围只读探索。

Agent 与 hook 的区别：

| 类型 | 特点 |
|------|------|
| hook | 自动触发，适合提醒、阻断、注入上下文 |
| agent | 被委派执行，适合深度分析、专项审查 |

团队项目中的 review agent 值得学习：

- 每个子项目一个审查 agent。
- agent 描述目标技术栈。
- agent 列出审查重点。
- 输出必须带文件路径和行号。

复制到其他项目时，不应直接复用 WMS 审查重点，而要重写项目自己的风险清单。

---

## 8. 当前 WMS 项目可学习的经验

以下是工程化经验总结，不是迁移要求。

### 8.1 UTF-8 前导

解决问题：PowerShell 5.1 中文输出和 hook JSON stdin/stdout 容易乱码。

适合沉淀为：

- 学习笔记。
- 未来 `.claude/lib/ps-utf8.sample.ps1` 模板。

### 8.2 Bash 嵌套 PowerShell 拦截

解决问题：在 Bash 工具里调用 `powershell` / `pwsh`，容易导致编码、变量解析、权限和日志行为不一致。

适合沉淀为：

- PowerShell 项目的通用 PreToolUse hook 样本。

### 8.3 Skill 路由提醒

解决问题：用户说“新增、修改、重构”时，AI 可能忘记调用对应 skill。

适合沉淀为：

- UserPromptSubmit hook 学习案例。

### 8.4 SessionStart 上下文注入

解决问题：AI 开局不知道当前分支、最近提交、未提交文件。

适合沉淀为：

- 通用 SessionStart hook 样本。

### 8.5 PreToolUse 强约束

解决问题：有些错误一旦写入代码，后面再 review 成本更高。

适合阻断的例子：

- 数据库操作中的 `Task.WhenAll`。
- 跨层依赖。
- 硬删除。
- PDA 普通 `.vue` 页面。
- 前端废弃组件路径。

### 8.6 Stop 任务日志

解决问题：AI 修改了代码但没有留下任务记录，后续很难追溯。

适合沉淀为：

- Stop hook 学习案例。
- logs/INDEX.md 任务记忆模式。

### 8.7 Review Agent

解决问题：主会话容易带着实现视角看代码，专项 agent 可以提供第二视角。

适合沉淀为：

- backend/frontend/pda review agent 样本思路。

---

## 9. 不要过度工程化

不建议沉淀：

- 真实项目 `settings.local.json`。
- 个人权限配置。
- token、账号、本机路径。
- 运行日志和临时输出。
- 未验证过的 prompt 实验。
- 低频、模糊、容易误判的 hook。
- 可以直接从代码读出的普通 CRUD 细节。

建议沉淀：

- 真实踩坑。
- 业务链路。
- 高价值 quick-ref。
- 高频问题 checklist。
- 已验证有效的 hook 设计思想。
- 原生 skill 的组织方式。
- agent 审查重点的设计方式。

---

## 10. 后续维护建议

后续可以分阶段补充：

```text
1. 先继续维护当前 ai-lab 文档。
2. 熟悉 settings/hooks/skills/agents 后，再新增 projects/_template/.claude。
3. 每次只模板化一个成熟机制。
4. 模板文件统一使用 .sample 后缀。
5. 复制到真实项目之前，先手动检查路径、权限、编码、误判风险。
```

原则：

```text
ai-lab 先总结经验，再沉淀模板，最后才考虑复制到项目。
```
