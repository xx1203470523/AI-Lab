# Workflow 协议 — 多模型文件交互规范

## 核心思路

多个 PowerShell 窗口 = 多个模型同时在线，各司其职、职责可能交叉。
通过**文件**实现模型间多向交互和迭代协作。

```
┌──────────────────────┐    ┌──────────────────────┐    ┌──────────────────────┐
│ Terminal 1: Flash #1 │    │ Terminal 2: Pro       │    │ Terminal 3: Flash #2 │
│ 日常开发、写代码      │    │ 深度推理、代码审查    │    │ 并行任务、辅助开发    │
│                      │    │                      │    │                      │
│  创建任务 ────────────┼───→│  领取并深度分析 ─────┼───→│                      │
│                      │    │                      │    │                      │
│  收到审查意见 ←───────┼────│  写回审查报告         │    │                      │
│  修改代码             │    │                      │    │                      │
│  请求重审 ────────────┼───→│  重审修改             │    │                      │
│                      │    │                      │    │                      │
│  确认通过 ←───────────┼────│  标记完成             │    │                      │
└──────────────────────┘    └──────────────────────┘    └──────────────────────┘
```

## 模型职责矩阵

同一份代码，不同模型从不同深度和角度参与：

| 职责 | v4 Flash | v4 Pro | 交叉情况 |
|------|----------|--------|----------|
| 代码编写 | **主导** | — | — |
| 快速自查 | **主导** | — | Flash 先自检 |
| 深度审查 | — | **主导** | Pro 审查 Flash 写的代码 |
| 并发分析 | 表面检查 | **深度分析** | 同一段代码，两层视角 |
| SQL 优化 | 常规索引建议 | **执行计划+深度优化** | Flash 给快速建议，Pro 给深度方案 |
| 架构设计 | 方案草稿 | **方案评审+拍板** | Flash 出草案，Pro 评审 |
| Bug 定位 | 日志收集+初步定位 | **根因分析** | Flash 收集线索，Pro 定根因 |
| 重构执行 | **主导** | 方案审核 | Pro 定方案，Flash 执行 |

> 核心原则：**Flash 提效，Pro 把关。Flash 先做，Pro 后审。同一任务两个深度，互补不重复。**

## 文件格式（v2 — 多参与者 + 步骤化）

```markdown
---
id: "20260511-143022-code-review-a1b2c3"
workflow: "code-review"
status: "pending"
priority: "normal"
created_at: "2026-05-11T14:30:22+08:00"

# 参与者定义
participants:
  - id: "flash-1"
    model: "deepseek-v4-flash"
    role: "author"             # author | reviewer | analyst | executor
  - id: "pro-1"
    model: "deepseek-v4-pro"
    role: "reviewer"
  - id: "flash-2"
    model: "deepseek-v4-flash"
    role: "executor"           # 按审查意见修改代码

# 步骤定义
steps:
  - step: 1
    name: "快速自查"
    assigned: "flash-1"
    status: "completed"
    summary: "已完成基础检查，未发现明显问题"

  - step: 2
    name: "深度审查"
    assigned: "pro-1"
    status: "pending"
    depends_on: [1]
    focus: ["并发安全", "事务边界", "数据一致性"]

  - step: 3
    name: "按审查意见修改"
    assigned: "flash-1"
    status: "pending"
    depends_on: [2]

  - step: 4
    name: "重审修改"
    assigned: "pro-1"
    status: "pending"
    depends_on: [3]

  - step: 5
    name: "确认通过"
    assigned: "pro-1"
    status: "pending"
    depends_on: [4]
---

# 任务描述

## 背景
（为什么需要这个分析）

## 审查范围
（文件列表、变更范围）

---

<!-- ============================================ -->
<!-- 以下区域由各步骤的 assigned 模型填写           -->
<!-- ============================================ -->

## Step 1 — 快速自查（flash-1）

### 检查结果
（Flash 的快速扫描结果——语法、明显问题）

### 提交给 Pro 的问题
（Flash 不确定、需要深度分析的点）

---

## Step 2 — 深度审查（pro-1）

### 严重问题
（必须修复）

### 建议改进
（应尽快修复）

### Flash 自查遗漏
（对比 Step 1，Pro 发现了哪些 Flash 没看出来的问题）

---

## Step 3 — 修改执行（flash-1）

### 修改摘要
| 文件 | 修改内容 | 对应审查项 |
|------|----------|------------|

---

## Step 4 — 重审（pro-1）

### 修改确认
- [ ] 问题 A 已修复
- [ ] 问题 B 已修复
- [ ] 无新问题引入

---

## Step 5 — 最终结论（pro-1）

- 风险等级：
- 是否可合并：
```

## 状态机（步骤级别）

```
每个 step 独立状态：
  pending ──→ in_progress ──→ completed
                │
                └──→ blocked（依赖的 step 未完成）

workflow 整体状态：
  pending ──→ in_progress ──→ completed
    │                           │
    └──→ failed                 └──→ re_opened（需要返工）
```

## 执行模式

### 串行（默认）
步骤按 `depends_on` 顺序执行，上一步完成才触发下一步。

### 并行
如果多个 step 互不依赖，**不同模型的会话可以同时执行各自的 step**：

```yaml
steps:
  - step: 1
    name: "SQL 性能分析"
    assigned: "pro-1"
  - step: 2
    name: "代码规范检查"
    assigned: "flash-1"
  # step 1 和 step 2 无依赖 → 可同时在两个窗口执行
```

### 迭代
同一个 step 可以被重新打开：

```
Pro 审查 → Flash 修改 → Pro 重审（不通过）→ Flash 再改 → Pro 再重审
```

通过在 frontmatter 中增加 `iteration: 2` 追踪轮次。

## 文件命名与目录

```
ai-lab/runtime/workflows/
  active/                              ← 进行中的 workflow
    20260511-143022-code-review-xxx.md
  archive/                             ← 已完成的 workflow
    20260510-090000-performance-yyy.md
```

> 简化：只分 `active/` 和 `archive/`，不再区分 inbox/outbox。同一文件内多步骤协作，不需要搬运。

## 发现机制

### 模式 1：用户中介（推荐）

1. Flash 窗口创建 workflow → 告诉用户文件路径
2. 用户在 Pro 窗口输入：`@workflow 处理 active/xxx.md step 2`
3. Pro 执行指定 step → 写回结果
4. 用户回到 Flash 窗口继续下一步

### 模式 2：目录监控

在 Pro 窗口中持续监控：

```
@workflow 监控 active/ --model deepseek-v4-pro --role reviewer
```

Pro 会话自动检测新文件或新 step，认领执行。

### 模式 3：主动轮询

```
每 5 分钟检查 active/ 是否有指派给我的待处理 step
```

## 会话指令

```
@workflow 创建 {type}                 # 创建新 workflow（Flash 侧常用）
@workflow 处理 {file} step {n}        # 执行指定步骤
@workflow 列表 [--mine] [--pending]   # 列出 workflow
@workflow 查看 {file}                 # 查看详情
@workflow 归档 {file}                 # 移到 archive/
@workflow 监控 active/                # 启动目录监控模式
```
