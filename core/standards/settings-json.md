# settings.json 配置学习笔记

## Purpose

本文记录 Claude Code `settings.json` 的用途、分层方式和维护边界。

ai-lab 中的 settings 说明只作为学习资料。真实项目只有把配置放到对应项目的 `.claude/settings.json` 后才会生效。

---

## 1. settings.json 是什么

`settings.json` 是 Claude Code 的项目级运行配置入口。

它常用于：

- 配置工具权限，减少重复授权。
- 注册 hooks，让 Claude Code 在特定事件自动执行脚本。
- 区分根项目和子项目的运行约束。
- 将团队共识从“文字提醒”升级为“运行时提醒或阻断”。

---

## 2. settings 与 ai-lab 的关系

```text
ai-lab             按需加载，记录知识和配置经验
.claude/settings   放到真实项目目录下才会生效
```

因此：

- ai-lab 可以保存 `settings.sample.json` 作为学习副本。
- ai-lab 不应保存个人 `settings.local.json`。
- ai-lab 中的样本不会自动影响真实项目。
- 复制样本到真实项目时，必须重新检查路径、权限和 hook 行为。

---

## 3. 常见配置区域

| 配置 | 用途 |
|------|------|
| `permissions.allow` | 允许的工具或命令白名单 |
| `hooks.SessionStart` | 会话开始注入上下文 |
| `hooks.UserPromptSubmit` | 用户提交提示词后注入提示 |
| `hooks.PreToolUse` | 工具执行前检查或阻断 |
| `hooks.PostToolUse` | 工具执行后检查 |
| `hooks.Stop` | 回合结束前检查 |
| `hooks.PostCompact` | 上下文压缩后重新注入约束 |

---

## 4. 根项目与子项目分层

适合 monorepo 的模式：

```text
根项目 .claude/settings.json
  放跨项目通用约束
  例如：Bash 嵌套 PowerShell 拦截、任务日志检查

子项目 .claude/settings.json
  放项目特定约束
  例如：后端分层检查、前端 lint、PDA .nvue 约束
```

优点：

- 通用规则只维护一份。
- 子项目可以按技术栈增加自己的 hooks。
- 约束作用域更清晰。

风险：

- 相对路径容易出错。
- 子项目移动目录后 hooks 可能失效。
- 不同项目 settings 版本可能漂移。

---

## 5. permissions.allow 维护原则

权限白名单只给最小必要能力。

适合放入公共 settings 的：

- 高频只读命令。
- 项目常用构建/检查命令。
- 明确安全的工具权限。

不适合直接放开的：

- 删除文件或目录。
- force push / reset hard / clean。
- 修改全局 git config。
- 带账号、token、私有路径的命令。
- 个人偏好命令。

建议：

```text
公共 settings.json     放团队共识
settings.local.json     放个人偏好，不进入 ai-lab
```

---

## 6. 什么时候值得写进 settings

适合：

- 团队已经反复踩坑。
- 规则稳定，短期不会变化。
- 能通过 hook 或权限配置表达。
- 误判成本可接受。

不适合：

- 还在试验的 prompt。
- 只对个人有用的习惯。
- 临时任务配置。
- 业务含义复杂、无法静态判断的规则。

---

## 7. 使用建议

从轻量到工程化时，建议顺序：

```text
1. 先在 ai-lab 记录规则和原因。
2. 多次复用后，再做 settings.sample.json。
3. 在真实项目中先启用提醒型 hook。
4. 验证稳定后，再升级为阻断型 hook。
5. 定期回看 settings，删除过期配置。
```
