# 执行流程定义

定义 AI 在接到用户输入后的完整执行链路。

## 标准流程

```
用户输入
  ↓
[Context Loader]     ← 加载 CLAUDE.md + 上下文
  ↓
[Registry 引擎]      ← 查 registry.json 匹配 skill / rule / agent
  ↓
[Skill Matcher]      ← 按 skill-map.md 规则匹配
  ↓
[Agent Selector]     ← 按 agent-routing.md 规则选择
  ↓
[Execution Engine]   ← 执行分析/审查/优化流程
  ↓
结构化输出
```

## Debug 流程

```
用户报 Bug
  ↓
加载 prompts/debug.md
  ↓
匹配 bug_analysis skill
  ↓
日志定位 → 数据追溯 → 代码走读 → 边界检查
  ↓
根因分析 + 修复建议
```

## 新增功能流程

```
用户要求新增功能
  ↓
加载 architect agent
  ↓
查项目 CLAUDE.md + rules
  ↓
设计变更方案（涉及文件、风险点）
  ↓
用户确认后实施
```
