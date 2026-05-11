# API 设计规范

## 路由
- 格式：`[Route("module/resource")]`
- 资源名用复数或单数保持统一
- 版本化：`[Route("api/v1/resource")]`

## 响应格式
- 成功：`return Success(data)` → `{ code: 200, data: {...} }`
- 分页：`return Success(pageData)` → `{ code: 200, data: { rows: [...], total: N } }`
- 失败：`throw new CustomException("message")`

## 权限
- 接口加 `[ActionPermissionFilter(Permission = "module:resource:action")]`
- 审计日志：`[Log(Title = "...", OperationType = EOperationType.Xxx)]`

## 幂等
- 写操作（CUD）必须有幂等校验
- 导出操作加 Redis 锁防止重复提交
