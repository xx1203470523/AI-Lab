# Agent 路由规则

定义 AI 如何选择 Agent。

## Agent 职责

| Agent | 触发条件 | 加载内容 |
|-------|----------|----------|
| reviewer | 代码审查、PR检查 | concurrency.md + api-design.md + dotnet-service.md |
| architect | 架构决策、模块设计 | architecture.md + 项目 CLAUDE.md |
| sql_expert | 慢查询、OOM、索引优化 | sql.md + optimize.md + index-check.md |

## 选择优先级

1. 如果用户明确指定 → 直接使用指定 Agent
2. 如果涉及代码变更 → reviewer
3. 如果涉及架构/设计 → architect
4. 如果涉及性能 → sql_expert
5. 多领域问题 → reviewer + sql_expert 联合分析
