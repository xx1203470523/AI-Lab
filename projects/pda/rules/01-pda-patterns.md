# PDA 开发约束

> 仅记录 AI 无法从训练数据得知、且容易踩坑的约束。
> 不写 Vue/UniApp 通用知识。

## pages.json 路由注册

- 所有页面路径必须在 `pages.json` 中注册，否则编译不通过
- `navigationStyle: "custom"` 是 nvue 页面的强制要求，不可省略
- easycom 自动注册 `components/thorui/`、`components/hmx/`、`components/nvue/` 下的组件
- TabBar 只有两个：工作台(work)、我的(mine)，不要新增 tab

## nvue 限制

- nvue 不支持 CSS 百分比、vw/vh 单位，使用 rpx 或固定 px
- nvue 不支持 `display: flex` 以外的布局（默认 flex）
- nvue 不支持 DOM 操作（`document.xxx` 全部不可用）
- nvue 中 `<text>` 必须包裹文本内容，不能直接用裸文本
- nvue 不支持 webview 组件和大部分 HTML 标签
- 新页面优先用 `.nvue`（原生渲染性能好），纯展示/H5页面才用 `.vue`

## request.js 使用注意

- 所有请求通过 `utils/request.js` 的 `get/post/put/del/upload` 发起，不要直接用 `uni.request`
- 请求自动携带 token、site、device=PDA、traceId、timezone、timestamp、version 头
- 401 时自动弹出重新登录 modal（单次会话 debounce），不需要页面手动处理
- 业务错误自动 toast + 错误语音（voice-utils.js），不需要页面手动提示
- 第三个参数可传 `{ hideLoading: true }` 隐藏 loading 动画
- Idempotent 方法（GET/HEAD/OPTIONS）网络错误时自动重试（指数退避），POST/PUT/DELETE 不重试

## 标签解析

- 扫描的标签字符串通过 `mixins/global.js` 的 `explainLabel()` 解析
- 标签格式：`MaterialCode#Feature#Qty#ProjectNo#PurchaseNo#PurchaseItem#DeliverNo#DeliverItem#SN#SerialNo`
- 有两套解析规则：9 段（旧版兼容）和 10 段（当前标准）
- 修改标签解析逻辑时必须兼容两套规则
- 不要在各页面中自行解析标签，统一走 `explainLabel()`

## 蓝牙扫描

- `utils/bluetooth.js` 封装了 Android 蓝牙扫描能力
- 仅 Android 设备可用，iOS 和 H5 环境不支持
- 不要在各页面中直接调用蓝牙 API，统一走 bluetooth.js

## 动态菜单

- 工作台菜单通过 `api/system/menu.js` → `getRouters()` 动态加载
- 菜单树在后端配置，PDA 只取 `pda` 根节点下的菜单
- 新增页面需要显示在菜单中，必须通过后端菜单系统配置（meta.link = 页面路径）
- 不要在 PDA 前端写死菜单项

## 语音提示

- 错误语音通过 `utils/voice-utils.js` → `playErrorVoicePDAVoice()` 播放
- request.js 已集成，API 报错时自动播放，页面无需额外调用
- 仅 PDA 设备有效，H5 环境为 no-op

## 页面跳转

- 统一使用 `utils/navigator.js` 的 `navigateToPage`、`redirectToPage`、`reLaunchPage`
- 自动检测目标页面是否在 tabbar 中，tab 页自动用 `switchTab`
- 不要直接用 `uni.navigateTo` / `uni.redirectTo` 等

## 字典数据

- 字典在 App 启动时通过 `store/modules/dict/` 加载
- 页面中使用字典数据通过 Vuex store 读取，不要重复请求字典接口
- 字典缓存生命周期跟随 App 会话，切换站点后需重新加载

## 环境配置

- `config.js` 中的 `baseUrl` 可在运行时被 `store.state.app.apiUrl` 覆盖
- 切换环境通过注释/取消注释 `config.js` 中的代码块实现
- 不要在多处定义 baseUrl，统一走 config.js
