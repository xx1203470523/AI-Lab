# Agent 路由规则

定义 AI 如何根据任务选择 Agent，以及何时触发跨模型协作。

## Agent 矩阵

| Agent | 模型 | 适用场景 | 加载内容 |
|-------|------|----------|----------|
| reviewer | v4 Flash | 日常代码自查（提交前快速扫描） | concurrency.md + api-design.md + dotnet-service.md |
| v4pro_reviewer | v4 Pro | 深度代码审查（PR 合并前）、安全审计 | 同上 + v4-pro.md |
| architect | v4 Flash | 需求梳理、现有架构定位 | architecture.md + 项目 CLAUDE.md |
| v4pro_architect | v4 Pro | 复杂方案设计、重构规划 | 同上 + v4-pro.md |
| sql_expert | v4 Flash | 常规 SQL 优化建议、索引检查 | sql.md + optimize.md + index-check.md |
| v4pro_sql_expert | v4 Pro | OOM 诊断、执行计划深度分析 | 同上 + v4-pro.md |
| debugger | v4 Flash | 日志收集、初步定位、复现步骤整理 | debug.md |
| v4pro_debugger | v4 Pro | 疑难 Bug 根因分析、多环节联动追踪 | debug.md + v4-pro.md |

## 选择规则

### 规则 1：用户显式标记优先

```
用户输入含 [v4pro] → 使用 v4 Pro 变体 agent
用户输入含 [quick]  → 使用 v4 Flash 变体 agent
```

### 规则 2：按任务类型自动匹配

| 任务类型 | 默认 Agent | 触发关键词 |
|----------|-----------|------------|
| 代码审查（自检） | reviewer | "检查一下这段代码"、"review 一下" |
| 代码审查（合并前） | v4pro_reviewer | "严格审查"、"上线前检查"、"PR 审查" |
| 架构咨询 | architect | "这个怎么设计"、"放在哪个模块" |
| 架构方案评审 | v4pro_architect | "重构方案"、"系统设计"、"技术选型" |
| SQL 优化 | sql_expert | "查询慢"、"优化 SQL" |
| OOM / 深度性能 | v4pro_sql_expert | "OOM"、"内存溢出"、"CPU 飙高" |
| Bug 定位 | debugger | "报错了"、"不生效"、"Bug" |
| 疑难 Bug | v4pro_debugger | "偶发 Bug"、"生产问题"、"数据不一致" |

### 规则 3：多领域联合分析

当问题跨多个领域时，按优先级加载多个 Agent 的规则：

```
"报表导出 OOM 且有并发问题"
  → v4pro_sql_expert + v4pro_reviewer 联合
  → 加载 sql.md + optimize.md + concurrency.md + report-module.md
```

### 规则 4：Workflow 触发条件（用户决定）

Workflow 是**可选工具**，由用户决定是否使用。AI 不自动创建、不强制推动。

以下情形 AI 可**简短建议**，最终由用户拍板：

| 情形 | 当前模型 | 建议委托给 | Workflow 类型 |
|------|----------|------------|---------------|
| 涉及库存并发扣减、多表事务 | Flash | Pro | code-review |
| 复杂 SQL（5+ JOIN，>100w 数据） | Flash | Pro | performance |
| 跨模块架构变更（>3 个模块） | Flash | Pro | architecture |
| 方案定稿后大量代码落地 | Pro | Flash | architecture step 5 |
| 审查后需按报告修改 | Pro | Flash | code-review step 3 |

**不重要/简单的任务不建议创建 workflow**，在当前会话完成即可。

### 规则 5：复杂度自评

AI 在处理任务时，可参考以下标准判断是否需要**建议**委托：

```
v4 Flash 参考：
  - 涉及 > 3 个表的并发一致性 → 可建议委托 Pro
  - SQL 涉及 > 5 个 JOIN 且数据量 > 100w → 可建议委托 Pro
  - 跨模块架构决策（影响 > 3 个模块）→ 可建议委托 Pro
  - 简单的代码修改、单表查询优化 → 自己处理，不建议

v4 Pro 参考：
  - 大量重复性代码编写 → 可建议委托 Flash
  - 简单 CRUD 接口 → 可建议委托 Flash
  - 需要快速修复的低风险 Bug → 可建议委托 Flash
```

## 路由流程图

```
用户输入
  ↓
是否有 [v4pro] / [quick] 标记？
  ├── 有 → 直接选择对应 Agent
  └── 无 → 按任务类型匹配（规则 2）
            ↓
        是否跨领域？
          ├── 是 → 联合加载多个 Agent 规则（规则 3）
          └── 否 → 单一 Agent
                    ↓
                当前模型是否胜任？
                  ├── 是 → 直接执行
                  └── 否 → 建议创建 workflow 委托另一模型（规则 4）
```
