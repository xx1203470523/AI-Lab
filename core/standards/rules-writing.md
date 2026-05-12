# Rule Writing Standard

> 通用 MD 写作原则遵守 [md-writing.md](md-writing.md)。

## Purpose

Rules 用于定义：

> 系统级约束（必须遵守）

目标：

- 控制 AI 行为边界
- 保证代码一致性
- 避免错误设计重复出现
- 强化架构稳定性

Rules 不是：

- 教程
- 经验总结
- 技术讲解
- Prompt
- 示例集合

---

# Rule Definition

Rule = 强约束 + 可执行约定

必须满足：

- 明确
- 可判断
- 不可歧义
- 可执行
- 可自动检查（尽量）

---

# Recommended Structure

```md
# Rule: xxx

## Scope

适用范围（在哪些模块生效）

---

## Constraint

必须遵守的规则（核心）

---

## Forbidden

禁止行为

---

## Exception（可选）

特殊情况允许例外
```

---

# Required Principles

## 1. Rule 必须“可判断”

正确：

- Service 不允许直接返回 Entity
- SQL 禁止 select *

错误：

- Service 应该尽量清晰
- SQL 要注意性能

---

## 2. Rule 只写“结果”，不写“过程”

正确：

- 必须使用事务

错误：

- 应该先考虑事务，然后根据情况决定...

---

## 3. Rule 不写背景

禁止：

- 为什么这样设计
- DDD理念解释
- 架构说明

Rule 不是说明书。

---

## 4. Rule 必须短

建议：

- 5~20条以内
- 单条 ≤ 2 行（优先）

---

# File Naming

统一命名：

```text
kebab-case.md
```

示例：

- service-layer.md
- controller-layer.md
- concurrency-rule.md
- sql-rule.md

禁止：

- 最终版规则.md
- new-rule-v2.md
- test.md

---

# Rule Types

## 1. Architecture Rules

例如：

- 分层约束
- 模块依赖

---

## 2. Data Rules

例如：

- 软删除
- 唯一约束
- 数据一致性

---

## 3. SQL Rules

例如：

- 禁止 select *
- 必须索引条件
- join 必须显式

---

## 4. Concurrency Rules

例如：

- 必须事务
- 必须幂等
- 必须防重复提交

---

# Good Example

```md
# Rule: Service Layer

## Scope

All Services

---

## Constraint

- Service must not return Entity
- Business logic must not be in Controller
- DTO must be used for output

---

## Forbidden

- Cross module repository call
- Direct DB access in Controller
```

---

# Bad Example

```md
Service层是业务核心层，它负责处理业务逻辑...

（长篇解释）
```

问题：

- 不可执行
- 不可判断
- AI不会严格遵守
- token浪费

---

# File Size Limit

建议：

- 50 ~ 120 行
- 超过必须拆分

---

# Split Rules

必须拆分情况：

- 同时包含多个层（service + controller + sql）
- rule 超过 25 条
- 出现“解释性段落”

---

# Anti Patterns

禁止：

- Rule 写成教程
- Rule 写成经验分享
- Rule 写成DDD说明
- Rule 混入 Skill
- Rule 混入 Context
- Rule 变成 Prompt

---

# Core Principle

Rule 的本质：

> 控制边界，而不是解释系统

---

# Final Rule

如果一条规则不能被简单判断：

> 就不是 Rule

必须拆成：

- Rule（约束）
- Skill（流程）
- Context（背景）