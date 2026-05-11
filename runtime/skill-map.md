# Skill 匹配规则

定义 AI 如何根据用户输入匹配对应的 Skill。

## 匹配逻辑

```
用户输入
  → 识别领域（WMS / PDA / WebApi / System）
  → 识别意图（query / review / optimize / debug / new）
  → 查 registry.json 找到对应 skill(s)
  → 加载 skill 文件中的流程
  → 按需加载关联 rules 和 agents
```

## 领域-意图映射

| 领域 | 意图 | Skill |
|------|------|-------|
| WMS-出库 | 扣库存检查 | stock_consistency |
| WMS-PDA | 重复提交 | repeat_submit_check |
| WMS-PDA | 数据同步 | pda_sync_check |
| WebApi-报表 | 新增 | new_report |
| WebApi-报表 | 调试 | debug_report |
| WebApi-代码 | 审查 | dotnet_service_review |
| 全局 | SQL优化 | sql_optimize |
| 全局 | Bug分析 | bug_analysis |
