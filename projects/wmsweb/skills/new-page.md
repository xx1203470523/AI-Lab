# Skill: New Business Page

## Trigger

- 新增业务模块页面
- 新增列表/表单页
- 新增 Tab 页签

## Goal

按规范创建完整的前端页面，保持代码风格一致

## Checklist

### 1. 路由配置
- `src/router/index.js` 添加路由记录（懒加载）
- path 格式：`/{module}/{resource}`
- meta.title / meta.icon 配置

### 2. API 文件
- `src/api/{module}/{resource}.js`
- CRUD 接口：list / get / add / update / del
- 导出具名函数

### 3. Store（需要时）
- `src/store/modules/{domain}.js`
- 仅跨组件共享数据才需要

### 4. 视图页面

**A — 新架构（推荐）**
- `views/{module}/index.vue` — 入口（Container + Tabs）
- `views/{module}/components/head/index.vue` — 列表（Search + Table）
- `views/{module}/components/head/schemas.tsx` — 表单/表格配置
- `views/{module}/event.ts` — 事件总线（mitt）

**B — 传统模式**
- `views/{module}/index.vue` — 入口
- 查询表单 → el-form + el-table
- el-dialog 弹窗处理新增/编辑

### 5. 权限标识
- 页面按钮添加 `v-hasPermi` / `HasPermiButton`
- 权限格式 `{module}:{resource}:{action}`

### 6. 验收清单
- 列表分页正常
- 查询条件有效
- 新增/编辑/删除数据后列表刷新
- 权限按钮按角色正确显示/隐藏

## Forbidden

- 路由不使用懒加载
- 视图内直接调用 axios
- 菜单/路由硬编码不与后端同步
