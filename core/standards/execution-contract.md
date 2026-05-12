# Execution Contract (AI Runtime Protocol)

## Purpose

本文件定义：

> AI 在 ai-lab 体系中的“执行规则”

目标：

- 统一 AI 读取顺序
- 强制按需加载（避免全量扫描）
- 固化 skill / rule / context 的使用路径
- 防止 AI 自由发挥导致结构失效

---

# 核心原则

## 1. No Full Scan

禁止：

- 读取整个 ai-lab
- 无目的遍历 rules / skills
- 不基于 context-map 的随机加载

---

## 2. Must Follow Routing

所有任务必须遵循：

> runtime → context-map → skill → rule → execute

---

## 3. Minimal Context Principle

每次任务只允许加载：

- 1个 project context
- 1~2个 skills
- 1~3个 rules

禁止全量加载。

---

# Execution Flow（强制执行流程）

## Step 1: Identify Project

判断当前任务属于：

- wms
- webapi
- pda
- wmsweb

---

## Step 2: Load Project Context

仅加载：

```text
projects/{project}/context.md
projects/{project}/context-map.md
```

---

## Step 3: Route Skill

通过 context-map 或 runtime/skill-map.md：

- 定位 skill
- 禁止全量 skills 搜索

---

## Step 4: Load Rules

仅加载：

- 与 skill 匹配的 rules
- core/rules/
- project-specific rules

---

## Step 5: Execute

执行原则：

- 优先 skill checklist
- rule 为硬约束
- context 仅提供事实背景

---

# Loading Priority (优先级)

```text
1. runtime/skill-map.md
2. project/context-map.md
3. core/skills/
4. project/skills/
5. core/rules/
6. project/rules/
```

---

# Forbidden Behaviors

## 1. Global Search

禁止：

- grep 全项目
- 扫描所有 skills
- 扫描所有 rules

---

## 2. Cross-Project Mixing

禁止：

- wms skill 用于 webapi
- pda rule 用于 wmsweb

除非 context-map 显式声明

---

## 3. Skill Bypass

禁止：

- 没有 skill 直接写代码
- 跳过 checklist

---

## 4. Rule Ignoring

禁止：

- 忽略 concurrency rule
- 忽略 sql rule
- 忽略 api design rule

---

# Decision Model

AI 必须按以下逻辑决策：

```text
Is task identifiable?
    ↓
Yes → find project
    ↓
Is skill available?
    ↓
Yes → load skill
    ↓
Load related rules
    ↓
Execute
```

---

# Skill Selection Rule

## Rule 1: Single Primary Skill

一个任务只能有：

- 1个主 skill

---

## Rule 2: Optional Secondary Skill

最多允许：

- 1个辅助 skill

---

## Rule 3: No Skill Overlap

禁止：

- 同时使用多个同类 skill
  （例如两个 SQL optimize skill）

---

# Context Usage Rule

Context 只允许：

- 提供结构信息
- 提供模块信息
- 提供技术栈信息

禁止：

- 推导规则
- 替代 skill
- 替代 rule

---

# Runtime Role

runtime/ 作用：

> 不是文档，而是“调度规则”

包含：

- skill-map（路由表）
- execution-flow（执行流程）
- workflow（多模型协作）

---

# System Guarantee Goal

执行该 contract 后必须保证：

- AI 不再全量扫描项目
- skill 必须被使用
- rule 必须被遵守
- context 不参与决策
- 输出稳定可控

---

# Core Philosophy

> AI 不负责“理解整个系统”
>
> AI 只负责“按路由执行局部任务”
