---
name: push
description: "推送当前代码变更到远程仓库。自动基于main创建规范分支、生成提交备注、提交并推送。触发关键词：推送、push、提交推送、commit and push、推送代码、提交代码、上传代码"
shell: powershell
version: 2.0.0
---

# Push — 推送代码变更

> 安全地将当前工作区变更推送到远程仓库，遵循项目分支命名和提交规范，避免直接在 main 上提交。

## Trigger

用户要求推送代码、提交并推送变更到远程仓库时触发。

## Workflow

### Step 1: 检查前置条件

- [ ] 当前在 git 仓库中
- [ ] 有未提交的变更（`git status` 有 modified 或 untracked 文件）
- [ ] 远程仓库 `origin` 可访问
- [ ] 当前不在 main/master/production/staging 分支上直接操作（如在这些分支上，先提醒用户确认）

### Step 2: 确定分支名称

根据改动类型选择分支前缀，参考 `git log --oneline -20` 已有风格：

| 改动类型  | 分支前缀       | 示例                                 |
| --------- | -------------- | ------------------------------------ |
| 新功能    | `feature/lyp/` | `feature/lyp/instock_search_enhance` |
| Bug修复   | `fix/lyp/`     | `fix/lyp/receipt_date_null`          |
| 维护/工具 | `chore/lyp/`   | `chore/lyp/update_skill_config`      |

命名规则：kebab-case（小写英文+连字符），简明描述改动内容。

### Step 3: 创建分支并变基到 main

```
git checkout -b {branch-name}      # 从当前位置创建新分支（保留未提交改动）
git fetch origin main
git rebase origin/main             # 变基到最新 main
```

### Step 4: 冲突处理

- `rebase` **成功** → 继续 Step 5
- `rebase` **有冲突** → 执行 `git rebase --abort` 还原，提示用户："变基到 main 时有文件冲突，请手动解决"

### Step 5: 提交

**范围控制**：仅提交当前对话任务涉及的代码变更。工作区中与当前任务无关的改动不纳入本次提交。

提交信息遵循 Conventional Commits（中文），正文用 `- ` 列表逐条列出改动：

```
type: 简短总结

- 改动项1
- 改动项2
```

类型：`feat` 新功能 / `fix` 修复 / `chore` 维护

**提交备注尾部禁止添加 Claude 共同作者签名**：不要在提交信息末尾追加任何 Co-Authored-By 行，包括 Claude Opus 4.7 的 noreply 签名。

**提交命令禁止使用 here-string 写法**：不要使用带 at 符号包裹的多行提交信息写法；示例和实际命令都必须避免该符号。

示例：

```
git add {具体文件}
git commit -m "fix: 入库标签UnitName记录单位编码而非单位名称" -m "- BuildLabelprintEntity 中 UnitName/UnitCode 改为从 BaseMaterial 取值`n- 修复 SponsorStockRejectionService 同类问题"
```

### Step 6: 推送

```
git push -u origin {branch-name}
```

推送成功后报告：分支名、提交 hash、推送结果。

## Forbidden

- 不要在 main/master/production/staging 分支上直接提交
- 不要一次推送多个不相关任务的改动，每次推送仅对应一个任务/主题
- 不要提交当前任务范围外的代码变更
- 不要使用 `git add -A` / `git add .`
- 不要使用 `--force` 推送
- 不要跳过 git hooks（`--no-verify`、`--no-gpg-sign`）
- 不要提交包含 secrets/credentials 的文件
