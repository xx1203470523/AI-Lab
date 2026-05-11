# 架构规范

## 分层依赖
```
Controller → Service(接口) → Service(实现) → Repository → DB
```
- Controller 只做路由和参数校验，不写业务逻辑
- Service 层必须面向接口编程
- Repository 层只做数据访问，不做业务判断

## 项目分层
| 层 | 职责 |
|------|--------|
| Presentation | ASP.NET Core 宿主，Program.cs |
| Application | 控制器，Hub，定时任务，集成事件 |
| Services | 业务逻辑实现 |
| Domain | 实体定义，仓储接口/实现 |
| Infrastructure | ORM，缓存，JWT，日志 |

## DI 注册
- Service 用 `[AppService(ELifeTime.Scoped)]` 自动注册
- 模块启动用 `[AppStartup]` + `services.AddComponent<T>()`

## 事务
- 跨库事务用 `DBTransactionScope` / `DBTransactionScopeAsync`
- 单库事务用 SqlSugar `Ado.BeginTran`
