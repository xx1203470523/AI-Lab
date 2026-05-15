# CLAUDE.md

## 项目身份

- **Project**: WMS PDA Mobile App
- **Stack**: UniApp (Vue 2 + Vuex) + uView UI + nvue
- **Build**: HBuilderX (无 CLI)，H5 dev 通过 manifest.json proxy
- **Scope**: 当前仓库仅负责 PDA 移动端，WebApi/AdminUI 为独立仓库

## Commands

PDA 项目通过 HBuilderX 构建，无可用的 CLI 命令。AI 在此项目中仅做代码阅读、分析与编辑，不执行 build/run。

## 入口

先判断任务复杂度，走对应链路：

### 简单任务（直接改，≤ 2 个文件定位）
单页面 UI 改动、加按钮、改样式、调文案、修 typo
→ 直接 Glob/Grep 定位目标文件，改完即止，**跳过 ai-lab**

### 复杂任务（先读 context-map）
新增页面/API、跨页面流程、业务逻辑变更、数据流调整、Bug 分析
→ 先读 `../ai-lab/projects/pda/context-map.md` 定位 rules/skills
→ 按需加载，一次 ≤ 3 个 ai-lab 文件
→ 禁止扫描 `../ai-lab/` 全目录

## 速查

| 场景              | 文件                                                     | 何时读 |
| ----------------- | -------------------------------------------------------- | ------ |
| 页面→API 映射     | `../ai-lab/projects/pda/quick-ref/entity-map.md`         | 新增 API 调用 |
| 业务操作数据流    | `../ai-lab/projects/pda/quick-ref/data-flows.md`         | 跨页面流程变更 |
| PDA 开发约束      | `../ai-lab/projects/pda/rules/01-pda-patterns.md`        | 新增页面/nvue 开发 |
| WMS 业务规范      | `../ai-lab/projects/wms/rules/wms-business.md`           | 出入库业务逻辑 |
| 防重复提交        | `../ai-lab/projects/wms/skills/repeat-submit-check.md`   | 提交类接口/按钮 |

## 回写

新增页面/API 调用后，在 entity-map.md 追加对应条目。发现新的数据链路后在 data-flows.md 补充。只写本次实际用到的路径，不推测不补充。
