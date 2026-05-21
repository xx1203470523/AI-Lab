# Controller Layer 规范

> 项目特定约束，通用 Controller/Route 模板不再重复。

## 命名空间陷阱

Controller 引用 Service 接口时，**以目标文件的 namespace 声明为准，禁止按物理文件夹路径猜测。** 详见 `02-service-layer.md` 命名空间陷阱章节。

## 基类

所有 Controller 继承 `ControllerAbstract`（定义在 `Application.Contracts`），提供：
- `Success(data)` / `Success()` — 成功响应
- `ToResponse(rows)` — 受影响行数
- 统一响应格式 `ApiResponse { Code, Msg, Data }`

## 权限与审计

- 鉴权格式：`{module}:{resource}:{action}`，如 `"system:user:list"`、`"instock:receipt:deapproval"`
- 接口鉴权使用 `[ActionPermissionFilter(Permission = "...")]` 特性，替代 Service 层内联角色校验
- 匿名接口标注 `[AllowAnonymous]`
- 操作审计标注 `[Log(Title = "...", OperationType = EOperationType.Xxx)]`

## 全局 Using

以下命名空间已在 `Application.Admin/GlobalUsing.cs` 中引入，Controller 无需重复 using：
`Services.Warehouse`、`Services.System`、`Services.Shared`、`Domain.Warehouse`、`Domain.System`、`Domain.Shared`、`Furion`、`SqlSugar`

## 响应约束

- 所有响应走 `Success()` / `ToResponse()` 统一封装，不直接 `return Ok()`
- 时间格式默认 `yyyy-MM-dd HH:mm:ss`
