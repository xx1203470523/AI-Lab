# Claude Code 工程化配置学习笔记

> 跨三个子项目（webapi / wmsweb / pda）的工程化配置经验汇总。
>
> 这里是**学习总结**，不是当前已启用配置。模板存放于 `core/.claude/skills/`、`projects/{webapi,wmsweb,pda}/.claude/{skills,hooks}/`，启用前请按 `core/.claude/hooks/README.md` 操作。

---

## 各子项目原生 Skill 适用场景

每个子项目都按 `base / gen / mod / rf` 四件套（PDA 多一个 `release`）组织，覆盖最高频的开发动作：

| 项目 | 共享 base 的关键约束 | gen 适合 | mod 适合 | rf 适合 |
|---|---|---|---|---|
| webapi | 分层、审计字段、SqlSugar、异常处理 | 新增实体/服务/Controller/DTO | 修 bug、调字段、改接口 | 拆 partial、提取方法 |
| wmsweb | 组件来源、页面模式、API 层、状态管理 | 新增页面/schema/API 文件 | 修页面、加字段、加按钮 | 拆组件、提 composable |
| pda | nvue、扫码、语音、焦点、页面注册 | 新增 PDA 页面/扫码流程 | 修扫码/提交/打印逻辑 | 拆页面、提取扫码处理 |
| pda（额外） | — | — | — | `release`：离线 APK 打包 |

完整业务链路（如调拨 allot-flow）也可以以原生 skill 形式存在，凭关键词稳定触发。静态参考资料（实体映射、外键链）放在 `quick-ref/`，约束类放在 `rules/`。

---

## Hook 适用判断

适合 hook 的规则需同时满足：高频 + 明确 + 可静态判断 + 误判成本可控。

### webapi（后端）

| 规则 | 事件 | 说明 |
|---|---|---|
| 禁止 `Task.WhenAll` 包数据库操作 | `PreToolUse(Edit/Write)` | MySQL/SqlSugar 连接风险明确 |
| 禁止 Application 层注入 Repository | `PreToolUse(Edit/Write)` | 分层违规可文本初筛 |
| 禁止 Services 层直接用 SqlSugarClient | `PreToolUse(Edit/Write)` | 强制走 Repository |
| 禁止硬删除 | `PreToolUse(Edit/Write)` | 项目默认软删除 |
| SqlSugar/Furion 知识库提醒 | `PreToolUse(Edit/Write)` | 适合提醒，不一定阻断 |

### wmsweb（前端）

| 规则 | 事件 | 说明 |
|---|---|---|
| 禁止修改 `backup/` 目录 | `PreToolUse(Edit/Write)` | 路径明确 |
| 禁止使用废弃组件目录 | `PreToolUse(Edit/Write)` | 路径或 import 检查 |
| 禁止 `getCurrentInstance()/proxy` | `PostToolUse(Edit/Write)` | 可做模式检查 |
| 编辑后 ESLint | `PostToolUse(Edit/Write)` | 单文件轻量检查 |

### pda（移动端）

| 规则 | 事件 | 说明 |
|---|---|---|
| 禁止新增普通 `.vue` 页面 | `PreToolUse(Edit/Write)` | PDA 要求 nvue，扩展名可判 |
| 禁止直接使用三方组件 | `PreToolUse(Edit/Write)` | 需走封装组件 |
| Stop 时提醒扫码验证项 | `Stop` | 如语音、焦点、错误反馈 |
| PostCompact 后重注入关键规则 | `PostCompact` | PDA 规则多，长会话易遗失 |

---

## Agent（深度审查）适用场景

Hook 只能阻断明确语法和路径违规；需要上下文判断的，留给 agent。

### webapi

- Controller 是否包含业务逻辑
- Service 是否返回 controller 类型
- 审计字段是否使用 `ToCreate/ToUpdate`
- SqlSugar 表达式中是否调用 C# 方法
- 是否使用 `DateTime.Now`
- 是否用 `Exception` 替代 `CustomException`
- DB 并发访问风险

### wmsweb

- 是否混用新旧页面模式
- 是否使用废弃组件路径
- 是否缺少 `defineOptions name`
- async loading 是否正确复位
- event bus 是否成对订阅和解绑

### pda

- 是否误用 `.vue` 而不是 `.nvue`
- 是否缺少扫码成功/失败语音反馈
- 扫码后是否回到输入焦点
- 是否在组件内弹窗替代页面导航
- 提交按钮是否有防重复提交机制

---

## 维护原则（贯穿三项目）

1. **静态参考资料**（实体映射、流程图、外键链、API 映射）→ `quick-ref/`
2. **AI 易踩坑约束** → `rules/`，靠 `prompt-rules-router.ps1` hook 按关键词路由触发
3. **高频流程** → `SKILL.md`（含 frontmatter），跨栈通用放 `core/.claude/skills/`，项目特定放 `projects/*/.claude/skills/`
4. **明确静态违规** → hook（先放 ai-lab 模板，再按需启用）
5. **复杂审查 / 第二视角** → agent
6. ai-lab 仅维护模板；启用时按需复制到 `~/.claude/`（个人）或真实项目 `.claude/`（团队共享）

不要跳过验证阶段：先记录 → 再归纳 → 再模板化 → 最后才自动化。
