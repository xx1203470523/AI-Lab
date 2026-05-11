# WebApi 项目上下文

> 对应项目：`IMTC.WMS.AdminWebApi`
> 技术栈：.NET 8 + Furion + SqlSugar + MiniExcel

## 核心结构
- `Presentation/Admin.WebApi/` — ASP.NET Core 宿主
- `Application.Admin/Controllers/` — 按模块分（System / InStock / OutStock / Report / BI）
- `Services.Warehouse/` — 核心 WMS 业务逻辑
- `Services.Report/` — 报表服务
- `Domain.Warehouse/` — 领域实体 + 仓储

## 相关文件
- 控制器基类：`Application.Contracts/ControllerAbstract.cs`
- SqlSugar ORM 配置：`Infrastructure.ORM/`
- 枚举定义：`Domain.Shared/Enums/`
