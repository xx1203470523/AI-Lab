# Agent: deepseek-v4-pro

使用 DeepSeek v4 Pro 模型执行深度推理任务。

## 适用场景

- **代码审查** — 复杂逻辑审查、并发安全分析、数据一致性校验
- **性能优化** — SQL 深度优化、OOM 诊断
- **架构设计** — 跨模块方案、系统重构规划
- **疑难 Bug** — 多环节联动问题追踪

## 启动方式

```powershell
claude --model deepseek-v4-pro
```

## 加载内容

与 v4 Flash 共享全部上下文（registry.json + rules + skills + projects），无额外配置。
