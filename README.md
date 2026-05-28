# AI-Lab

AI-Lab 用于管理 AI Coding 的项目上下文、工程规则与问题解决经验。

目标不是“控制 AI”。

而是：

> 帮助 AI 更快理解项目，减少无效搜索与低质量输出。

---

# 核心理念

现代 AI（Claude / GPT / DeepSeek 等）已经具备较强代码能力。

工程化重点不再是：

- 教 AI 怎么写代码
- 给 AI 无限 Prompt
- 设计复杂 Agent Workflow

而是：

- 提供项目上下文
- 提供业务链路
- 提供真实踩坑经验
- 降低搜索成本
- 提高定位效率

AI 缺少的不是“编码能力”。

而是：

- 项目知识
- 数据流向
- 文件位置
- 业务约束
- 历史坑点

因此：

```text
AI-Lab = 项目知识索引系统
而不是 AI 管理系统
```

---

# 目录结构

```text
ai-lab/
│
├── core/                         # 跨项目通用能力
│
│   ├── rules/                    # 通用强约束
│   ├── skills/                   # 通用问题解决流程
│   └── standards/                # AI 文件生成规范（可选）
│
├── projects/                     # 项目级上下文
│
│   ├── webapi/
│   │   ├── CLAUDE.md             # 项目入口
│   │   ├── context-map.md        # 任务 → 上下文索引
│   │   │
│   │   ├── quick-ref/            # 高价值业务速查（核心）
│   │   │   ├── data-flows.md
│   │   │   ├── entity-map.md
│   │   │   └── fk-chains.md
│   │   │
│   │   ├── rules/                # 项目特定约束
│   │   └── skills/               # 项目特定问题流程
│   │
│   ├── wms/
│   ├── pda/
│   └── wmsweb/
│
└── runtime/                      # 轻量运行辅助（可选）
    └── workflows/
```

---

# 文件职责

| 文件        | 作用               |
| ----------- | ------------------ |
| CLAUDE.md   | 项目入口           |
| context-map | 任务 → 上下文路由  |
| quick-ref   | 项目知识速查       |
| rules       | AI 易踩坑约束      |
| skills      | 高频问题解决流程   |
| standards   | AI 文件规范        |
| workflows   | 多模型协作（可选） |

---

# 设计原则

## 1. CLAUDE.md 只做入口

CLAUDE.md 不写大而全规范。

只保留：

- 项目身份
- build/run/test 命令
- context-map 入口
- quick-ref 索引
- 少量关键约束

本质：

```text
CLAUDE.md = AI 进入项目后的导航页
```

不是：

```text
AI 行为管理条例
```

---

## 2. Quick-Ref 是核心

AI 最缺的不是编码能力。

而是：

```text
东西在哪
数据怎么流
字段从哪里来
改哪里会影响什么
```

quick-ref 用于解决这些问题。

例如：

| 文件              | 用途           |
| ----------------- | -------------- |
| data-flows.md     | 数据链路       |
| entity-map.md     | 功能与实体映射 |
| fk-chains.md      | 表关联关系     |
| business-links.md | 业务调用链     |

---

## 3. Rules 只保留"真实坑点"，靠 Hook 路由触发

Rules 不写教程。

只记录：

```text
AI 无法从训练数据得知
且容易踩坑
```

例如：

```md
- quantity 扣减必须条件更新
- SnapshotEntity 更新后必须调用 AfterUpdate
- namespace 必须以实际声明为准
- 禁止直接更新库存快照表
```

不要写：

```md
- Controller 放 Controllers
- Service 使用依赖注入
```

这些属于 AI 已知知识。

### 触发机制：UserPromptSubmit Hook 路由

Claude Code 没有 `.claude/rules/` 这个原生加载机制——任意 `.md` 文件不会被自动读。仅靠 CLAUDE.md 引用 + 让 AI 自己去读，实践中触发率很低。

ai-lab 在每个项目的 `.claude/` 下提供一份 hook 模板（`prompt-rules-router.ps1`）+ 关键词映射（`router-rules.json`），按用户输入的关键词自动注入 "请先读 X.md" 提示，让 AI 在干活前看到对应 rules。

```
ai-lab/projects/{webapi,wmsweb,pda}/.claude/
├── hooks/prompt-rules-router.ps1   # hook 主脚本（三项目同款）
├── router-rules.json               # 关键词→rules 映射（项目特定）
├── lib/ps-utf8.ps1                 # PS5.1 UTF-8 共享前导
└── settings.sample.json            # 启用样本
```

启用方式两种（详见 `core/.claude/hooks/README.md`）：

| 方式 | 用途 | 落点 |
|---|---|---|
| 项目内启用 | 团队共享 | 复制到真实项目 `.claude/` |
| 个人启用 | 跨项目你自用 | 复制到 `~/.claude/`（路径变量化） |

工作流：

```
用户: "改一下 Service 实现，再写一个 Report"
    ↓
hook 命中关键词 service / Report
    ↓
注入: 请先读 02-service-layer.md + 04-report-module.md
    ↓
AI Read 对应 rules → 再开始作业
```

---

## 4. Skills 只沉淀高价值流程

Skill 是：

```text
高频
复杂
容易遗漏
跨项目复用
```

的问题解决经验。

适合 Skill 的内容：

- SQL 调优
- 死锁分析
- 库存一致性
- PDA 重复提交
- 并发问题排查

不适合：

- 新增 Controller
- 新增 DTO
- 基础 CRUD

---

## 5. Context-Map 用于减少搜索成本

context-map 不负责“控制 AI”。

只负责：

```text
任务 → 推荐阅读内容
```

例如：

```text
库存扣减问题
→ inventory rules
→ inventory consistency skill
→ fk-chains
```

目标：

- 减少无效搜索
- 提高上下文命中率
- 降低 token 消耗

### context-map 的实际触发机制

context-map 自身不会被 AI 自动加载——它是 markdown 文档，不是 Claude Code 原生加载入口。要让它真正起作用，需要一种触发方式：

| 触发方式 | 实现 |
|---|---|
| 关键词 → rules（自动） | `prompt-rules-router.ps1` hook + `router-rules.json`，已实现 |
| 关键词 → skill（自动） | SKILL.md frontmatter 的 `description`，已实现 |
| 入口文档 → AI 主动读 | `CLAUDE.md` 顶部明确引用 context-map（半自动，需 AI 配合） |

实践经验：**只有 hook + skill frontmatter 是稳定触发**。CLAUDE.md 引用是辅助。把 context-map 当作"给人看的导航文档 + AI 偶尔读的索引"，不要奢望它自动加载。

---

## 6. 配置分层：项目级 / 个人级 / ai-lab

ai-lab 是模板源，最终生效需要复制到 Claude Code 实际加载的位置。配置存在三个层次：

```text
ai-lab/                       — 模板源（不直接生效）
真实项目 .claude/             — 项目级（团队共享）
~/.claude/                    — 个人级（跨项目，你自己用）
```

| 层 | 适合放 | 例子 |
|---|---|---|
| ai-lab | 所有可复用模板的真源 | skill / hook / rules / quick-ref |
| 项目级 `.claude/` | 团队共同遵守的约束 | 分层 hook、领域 skill、PreToolUse 拦截 |
| 个人级 `~/.claude/` | 你自己的偏好 | push 流程、commit 风格、跨项目通用 skill |

启用方式：从 ai-lab 复制到对应层。skill 和 hook 之间的优先级（`~/.claude/` 优先于项目）见 Claude Code 官方文档。

---

# 推荐工作流

## 日常开发

```text
需求
↓
[自动] UserPromptSubmit hook 命中关键词 → 注入 rules / skill 提示
[自动] CLAUDE.md 已加载（项目级）
↓
AI 读取被注入的 rules
↓
AI 按需查 quick-ref（业务事实）
↓
生成代码
↓
人类 review
```

---

## 复杂问题

```text
需求
↓
关键词触发 skill（自动）
↓
skill 内引用 quick-ref / rules
↓
分析问题
↓
生成修复方案
↓
review
```

---

# 推荐实践

## 优先沉淀“项目知识”

优先级：

```text
项目链路 > AI Prompt
业务知识 > 通用规范
文件定位 > 编码模板
```

---

## 减少通用规范

AI 本身已经知道：

- Controller 怎么写
- Service 怎么分层
- DI 怎么注册
- Repository 怎么调用

不要重复沉淀这些内容。

---

## 避免过度工程化

不要：

- 无限拆 Agent
- 无限 Workflow
- 无限 Prompt
- 无限规则
- 无限自动化

目标不是：

```text
做一个 AI 操作系统
```

而是：

```text
让 AI 能稳定辅助真实开发
```

---

# Anti-Patterns

避免：

- CLAUDE.md 超长
- rules 写成教程
- skills 写成项目介绍
- workflow 复杂化
- 一个文件混合 rule + context + skill
- 全量扫描整个 ai-lab
- 沉淀 AI 已知的通用知识
- 无限制积累低价值 Markdown

---

# 最终目标

```text
需求
↓
AI 快速定位相关上下文
↓
按需读取项目知识
↓
稳定生成代码
↓
人类 review
```

而不是：

```text
加载大量规则
↓
自由发挥
↓
输出不稳定
```

---

# 一句话总结

```text
AI-Lab 的目标：

不是教 AI 写代码。

而是帮助 AI 更快理解项目。
```
