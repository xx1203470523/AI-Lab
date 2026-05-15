# Rule: API Layer

## Scope

所有 API 调用（`src/api/` + 视图层中的请求）

## Constraint

### API 文件约定
- 一个业务模块对应一个 API 文件：`src/api/{module}/{resource}.js`
- 每个接口导出一个具名函数
- 统一使用 `import request from '@/utils/request'`
- URL 路径与后端路由一致：`{module}/{resource}/{action}`

### 请求方法
- 查询（列表/详情）：`method: 'get'` + `params`
- 新增：`method: 'post'` + `data`
- 修改：`method: 'PUT'` + `data`
- 删除：`method: 'delete'` + URL 参数

### 响应处理
- 检查 `res.code == 200` 判断成功
- 列表数据取 `res.data.result` + `res.data.totalNum`
- 分页参数名：`pageNum` / `pageSize`
- 排序参数名：`sort` / `sortType`

## Forbidden

- 视图层直接 `import axios` 调用
- 不通过 API 文件直接写 URL 字符串
- `params` 和 `data` 混用（get 用 params，post/put 用 data）
