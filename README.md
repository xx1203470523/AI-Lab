# AI-Lab 工程化结构说明

本目录用于统一管理 AI Coding 的：

- 全局规则（Rules）
- 问题解决流程（Skills）
- 项目上下文（Context）
- AI 文件生成规范（Standards）
- 多模型协作（Workflow）

目标：

> 让 AI 在不同项目中稳定工作，而不是无限生成混乱 Prompt 与 Markdown。

---

# 目录结构

```text
ai-lab/
│
├── core/                     # 全局通用能力（跨项目）
│
│   ├── standards/            # ⭐ 元规范（规范AI如何写AI文件）
│   ├── rules/                # 强约束
│   ├── skills/               # 问题解决流程
│   ├── agents/               # AI角色风格（可选）
│   └── workflows/            # 多模型协作（可选）
│
│
├── projects/                 # 项目级上下文
│
│   ├── webapi/
│   │   ├── CLAUDE.md
│   │   ├── context.md
│   │   ├── context-map.md
│   │   ├── rules/
│   │   ├── skills/
│   │   └── architecture/
│   │
│   ├── pda/
│   └── wmsweb/
│
│
└── runtime/                  # AI运行机制（轻量）
```

---

# 核心设计原则

## 1. CLAUDE.md 只做入口

CLAUDE.md：

- 不写完整规范
- 不写详细架构
- 不写 workflow 全文
- 不写长篇说明

它只负责：

- 项目身份
- workspace 定位
- 规则加载入口
- 搜索约束
- build/run 命令

本质：

> CLAUDE.md = AI 工作区入口

---

## 2. Rules = 强约束

Rules 用于定义：

- 必须遵守的规则
- 禁止行为
- 分层约束
- SQL 约束
- 事务约束

特点：

- 短
- 明确
- 不解释
- 不教程化

示例：

```md
- Service 不返回 Entity
- 禁止 select *
- 库存扣减必须事务
```

---

## 3. Skills = 固定问题解决流程

Skill 本质：

> 工程经验流程化

适合：

- SQL优化
- 并发检查
- 重复提交
- 库存一致性
- 死锁分析

Skill 应包含：

- Trigger
- Checklist
- Common Fix
- Forbidden

Skill 不应该包含：

- 项目背景
- Prompt语言
- 长篇解释

---

## 4. Context = 项目世界观

Context 用于告诉 AI：

- 项目是什么
- 技术栈是什么
- 架构是什么
- 核心模块是什么

Context 不写：

- 实现细节
- Skill
- Workflow

---

## 5. Context-Map = AI 路由器

context-map.md 用于：

> 任务 → 规则映射

示例：

```md
库存相关：
  -> skills/stock-consistency.md
  -> core/rules/concurrency.md

复杂SQL：
  -> core/skills/sql/
```

作用：

- 避免 AI 全量扫描
- 提高规则命中率
- 降低 token 消耗

---

## 6. Standards = 元规范（非常重要）

Standards 用于：

> 规范 AI 如何生成 AI 文件

包含：

```text
core/standards/
  md-writing.md
  rules-writing.md
  skills-writing.md
  context-writing.md
  anti-patterns.md
```

这是整个系统最重要的部分之一。

因为：

> AI 最大的问题不是不会写，而是不知道什么内容应该以什么形式存在。

---

# 推荐文件职责

| 文件 | 作用 |
|---|---|
| CLAUDE.md | AI入口 |
| standards | AI如何写文件 |
| rules | 强约束 |
| skills | 问题解决流程 |
| context | 项目世界观 |
| context-map | AI路由 |
| agents | AI风格 |
| workflows | 多模型协作 |
| runtime | AI运行机制 |

---

# 推荐工作流

## 日常开发

```text
需求
↓
AI读取 CLAUDE.md
↓
按需加载 rules / skills
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
context-map 定位规则
↓
加载对应 skill
↓
分析/生成
↓
必要时 workflow 协作
```

---

# 推荐原则

## 只抽高频问题为 Skill

不要什么都抽 skill。

只有：

- 高频
- 容易出错
- 跨项目复用

才值得沉淀。

---

## 只把跨项目规则放 core

项目特殊逻辑：

```text
projects/webapi/
```

全局规则：

```text
core/rules/
```

---

## 避免过度工程化

不要：

- 无限扩 workflow
- 无限拆 agent
- 无限写 prompt
- 无限抽象

目标不是：

> 做 AI 框架

而是：

> 让 AI 稳定辅助真实开发

---

# Anti-Patterns（必须避免）

禁止：

- CLAUDE.md 超长
- rules 写成教程
- skills 写成项目介绍
- workflow 写成论文
- 一个 md 同时包含 rule + skill + context
- 全量扫描 ai-lab
- 无限制沉淀无价值知识

---

# 最终目标

最终希望达到：

```text
需求
↓
AI 自动定位相关规则
↓
按需读取技能
↓
稳定生成代码
↓
人类 review
```

而不是：

```text
无限Prompt
无限上下文
无限长Markdown
```

---

# 一句话总结

- CLAUDE.md = AI入口
- rules = 强约束
- skills = 解决流程
- context = 项目世界观
- standards = 规范AI如何写规范

核心目标：

> 让 AI 工程体系长期可维护，而不是越来越乱。

