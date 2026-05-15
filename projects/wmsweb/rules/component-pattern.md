# Rule: Component Pattern

## Scope

所有 `.vue` 文件

## Constraint

### 脚本规范
- 必须使用 Composition API + `<script setup>`
- 组件名通过 `setup name="xxx"` 或在文件级定义
- `import` 按顺序：Vue/第三方 → 组件 → API → Store → 工具

### 两套页面模式

**模式 A — 新架构（推荐新页面使用）**
- `@/lebg/components/` 体系：Search + Table + Container + HasPermiButton
- 表单/表格配置抽取到独立 `schemas.tsx` 文件
- 使用 `useTable` hook 管理列表状态
- 模块级事件通过 `mitt` event bus 通信

**模式 B — 传统模式（存量页面）**
- 直接使用 Element Plus 组件（el-table / el-form / el-dialog）
- 手动管理 `loading` / `dataList` / `total`
- 查询表单直接写在 SFC 模板中

### 列表页规范
- 分页必须携带 `pageNum` / `pageSize`
- 数据变更后重新调用查询
- `el-table` 列使用 `show-overflow-tooltip` 处理长文本
- 操作列固定右侧

### 弹窗规范
- 编辑/新增弹窗使用 `el-dialog` + `draggable`
- 弹窗关闭时重置表单：`resetForm()`
- 确认操作前二次确认：`ElMessageBox.confirm` / `proxy.$confirm`

## Forbidden

- 在同一页面混用两种模式（A + B）
- 视图层直接修改 Pinia state（必须走 action）
- 弹窗内容超过一屏不拆分
