# AI Lab — WMS AI 工程化上下文

AI 协作上下文、规则、技能和运行机制的集中管理目录。

> 本目录已被 `.gitignore` 忽略，不会提交到代码仓库，仅供 AI 协作使用。

---

## 目录结构

```
ai-lab/
│
├── core/                          # 能力库（跨项目通用）
│   ├── registry.json              # 全局索引 — skill / rule / agent / workflow 注册
│   │
│   ├── rules/                     # 通用规范
│   │   ├── sql.md                 # SQL 查询规范
│   │   ├── api-design.md          # API 设计规范
│   │   ├── architecture.md        # 架构分层规范
│   │   └── concurrency.md         # 并发安全规范
│   │
│   ├── skills/                    # 可复用技能
│   │   ├── sql/
│   │   │   ├── optimize.md        # SQL 优化
│   │   │   └── index-check.md     # 索引检查
│   │   ├── code-review/
│   │   │   └── dotnet-service.md  # .NET Service 审查
│   │   └── general/
│   │       ├── bug-analysis.md    # Bug 分析
│   │       └── model-switch.md    # 模型切换与多窗口协作
│   │
│   ├── agents/                    # AI Agent 定义
│   │   ├── reviewer.md            # 代码审查员
│   │   ├── architect.md           # 架构师
│   │   ├── sql-expert.md          # SQL 专家
│   │   └── v4-pro.md              # v4 Pro 深度推理 Agent
│   │
│   └── prompts/                   # 常用 Prompt 模板
│       ├── debug.md               # 调试
│       ├── refactor.md            # 重构
│       └── analyze-performance.md # 性能分析
│
├── projects/                      # 业务隔离层
│   ├── wms/                       # WMS 领域
│   │   ├── CLAUDE.md              # 项目上下文
│   │   ├── context.md             # 模块概览
│   │   ├── rules/
│   │   │   └── wms-business.md    # 入库/出库/库存业务规范
│   │   └── skills/
│   │       ├── repeat-submit-check.md  # 防重复提交
│   │       ├── stock-consistency.md    # 库存一致性
│   │       └── pda-sync-check.md       # PDA 同步检查
│   │
│   ├── webapi/                    # 后端 API 专属
│   │   ├── CLAUDE.md              # 项目上下文
│   │   ├── rules/                 # 分层规范
│   │   │   ├── 01-domain-layer.md
│   │   │   ├── 02-service-layer.md
│   │   │   ├── 03-controller-layer.md
│   │   │   └── 04-report-module.md
│   │   └── skills/
│   │       ├── new-report.md      # 新增报表
│   │       └── debug-report.md    # 报表调试
│   │
│   └── pda/                       # PDA 手持终端
│       └── CLAUDE.md
│
└── runtime/                       # 运行机制
    ├── skill-map.md               # 输入 → Skill 匹配规则
    ├── agent-routing.md           # Agent 选择 + 跨模型委托规则
    ├── execution-flow.md          # 完整执行链路定义
    └── workflows/                 # 多模型协作 workflow
        ├── workflow-protocol.md   # 文件交互协议（步骤化、迭代、状态机）
        ├── code-review.workflow.md    # 代码审查 5 步流程
        ├── performance.workflow.md    # 性能诊断 4 步流程
        └── architecture.workflow.md   # 架构设计 6 步流程
```

---

## 运行架构

```
用户输入
    ↓
[Context Loader]      ← 加载 CLAUDE.md + 项目上下文
    ↓
[Registry 引擎]       ← 查 registry.json 匹配 skill / rule / agent
    ↓
[Skill Matcher]       ← 按 skill-map.md 匹配
    ↓
[Agent Selector]      ← 按 agent-routing.md 选择 + 复杂度自评
    ↓
    ├── 当前模型胜任 → [Execution Engine] → 结构化输出
    │
    └── 超出能力范围 → [Workflow Dispatcher]
                         ↓
                    创建 workflow 文件到 runtime/workflows/active/
                         ↓
                    另一模型会话领取执行 → 写回结果 → 继续
```

---

## 核心文件

| 文件 | 作用 |
|------|------|
| `core/registry.json` | 全局索引，所有 skill/rule/agent/workflow 在此注册 |
| `runtime/skill-map.md` | 用户输入 → 匹配哪个 skill |
| `runtime/agent-routing.md` | 什么场景用哪个 agent + 何时委托另一模型 |
| `runtime/execution-flow.md` | 完整执行流程定义 |
| `runtime/workflows/workflow-protocol.md` | 多模型文件交互协议 |
| `runtime/workflows/*.workflow.md` | 各类型 workflow 详细模板 |

---

## 维护说明

### 新增一条规则

1. 创建 `.md` 文件到对应目录（`core/rules/` 或 `projects/*/rules/`）
2. 在 `core/registry.json` 的 `"rules"` 中注册路径

### 新增一个技能

1. 创建技能 `.md` 文件到 `core/skills/` 或 `projects/*/skills/`
2. 在 `core/registry.json` 的 `"skills"` 中注册
3. 在 `runtime/skill-map.md` 中添加匹配规则

### 新增一个 Agent

1. 创建 Agent 定义文件到 `core/agents/`
2. 在 `core/registry.json` 的 `"agents"` 中注册
3. 在 `runtime/agent-routing.md` 中添加路由规则

### 新增一个 Workflow

1. 在 `runtime/workflows/` 下创建 `{name}.workflow.md`
2. 结构参照 `workflow-protocol.md`：定义参与者（哪些模型）、步骤（每步谁执行）、输出格式
3. 在 `core/registry.json` 的 `"workflows"` 中注册
4. 在 `agent-routing.md` 的"规则 4: Workflow 触发条件"中添加触发规则
5. 在对应项目的 `CLAUDE.md` 的"多模型协作"章节中引用新 workflow

### 新增一个模型

1. 在 `core/registry.json` 的 `"models"` 中注册新模型
2. 在 `core/agents/` 中创建对应的 Agent 定义文件（如需要）
3. 在 `core/skills/general/model-switch.md` 中添加启动方式
4. 在 `runtime/agent-routing.md` 的 Agent 矩阵中添加新模型变体
5. 在 `runtime/agent-routing.md` 的复杂度自评规则中添加新模型的自评标准

---

## 使用规则

1. **禁止跨域扫描** — 处理后端问题只读 `core/` + `projects/webapi/`，不读 `pda/`
2. **禁止全项目 \*.cs grep** — 优先从 Controller 定位 Service，再定位 Repository
3. **优先查 skill 和 workflow** — 常见问题有标准排查流程
4. **Flash 先做，Pro 后审** — 遇到复杂问题主动创建 workflow 委托，不硬撑
5. **Workflow 文件即协议** — 所有模型间交互通过 `runtime/workflows/` 下的文件，不依赖外部工具
