# CLAUDE.md

## 项目身份

- **Project**: WMS PDA Mobile App
- **Stack**: UniApp (Vue 2 + Vuex) + uView UI + nvue + HBuilderX
- **Scope**: 当前仓库仅负责 PDA 移动端，WebApi/AdminUI 为独立仓库

## Commands

PDA 项目通过 HBuilderX IDE 构建运行，无可用的 CLI 命令。AI 在此项目中仅做代码阅读、分析与编辑。

- **HBuilderX**: Open project → Run → Android/iOS device or emulator
- **H5 dev**: `manifest.json` → `h5.devServer` (port 11103, proxy → 11100)
- **App version**: Update `manifest.json` → `versionName` / `versionCode`

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

## 关键约束

- nvue 页面必须 `navigationStyle: "custom"`，不支持 DOM/CSS %
- 所有 HTTP 请求走 `utils/request.js`，不直接用 `uni.request`
- 标签解析统一走 `mixins/global.js` → `explainLabel()`，不要各页面自行解析
- 页面跳转统一走 `utils/navigator.js`，不直接用 `uni.navigateTo`
- 菜单由后端动态加载，不在前端硬编码
- 新增页面必须在 `pages.json` 注册

## 回写

新增页面/API 后在 `../ai-lab/projects/pda/quick-ref/entity-map.md` 追加条目。发现新数据链路后在 `data-flows.md` 补充。只写本次实际用到的路径。
