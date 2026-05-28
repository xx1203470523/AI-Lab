# Agents 配置学习笔记

## Purpose

本文记录 Claude Code agents 的用途、适用场景和维护边界。

Agent 适合做专项分析和第二视角审查，不适合替代 hooks 或 skills。

---

## 1. Agent 是什么

Agent 是 Claude Code 的专项子代理配置。

它通常用于：

- 代码审查。
- 安全审查。
- 大范围只读探索。
- 复杂问题的第二视角。
- 将主会话不适合承载的大量上下文隔离出去。

---

## 2. Agent、Hook、Skill 的区别

| 类型 | 触发方式 | 适合用途 |
|------|----------|----------|
| Hook | 自动触发 | 阻断、提醒、注入上下文 |
| Skill | 用户或模型调用 | 固定任务流程，如生成、修改、重构 |
| Agent | 主会话委派 | 深度分析、代码审查、跨文件检查 |

判断方式：

```text
要自动检查？用 hook。
要固定流程？用 skill。
要第二视角或深度审查？用 agent。
```

---

## 3. 适合 Agent 的场景

适合：

- Backend review。
- Frontend review。
- PDA review。
- Security review。
- 大范围代码定位。
- 对复杂改动做独立判断。

不适合：

- 简单文件读取。
- 单行修改。
- 明确可静态阻断的规则。
- 需要立即在工具调用前拦截的场景。

---

## 4. Review Agent 设计要点

一个好的 review agent 应包含：

- 目标项目和技术栈。
- 工作目录。
- 允许使用的工具。
- 审查重点。
- 输出格式。
- 是否需要读取项目规则。

示例审查重点：

```text
Backend:
- 分层违规
- 审计字段
- ORM 表达式
- DB 并发
- 异常类型

Frontend:
- 组件来源
- loading/error handling
- event bus 生命周期
- 类型与 schema 同步

PDA:
- nvue 页面
- 扫码语音
- 焦点回归
- 三方组件封装
```

---

## 5. ai-lab 中如何维护 Agent 经验

建议：

- 在 `core/standards/agents.md` 记录通用原则。
- 在 `projects/*/.claude/agents/` 未来保存项目级样本。
- 在 `projects/*/rules/` 维护审查规则来源。
- 不要把所有 review 细节写死在通用 agent 中。

原则：

```text
通用 agent 只写方法。
项目 agent 写项目风险。
业务知识仍在 ai-lab rules/quick-ref。
```
