# Rule: Page Structure

## Scope

所有页面视图（`src/views/`）

## Constraint

### 目录组织
- 一个业务模块对应一个目录：`views/{module}/index.vue` 为入口
- 页面的子组件放 `views/{module}/components/`
- 模块级枚举常量放 `views/{module}/constants/` 或共享枚举 `src/enums/`

### 路由
- 路由懒加载：`component: () => import('@/views/{module}/index.vue')`
- 路由 name 与 path 保持一致
- 动态路由参数通过 `query` 传递

### 文件命名
- 视图文件：`kebab-case.vue`
- API 文件：`kebab-case.js` 或 `kebab-case.ts`
- 枚举文件：`PascalCase.ts`
- Store 文件：`camelCase.js`

## Forbidden

- 视图层文件超过 600 行（必须拆出子组件）
- 一个文件包含多个页面入口
- 路由 path 使用中文或大写
