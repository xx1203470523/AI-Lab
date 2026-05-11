# Service Layer (服务层) 规范

> 对应项目：`Services.Warehouse`, `Services.Report`, `Services.BI`, `Services.System` 等
> 物理位置：`Services/` 目录下

## 命名空间约定

**Service 层绝大多数使用扁平命名空间 `Services.Warehouse`，物理文件夹仅用于组织，不影响命名空间。**

```
物理路径:  Services/Services.Warehouse/Services/Interfaces/AutoPost/IAutoPostService.cs
命名空间:   namespace Services.Warehouse;              ← 扁平（大多数）

物理路径:  Services/Services.Warehouse/Services/Implementations/AutoPost/AutoPostService.cs
命名空间:   namespace Services.Warehouse;              ← 扁平（大多数）

物理路径:  Services/Services.Warehouse/AutoPost/SceneAutoInStockService.cs
命名空间:   namespace Services.Warehouse;              ← 扁平（大多数）
```

**少数例外使用深层命名空间**（历史遗留）：

```
IInStockUpShelvesNoticeService  →  namespace Services.Warehouse.Services.Interfaces.InStock;
IErpIQCResultSyncService       →  namespace Services.Warehouse.Interfaces.Sync;
IMatchMakingService             →  namespace Services.Warehouse.Services.Interfaces.Fix;
IBaseUrgencyMaterialChargeService → namespace Services.Warehouse.Services.Interfaces.Base;
```

**规则：**

1. **新代码一律使用 `namespace Services.Warehouse;`（扁平），不按文件夹建深层命名空间**
2. **添加 using 时必须以目标文件的实际 `namespace` 声明为准，禁止按文件夹路径猜测**
3. `Application.Admin/GlobalUsing.cs` 已全局引入 `Services.Warehouse`，覆盖大多数接口，Controller 无需额外 using
4. 如需引用深层命名空间的接口（如上表例外），需在 Controller 中显式 `using`

验证方法：
```
找到目标接口文件 → 读第一行 namespace xxx; → 按实际写 using
```

## 目录结构

```
Services.Report/
  Dtos/                            — 数据传输对象
    InStockOrderReportDto.cs       — 响应DTO
    InStockOrderReportExportDto.cs — 导出DTO（带 [DisplayName]）
    OutStockOrderReportDto.cs      — 包含 QueryDto + PagedQueryDto + ExportDto
  Services/
    Interfaces/                    — 服务接口
      IInStockOrderReportService.cs
      IOutStockOrderReportService.cs
    Implementations/               — 服务实现
      InStockOrderReportService.cs
      OutStockOrderReportService.cs
  GlobalUsing.cs
```

## DTO 规范

### 三件套模式

每个报表/功能通常有三个DTO：

```csharp
// 1. 响应DTO：返回给前端的数据结构
public class InStockOrderReportDto
{
    public long ReceiptId { get; set; }
    public string? ReceiptNo { get; set; }
    public string? SupplierName { get; set; }
    // ... 业务字段
}

// 2. 查询DTO：分页查询参数（继承 PagerQuery）
public class InStockOrderReportQueryDto : PagerQuery
{
    public string? ReceiptNo { get; set; }
    public int[]? BusinessType { get; set; }
    public DateTime? StartTime { get; set; }
    public DateTime? EndTime { get; set; }
}

// 3. 导出DTO：Excel导出专用（带 [DisplayName] 特性）
public class InStockOrderReportExportDto
{
    [DisplayName("收货单号")]
    public string ReceiptNo { get; set; }

    [DisplayName("创建时间")]
    [ExcelFormat("yyyy-MM-dd HH:mm:ss")]
    public DateTime? CreateOn { get; set; }
}
```

**约束：**
- 响应DTO属性尽量使用 `nullable` 类型（`string?`、`DateTime?`）
- 查询DTO集成 `PagerQuery` 自动获得 `PageNum` / `PageSize` 分页参数
- 导出DTO使用 `DisplayName`（MiniExcel 识别）而非 `Description`
- 时间字段用 `[ExcelFormat("yyyy-MM-dd HH:mm:ss")]` 标注
- 所有DTO类集中在 `Dtos/` 目录下（按模块分文件）

## 接口规范

```csharp
/// <summary>
/// 入库报表接口
/// </summary>
public interface IInStockOrderReportService
{
    /// <summary>
    /// 获取入库单综合报表（分页）
    /// </summary>
    Task<PagedInfo<InStockOrderReportDto>> GetInStockOrderPagedDataAsync(InStockOrderReportQueryDto parm);

    /// <summary>
    /// 入库综合报表导出
    /// </summary>
    Task<string> InStockOrderExportAsync(InStockOrderReportQueryDto parm);
}
```

**命名约束：**
- 接口以 `I` 开头，以 `Service` 结尾
- 方法名采用 `GetXxxPagedDataAsync`（分页查询）/ `XxxExportAsync`（导出）
- 返回分页数据统一用 `Task<PagedInfo<T>>`
- 返回导出文件路径统一用 `Task<string>`

## 实现规范

### DI 注册

```csharp
[AppService(ELifeTime.Scoped)]   // 或用 ITransient / ISingleton 接口标记
public class InStockOrderReportService : IInStockOrderReportService, ITransient
```

**约束：**
- 必须标记 `[AppService(ELifeTime.Scoped)]` 或实现 `ITransient`/`ISingleton` 接口
- 默认使用 `Scoped` 生命周期

### 构造函数注入

```csharp
public class InStockOrderReportService : IInStockOrderReportService, ITransient
{
    private readonly InStockReceiptHeadRepository _inStockReceiptHeadRepository;
    private readonly ICachingService _cachingService;

    public InStockOrderReportService(
        InStockReceiptHeadRepository inStockReceiptHeadRepository,
        ICachingService cachingService)
    {
        _inStockReceiptHeadRepository = inStockReceiptHeadRepository;
        _cachingService = cachingService;
    }
}
```

### 分页查询标准模式

```csharp
public async Task<PagedInfo<InStockOrderReportDto>> GetInStockOrderPagedDataAsync(InStockOrderReportQueryDto parm)
{
    // 1. 构建基础查询（多表 Join）
    var baseQuery = _repository.Queryable()
        .LeftJoin<OtherEntity>((a, b) => a.ForeignKey == b.Id);

    // 2. 查询条件过滤（使用 WhereIF）
    baseQuery = baseQuery
        .WhereIF(!string.IsNullOrEmpty(parm.ReceiptNo), a => a.ReceiptNo.StartsWith(parm.ReceiptNo))
        .WhereIF(parm.StartTime.HasValue, a => a.CreateOn >= parm.StartTime)
        .WhereIF(parm.EndTime.HasValue, a => a.CreateOn < parm.EndTime);

    // 3. Select 投影 + 分页
    var pageData = await baseQuery
        .Select((a, b) => new InStockOrderReportDto
        {
            ReceiptId = a.Id,
            ReceiptNo = a.ReceiptNo
        })
        .ToPageAsync(parm);   // 自动分页

    // 4. 补充数据（字典映射）
    // 查询关联表补充展示字段

    // 5. 后处理
    foreach (var item in pageData.Result)
    {
        // 状态枚举转换、人员名称映射等
    }

    return pageData;
}
```

### 导出标准模式

```csharp
public async Task<string> InStockOrderExportAsync(InStockOrderReportQueryDto parm)
{
    // 1. 防重复导出锁
    var lockKey = $@"ReportName:ExportAsync:" + WMSApp.GetUserId();
    var _lock = await _cachingService.LockAsync(lockKey);
    if (!_lock) throw new CustomException("其他页面正在导出中，请稍后重试！");

    try
    {
        // 2. 查询数据（不分页或扩大分页）
        parm.PageNum = 1;
        parm.PageSize = 100001;
        var dataList = await GetPagedDataAsync(parm);

        // 3. 空数据校验
        if (dataList.Result.Count == 0)
            throw new CustomException("未查询到数据，请检查搜索条件");

        // 4. 导出行数限制
        if (dataList.Result.Count >= 500000)
            throw new CustomException("导出行数最大不能超过50w行");

        // 5. DTO转换 + MiniExcel导出
        var exportResult = dataList.Result.Adapt<List<ExportDto>>();
        string fileName = "报表名称";
        string filePath = HandleExcelHepler.GetFilePath(fileName, out string newFileName);
        MiniExcel.SaveAs(filePath, exportResult, excelType: ExcelType.XLSX);

        return newFileName;
    }
    finally
    {
        await _cachingService.LockReleaseAsync(lockKey);
    }
}
```

### 跨库查询规范

- 使用 `LeftJoin` / `InnerJoin` 进行多表关联
- 复杂关联业务使用 `SqlFunc.Subqueryable` 子查询
- 查询条件用 `WhereIF`（条件成立才拼接），避免空条件影响性能
- 查询结果用 `.ToPageAsync(parm)` 自动分页
