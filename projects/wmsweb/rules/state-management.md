# Rule: State Management

## Scope

所有状态管理（`src/store/` + 组件内状态）

## Constraint

### Pinia Store
- 每个独立领域创建一个 store：`src/store/modules/{domain}.js`
- 使用 `defineStore({ id: 'xxx', state, getters, actions })`
- 站点信息通过 `useSiteStore` 获取（`dictStore.siteConvert` 用于字典转换）
- 字典数据通过 `useDictStore` 统一管理，页面按需取 `dictStore.{dictName}Convert` / `dictStore.{dictName}Selected` 等
- 刷新信号通过 `useRefreshStore` 的 `popRefreshList(key)` 机制

### 组件本地状态
- 响应式数据用 `ref()` / `reactive()`
- 计算属性用 `computed()`
- `props` + `emit` 用于父子通信
- 跨级/跨模块通信用 `mitt` event bus（`import mitt from 'mitt'`）

### 权限控制
- 按钮级权限用 `v-hasPermi="['module:resource:action']"` 指令
- 新架构使用 `HasPermiButton` 组件：`<HasPermiButton :perms="[...]" />`
- 权限标识符格式：`{module}:{resource}:{action}`

## Forbidden

- 组件内直接修改 `useUserStore().permissions`
- 不使用 `defineStore` 创建 store
- 跨组件共享状态不使用 Pinia / mitt（禁止 props 透传多层）
