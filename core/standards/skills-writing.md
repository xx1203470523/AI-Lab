# Skill Writing Standard

> 通用 MD 写作原则遵守 [md-writing.md](md-writing.md)。

## Purpose

Skill 用于沉淀：

> 某类问题的固定解决流程

目标：

- 让 AI 稳定处理高频问题
- 减少重复 Prompt
- 降低上下文污染
- 提高跨项目复用能力

Skill 不是：

- 项目介绍
- Prompt
- 教程
- AI人格设定
- 长篇经验总结

---

# Skill Definition

Skill 应满足：

- 高频问题
- 易出错
- 可流程化
- 可复用
- 有明确触发条件

---

# Recommended Structure

标准结构：

```md
# Skill: xxx

## Trigger

什么时候触发

---

## Goal

解决什么问题

---

## Checklist

检查项

---

## Common Fix

常见解决方案

---

## Forbidden

禁止行为

---

## Output

输出要求（可选）
```

---

# Required Sections

## 1. Trigger

定义：

> 什么情况下应该加载该 Skill

Trigger 应：

- 明确
- 可识别
- 可路由

推荐：

```md
## Trigger

- 库存扣减
- PDA提交
- 状态流转
```

禁止：

```md
当你觉得可能有问题的时候
```

---

## 2. Goal

定义：

> Skill 最终解决的问题

推荐：

```md
## Goal

防止：

- 重复提交
- 并发写入
- 状态错乱
```

禁止：

- 长篇解释
- 背景介绍
- AI思考过程

---

## 3. Checklist

定义：

> 固定检查流程

Checklist 应：

- 短
- 明确
- 可执行

推荐：

```md
## Checklist

- 是否存在事务
- 是否幂等
- 是否状态校验
- 是否唯一约束
```

禁止：

- 长段落
- 理论解释
- 模糊描述

---

## 4. Common Fix

定义：

> 常见解决方案

推荐：

```md
## Common Fix

1. 唯一索引
2. Redis锁
3. 幂等Token
4. 状态机
```

禁止：

- 大量代码
- 多种风格混杂
- 不可维护方案

---

## 5. Forbidden

定义：

> 明确禁止行为

推荐：

```md
## Forbidden

- 仅前端防重复
- 无事务更新库存
- select \*
```

Forbidden 必须：

- 简短
- 明确
- 可执行

---

# Optional Sections

## Output

定义：

> Skill 输出要求

推荐：

```md
## Output

输出：

- 风险点
- 修复建议
- 优化后方案
```

仅在：

- Review
- SQL优化
- 分析类 Skill

场景下使用。

---

# File Naming

Skill 文件命名：

统一使用：

```text
kebab-case
```

示例：

```text
repeat-submit-check.md
stock-consistency.md
sql-optimize.md
deadlock-analysis.md
```

禁止：

```text
库存一致性.md
skill1.md
new-skill.md
最终版skill.md
```

---

# File Size Limit

建议：

- <= 150 行
- <= 1 个主题

超过必须拆分。

---

# Split Rules

以下情况必须拆分 Skill：

- 同时处理多个领域
- 同时包含 SQL + 并发 + 架构
- 超过 150 行
- Checklist 超过 15 项

---

# Writing Style

必须：

- bullet point
- checklist
- constraints
- decision tree

避免：

- 散文
- 教程
- Prompt工程语言
- AI哲学

---

# Forbidden Content

Skill 中禁止：

- 项目背景
- 技术栈介绍
- 长篇DDD解释
- “你是一个专业AI”
- Prompt模板
- 超长代码示例
- 完整架构文档
- Workflow协议

---

# Good Example

```md
# Skill: Repeat Submit Check

## Trigger

- PDA提交
- 库存扣减
- 状态流转

---

## Goal

防止：

- 重复提交
- 并发写入
- 状态错乱

---

## Checklist

- 是否事务
- 是否幂等
- 是否唯一约束
- 是否状态校验

---

## Common Fix

1. Redis锁
2. 幂等Token
3. 唯一索引

---

## Forbidden

- 仅前端防重复
- 无事务更新库存
```

---

# Bad Example

禁止：

```md
# 库存问题分析

库存是WMS系统中非常重要的一部分。

你是一个专业AI助手。

DDD架构下应该...

（后续300行）
```

问题：

- 背景过多
- Prompt化
- 不可扫描
- 不可复用
- Token浪费

---

# Core Principle

Skill 的本质：

> 解决问题流程化

而不是：

> 知识堆积
