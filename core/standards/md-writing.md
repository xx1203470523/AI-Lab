# Markdown Writing Standard
**版本**：v1.1  
**更新日期**：2025-05-12  
**适用范围**：ai-lab 项目中所有 `.md` 文件

## Purpose

统一 ai-lab 中所有 markdown 文件的写作规范。

目标：

- 保持结构一致
- 控制复杂度
- 降低 token 消耗
- 提高 AI 可解析性
- 防止内容膨胀

---

# 核心原则

## 1. One File One Purpose

一个文件只能表达一个核心意图。

禁止：

- 一个文件同时包含 rule + skill + context
- 一个文件写多个主题
- 一个文件解决多个问题域

---

## 2. Machine Readable First

所有 md 文件必须优先考虑：

> AI 是否可以快速解析

因此必须：

- 使用 bullet point
- 使用结构化标题
- 避免长段落
- 避免散文式描述

---

## 3. No Narrative Writing

禁止：

- 故事化表达
- 教程式表达
- 长解释段落
- 背景铺垫

---

## 4. Strict Structure Preference

推荐结构：

```md
# Title

## Purpose

## Scope

## Core Rules / Steps

## Examples (optional)

## Forbidden (optional)
```

---

# 📏 文件长度规范

## Rule

| 类型 | 最大建议长度 |
|---|---|
| rule | 50~120 行 |
| skill | 80~150 行 |
| context | 50~100 行 |
| workflow | 100~200 行 |
| standards | 100~200 行 |

---

## 超过必须拆分

拆分原则：

- 按职责拆
- 按问题域拆
- 不按文件大小硬拆

---

# 内容分层规则

## 1. Context Layer（事实）

- 技术栈
- 架构
- 模块划分

不包含：

- 规则
- 流程
- 判断逻辑

---

## 2. Rules Layer（约束）

- 必须
- 禁止
- 强制条件

不包含：

- 为什么
- 如何做
- 背景解释

---

## 3. Skills Layer（流程）

- Trigger
- Steps
- Checklist
- Fix

不包含：

- 架构解释
- 项目背景

---

## 4. Standards Layer（规范）

- 如何写 md
- 如何拆文件
- 如何定义 skill / rule

> 各文件类型的详细结构参见对应规范：[rules-writing.md](rules-writing.md) / [skills-writing.md](skills-writing.md) / [context-writing.md](context-writing.md)。通用结构不足以描述特定类型时，以类型规范为准。

---

# 禁止内容（全局）

任何 md 文件禁止出现：

## Prompt语言

- “你是一个专业AI”
- “请一步一步思考”
- “作为一个资深工程师”

---

## 长段解释

```text
DDD是一种很好的架构思想...
```

---

## 混合内容

- rule + skill 混写
- context + rule 混写
- workflow + prompt 混写

---

## 教程化内容

- “什么是DDD”
- “为什么要这样设计”

---

# 推荐写法

## ✔ bullet point

```md
- 必须使用事务
- 禁止 select *
- Service 不返回 Entity
```

---

## ✔ checklist

```md
- 是否有事务
- 是否幂等
- 是否唯一索引
```

---

## ✔ 结构化步骤

```md
1. 检查并发
2. 检查事务
3. 检查幂等
```

---

# 文件拆分规则

当出现以下情况必须拆分：

## 1. 多主题

一个文件包含：

- SQL
- 并发
- 架构

---

## 2. 多意图

一个文件同时：

- 解释 + 规则 + 流程

---

## 3. 长度过大

超过：

- skill > 150行
- rule > 120行

---

## 4. 可复用性差

内容只适用于某个局部场景

---

# 核心思想总结

## Markdown 在 AI 系统中的角色：

| 类型 | 本质 |
|---|---|
| context | 描述事实 |
| rules | 定义约束 |
| skills | 固化流程 |
| standards | 定义写法 |
| md-writing | 控制整体质量 |

---

# 最关键原则（非常重要）

>Markdown 不再是“文档”
>
> 而是“AI行为控制结构”

---

# 一句话总结

md-writing 的本质：

> 控制 AI 如何组织知识，而不是知识本身

---