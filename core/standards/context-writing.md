# Context Writing Standard

> 通用 MD 写作原则遵守 [md-writing.md](md-writing.md)。

## Purpose

Context 用于描述：

> 项目的“现实世界状态”

它回答的问题是：

- 这是一个什么系统？
- 有哪些模块？
- 用了什么技术？
- 核心业务域是什么？

---

Context 的本质：

> Context = “事实描述”，不是“规则系统”

---

# Context 不能包含什么

禁止包含：

- rules（规则）
- skills（流程）
- workflow（流程编排）
- 代码实现细节
- Prompt
- AI行为说明
- 设计原则（WHY）

---

# ✔ Context 应该包含什么

## 1. 项目基本信息

- 项目名称
- 系统类型
- 业务领域

---

## 2. 技术栈

- 后端框架
- ORM
- 数据库
- 中间件

---

## 3. 架构分层（只描述结构，不解释原因）

例如：

- Presentation
- Application
- Services
- Domain
- Infrastructure

---

## 4. 核心业务域（Domain Overview）

例如：

- InStock（入库）
- OutStock（出库）
- Stock（库存）
- Report（报表）

---

## 5. 模块划分（高层）

例如：

- System Module
- Warehouse Module
- Quality Module

---

## 6. 约束事实（Facts only）

只能写“事实”，不能写“规则”

✔ 正确：

- 使用 .NET 8
- 使用 SqlSugar ORM
- 使用多租户

错误：

- 所有查询必须分页（这是 rule）
- Service不能返回Entity（这是 rule）

---

# Recommended Structure

```md
# Project Context

## 1. System Info

xxx

---

## 2. Tech Stack

xxx

---

## 3. Architecture

- Layer A
- Layer B

---

## 4. Business Domains

- Domain A
- Domain B

---

## 5. Modules

- Module A
- Module B

---

## 6. Constraints (Facts Only)

- .NET 8
- SqlSugar
- Multi-Tenant
```

---

# Context 设计核心原则

## 1. Context = “静态事实”

不随业务逻辑变化频繁调整

---

## 2. Context 不做判断

禁止：

- 应该怎么设计
- 为什么这样设计
- 推荐做法

---

## 3. Context 不参与决策

AI 不应“根据 Context 推规则”

规则来自：

- rules/
- skills/

不是 context

---

## 4. Context 要“低频更新”

只有：

- 新模块增加
- 架构变化
- 技术栈变化

才修改

---

# Anti Patterns

## 1. Context 写成架构论文

```md
DDD是一种很好的架构思想，它可以帮助我们...
```

---

## 2. Context 混入规则

```md
Service必须保持单一职责
```

（这是 rule，不是 context）

---

## 3. Context 混入技能

```md
库存扣减需要检查并发...
```

（这是 skill，不是 context）

---

## 4. Context 写成 prompt

```md
你是一个专业的AI开发助手...
```

---

# Good Example（完整示例）

```md
# Project Context

## 1. System Info

WMS（Warehouse Management System）

---

## 2. Tech Stack

- .NET 8
- SqlSugar ORM
- Furion Framework
- Redis
- SQL Server

---

## 3. Architecture

- Presentation
- Application
- Services
- Domain
- Infrastructure

---

## 4. Business Domains

- InStock
- OutStock
- Stock
- Quality
- Report

---

## 5. Modules

- System Module
- Warehouse Module
- Report Module
- PDA Module

---

## 6. Facts

- Multi-Tenant
- Soft Delete Enabled
- Snowflake ID
```

---

# 一句话总结

Context 的本质：

> “让 AI 知道这是哪里，但不告诉它该怎么做”
