# 新增报表

按报表模块规范快速创建新报表。

## 规范参考

先通读 `projects/webapi/rules/04-report-module.md`：
- 报表三要素（分页查询 + 导出 + Controller）
- DTO 三件套（Dto / PagedQueryDto / ExportDto）
- 查询实现模式（多表 Join / WhereIF / 数据后处理）
- 导出规范（Redis 锁 / MiniExcel / 文件路径）

## 三步创建流程

### Step 1: 定义 DTO

```csharp
// 1. 报表名Dto — 响应数据
public class XxxReportDto
{
    public string? Field1 { get; set; }
    public string? StatusName { get; set; }
    public string? TypeName { get; set; }
}

// 2. 报表名PagedQueryDto — 分页查询参数
public class XxxReportPagedQueryDto : PagerQuery
{
    public string? Code { get; set; }
    public DateTime? StartTime { get; set; }
    public DateTime? EndTime { get; set; }
}

// 3. 报表名ExportDto — 导出列定义
public class XxxReportExportDto
{
    [DisplayName("编码")]
    public string Code { get; set; }
    [DisplayName("时间")]
    [ExcelFormat("yyyy-MM-dd HH:mm:ss")]
    public DateTime? CreateOn { get; set; }
}
```

### Step 2: Service 接口 + 实现

**接口：** `Services.Report/I{Name}Service.cs`
```csharp
public interface IXxxReportService
{
    Task<PagedInfo<XxxReportDto>> GetPagedDataAsync(XxxReportPagedQueryDto parm);
    Task<string> ExportExcelAsync(XxxReportPagedQueryDto parm);
}
```

**实现：** `Services.Report/Implementations/XxxReportService.cs`
```csharp
[AppService(ELifeTime.Scoped)]
public class XxxReportService : IXxxReportService
{
    public async Task<PagedInfo<XxxReportDto>> GetPagedDataAsync(XxxReportPagedQueryDto parm)
    {
        var query = _repo.Queryable()
            .LeftJoin<DetailEntity>((a, b) => a.Id == b.HeadId)
            .WhereIF(!string.IsNullOrEmpty(parm.Code), a => a.Code == parm.Code)
            .WhereIF(parm.StartTime.HasValue, a => a.CreateOn >= parm.StartTime);

        var pageData = await query.Select((a, b) => new XxxReportDto
        {
            Code = a.Code,
            StatusName = a.Status.ToEnum<EStatus>().GetDescription(),
        }).ToPageAsync(parm);

        return pageData;
    }

    public async Task<string> ExportExcelAsync(XxxReportPagedQueryDto parm)
    {
        // Redis 锁 → 不分页查全部 → Mapster转ExportDto → MiniExcel导出
    }
}
```

### Step 3: Controller

```csharp
[Route("report/xxx")]
public class XxxReportController : ControllerAbstract
{
    [HttpGet("page")]
    public async Task<IActionResult> GetPagedDataAsync([FromQuery] XxxReportPagedQueryDto parm)
        => Success(await _service.GetPagedDataAsync(parm));

    [HttpGet("export")]
    public async Task<IActionResult> ExportExcelAsync([FromQuery] XxxReportPagedQueryDto parm)
        => Success(await _service.ExportExcelAsync(parm));
}
```

## 检查清单
- [ ] DTO 三件套完整（Dto / PagedQueryDto / ExportDto）
- [ ] Service 接口在正确目录
- [ ] 实现使用 `[AppService(ELifeTime.Scoped)]`
- [ ] Controller 在 `Report/` 目录下
- [ ] 导出方法有 Redis 锁保护
- [ ] `[DisplayName]` 定义导出列名
