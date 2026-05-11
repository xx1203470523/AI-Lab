# Controller Layer (控制器层) 规范

> 对应项目：`Application.Admin`
> 物理位置：`Application/Application.Admin/Controllers/`

## 目录结构

```
Application.Admin/Controllers/
  System/
    SysUserController.cs
    SysRoleController.cs
    SysMenuController.cs
    SysLoginController.cs
    ...
  InStock/
    InStockAsnController.cs
    InstockReceiptController.cs
    InStockUpShelvesController.cs
    InStockUpShelvesPDAController.cs
    ...
  OutStock/
    OutStockPickOrderController.cs
    OutStockDeliveryController.cs
    OutStockShipmentController.cs
    ...
  Report/
    InStockReportController.cs
    OutStockReportController.cs
    InventoryReportController.cs
    CheckReportController.cs
    TransferReportController.cs
    ...
  BI/
    BIController.cs
  Common/
    CommonController.cs
    PrinterController.cs
```

## Controller 基类

所有控制器继承 `ControllerAbstract`（定义在 `Application.Contracts`）：

```csharp
public abstract class ControllerAbstract : ControllerBase
{
    protected IActionResult Success(object data);
    protected IActionResult Success();
    protected IActionResult ToResponse(ApiResponse apiResult);
    protected IActionResult ToResponse(EResultCode resultCode, string msg);
    protected IActionResult ToResponse(long rows);
    protected ApiResponse ToJson(long rows);
    protected ApiResponse GetApiResult(EResultCode resultCode, object? data = null);
    protected string ExportExcel<T>(List<T> list, string sheetName, string fileName);
}
```

## Controller 标准模板

```csharp
namespace Application.Admin.Controllers.Report;

[Route("report/instock")]
[ApiController]
[ActionPermissionFilter(Permission = "report:instock:list")]
public class InStockReportController : ControllerAbstract
{
    private readonly IInStockOrderReportService _reportService;

    public InStockReportController(IInStockOrderReportService reportService)
    {
        _reportService = reportService;
    }

    [HttpGet("getOrderList")]
    public async Task<IActionResult> GetInStockOrderListAsync([FromQuery] InStockOrderReportQueryDto parm)
    {
        return Success(await _reportService.GetInStockOrderPagedDataAsync(parm));
    }

    [HttpGet("exportOrderList")]
    public async Task<IActionResult> GetInStockOrderListExportAsync([FromQuery] InStockOrderReportQueryDto parm)
    {
        var newFileName = await _reportService.InStockOrderExportAsync(parm);
        return Success(new { path = "/export/" + newFileName, fileName = newFileName });
    }
}
```

## 命名约束

| 元素 | 约定 | 示例 |
|------|------|------|
| Controller 类 | `{Module}Controller` | `InStockReportController` |
| 路由前缀 | `{area}/{module}` | `[Route("report/instock")]` |
| 查询方法 | `GetXxxAsync` | `GetInStockOrderListAsync` |
| 导出方法 | `GetXxxExportAsync` | `GetInStockOrderListExportAsync` |
| 查询参数 | `[FromQuery]` | `[FromQuery] InStockOrderReportQueryDto parm` |

## 命名空间与 Using

### 全局 Using

以下命名空间已在 `Application.Admin/GlobalUsing.cs` 中全局引入，**Controller 无需重复 using**：

| 全局 Using | 覆盖内容 |
|------------|----------|
| `Services.Warehouse` | 大部分 Service 接口（`ICommonQueueAutoPostService`、`INoticeService` 等） |
| `Services.System` | System 相关 Service |
| `Services.Shared` | 共享 Service |
| `Services.Scheduler` | 调度相关 Service |
| `Domain.Warehouse` | WMS 领域实体 |
| `Domain.System` | System 领域实体 |
| `Domain.Shared` | 共享基类（`EntityAbstract`、枚举等） |
| `Furion` | Furion 框架 |
| `SqlSugar` | ORM |

### 命名空间陷阱

**Service 接口的物理文件夹路径 ≠ C# 命名空间。**

```
物理路径:  Services/Services.Warehouse/Services/Interfaces/AutoPost/IAutoPostService.cs
实际命名空间: namespace Services.Warehouse;                        ← 扁平！

物理路径:  Services/Services.Warehouse/Services/Interfaces/InStock/UpShelves/IInStockUpShelvesNoticeService.cs
实际命名空间: namespace Services.Warehouse.Services.Interfaces.InStock;  ← 深层（例外）
```

**规则：添加 using 时必须以实际 `namespace` 声明为准，禁止按文件夹路径猜测。**

验证方法：
1. 打开目标接口文件，查看第一行 `namespace xxx;`
2. 如果已在 `GlobalUsing.cs` 中，无需重复 using
3. 如果不在，按实际命名空间添加 using

## 权限与审计

```csharp
[ActionPermissionFilter(Permission = "system:user:list")]
[HttpGet("list")]
public IActionResult List(...)

[Log(Title = "登录", OperationType = EOperationType.Login)]
[HttpPost("login")]
[AllowAnonymous]
public async Task<IActionResult> LoginAsync(...)
```

**约束：**
- 需要权限控制的接口标注 `[ActionPermissionFilter(Permission = "...")]`
- 鉴权格式：`{module}:{resource}:{action}`
- 匿名接口标注 `[AllowAnonymous]`
- 操作审计标注 `[Log(Title = "...", OperationType = ...)]`

## 响应规范

```csharp
return Success(data);                                          // 成功返回数据
return Success(await _service.GetPagedDataAsync(parm));        // 分页返回
return Success(new { path, fileName });                        // 导出返回文件路径
return ToResponse(rows);                                       // 受影响行数
```

**约束：**
- 所有响应走 `Success()` / `ToResponse()` 统一封装，不直接 `return Ok()`
- 响应格式统一为 `ApiResponse { Code, Msg, Data }`
- 时间格式默认 `yyyy-MM-dd HH:mm:ss`
