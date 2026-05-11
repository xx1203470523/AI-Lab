# 模型切换

使用 `--model` 参数在启动时指定模型。不同模型可在**多个 PowerShell 窗口同时运行**，通过 workflow 文件协作。

## 启动方式

```powershell
# v4 Pro（深度推理，审查代码）
claude --model deepseek-v4-pro

# v4 Flash（默认，日常开发）
claude --model deepseek-v4-flash
```

## 当前可用模型

| 模型名 | 用途 | 典型窗口 |
|--------|------|----------|
| `deepseek-v4-flash` | 日常开发、快速问答、代码编写 | 主开发窗口（1-2 个） |
| `deepseek-v4-pro` | 代码审查、性能分析、架构设计 | 审查/分析窗口（1 个） |

> 后续新增模型在此扩展即可。

## 多模型协作模式

**核心思路**：多个 PowerShell 窗口同时运行不同模型，通过 `ai-lab/runtime/workflows/` 下的文件进行任务交接。

```
┌─────────────────────────┐    ┌─────────────────────────┐
│ Terminal 1: v4 Flash    │    │ Terminal 2: v4 Pro       │
│ 日常开发、写代码         │    │ 深度推理、审查、分析     │
│                         │    │                         │
│ 创建 workflow 任务 ──────┼───→│ 领取并执行              │
│ 收到结果，继续开发 ←─────┼────│ 写回审查报告            │
└─────────────────────────┘    └─────────────────────────┘
```

### 典型工作流

| 场景 | Flash 窗口 | Pro 窗口 | 交互方式 |
|------|-----------|----------|----------|
| 代码审查 | 写代码 → 自查 → 创建审查 workflow | 深度审查 → 写回报告 | [code-review.workflow.md](../runtime/workflows/code-review.workflow.md) |
| 性能诊断 | 快速诊断（收集日志、定位 SQL） | 并行深度分析（执行计划、索引）→ 汇总方案 | [performance.workflow.md](../runtime/workflows/performance.workflow.md) |
| 架构设计 | 需求梳理 → 质疑 Pro 方案 | 方案设计 → 回应质疑 → 定稿 | [architecture.workflow.md](../runtime/workflows/architecture.workflow.md) |
| Bug 定位 | 收集日志、初步定位、复现步骤 | 根因分析、修复方案 | 同上模式 |

### 操作步骤

1. **Flash 窗口**创建任务：
   ```
   @workflow 创建 code-review
   审查范围：当前分支变更
   ```

2. **Pro 窗口**领取并执行：
   ```
   @workflow 处理 active/20260511-xxx-code-review.md step 2
   ```

3. **Flash 窗口**查看结果、继续修改：
   ```
   @workflow 处理 active/20260511-xxx-code-review.md step 3
   ```

详见 [workflow-protocol.md](../runtime/workflows/workflow-protocol.md)。

## 模型职责分工

| 职责 | v4 Flash | v4 Pro | 协作方式 |
|------|----------|--------|----------|
| 代码编写 | **主导** | — | — |
| 快速自查 | **主导** | — | Flash 先自检再提交 Pro |
| 深度审查 | — | **主导** | Pro 审查，标注 Flash 自查遗漏 |
| 并发分析 | 表面检查 | **深度分析** | 同一代码，两层视角互补 |
| SQL 优化 | 常规建议 | **执行计划分析** | Flash 给方向，Pro 给方案 |
| 架构设计 | 需求梳理+草案 | **方案设计+定稿** | Flash 发散，Pro 收敛 |
| Bug 定位 | 收集线索 | **根因分析** | Flash 收集，Pro 推理 |

> 核心原则：**Flash 提效，Pro 把关。Flash 先做，Pro 后审。同一任务两个深度，互补不重复。**
