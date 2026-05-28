# Permissions 配置学习笔记

## Purpose

本文记录 Claude Code `permissions.allow` 的维护原则。

权限配置用于减少重复授权，但过度放开会扩大误操作范围。

---

## 1. permissions.allow 是什么

`permissions.allow` 用于允许某些工具或命令在项目中直接执行，减少交互确认。

常见例子：

```text
PowerShell(git *)
PowerShell(pnpm *)
PowerShell(dotnet build *)
WebSearch
WebFetch(domain:example.com)
```

---

## 2. 配置原则

```text
最小权限 + 项目相关 + 可解释
```

适合放入：

- 高频只读命令。
- 项目常用构建/检查命令。
- 明确安全的查询命令。
- 特定可信域名的 WebFetch。

不适合放入：

- 删除文件或目录。
- `git reset --hard`、`git clean`、force push。
- 修改全局配置。
- 带 token、账号、私有路径的命令。
- 个人临时习惯。

---

## 3. 公共配置与本地配置

| 文件 | 用途 |
|------|------|
| `settings.json` | 团队共享配置，应该克制 |
| `settings.local.json` | 个人本地配置，不应进入 ai-lab 或仓库 |

ai-lab 可以记录权限策略，但不要保存个人 allowlist。

---

## 4. 按项目选择

Backend 常见：

- `PowerShell(git *)`
- `PowerShell(dotnet build *)`
- `PowerShell(dotnet test *)`

Frontend 常见：

- `PowerShell(pnpm *)`
- `PowerShell(npx eslint *)`
- `PowerShell(npx vue-tsc *)`

PDA 常见：

- `PowerShell(git *)`
- 特定 DCloud 文档域名的 `WebFetch`

实际是否允许，应按项目风险和团队习惯决定。

---

## 5. 维护建议

- 新增 allow 前先确认是否高频。
- 对 destructive 命令保持手动确认。
- 定期清理不再使用的 allow 项。
- 不把权限配置当作绕过安全提示的手段。
