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

## 3. Rules 只保留“真实坑点”

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

---

# 推荐工作流

## 日常开发

```text
需求
↓
读取 CLAUDE.md
↓
查看 context-map
↓
按需读取 rules / quick-ref / skills
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
定位 skill
↓
分析问题
↓
必要时查看 quick-ref
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
