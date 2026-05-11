# Report Module (报表模块) 规范

> 报表模块贯穿三层：Controller → Service → Domain

## 项目映射

```
Controller:   Application.Admin/Controllers/Report/
Service:      Services.Report/
Domain:       Domain.Warehouse/   (使用现有实体，不新增报表实体)
```

## 三层调用链

```
InStockReportController                    ← Application.Admin
  → IInStockOrderReportService             ← Services.Report (接口)
    → InStockOrderReportService            ← Services.Report (实现)
      → InStockReceiptHeadRepository       ← Domain.Warehouse (仓储)
      → InStockArnHeadRepository
      → QualChecklistRepository
```

## 现有报表清单

| 报表 | 控制器 | 服务 |
|------|--------|------|
| 入库综合报表 | `InStockReportController` | `InStockOrderReportService` |
| 入库明细报表 | `InStockReportController` | `InStockOrderDetailReportService` |
| 入库分拣报表 | `InStockSortingReportController` | `InStockSortingReportService` |
| 出库单据报表 | `OutStockReportController` | `OutStockOrderReportService` |
| 出库明细报表 | `OutStockReportController` | `OutStockDetailReportService` |
| 出库产品报表 | `OutStockProductReportController` | `OutStockProductReportService` |
| 库存报表 | `InventoryReportController` | `InventoryReportService` |
| 库存账龄报表 | `InventoryReportController` | `InventoryAgingReportService` |
| 质检报表 | `CheckReportController` | `CheckReportService` |
| 检验退货报表 | `InspectionReturnReportController` | `InspectionOrderReportService` |
| 移库报表 | `TransferReportController` | `TransferOrderReportService` |
| 在库调拨报表 | `OnStockAllotController` | `OnStockAllotReportService` |
| 异常单据报表 | `ExceptionOrderReportController` | `ExceptionOrderReportService` |
| 紧急物料进度 | `UrgentMaterialReportController` | `UrgentMaterialProgressReportService` |

## 报表三要素

```
接口定义:
  Task<PagedInfo<XxxDto>> GetPagedDataAsync(XxxPagedQueryDto parm)
  Task<string> ExportExcelAsync(XxxQueryDto parm)

Controller:
  [HttpGet("page")]     GetPagedDataAsync
  [HttpGet("export")]   ExportAsync
```

## DTO 三件套

每个报表在同个文件中定义3个DTO类：

```csharp
// 1. 报表名Dto — 响应数据
public class OutStockOrderReportDto
{
    public string? SyncCode { get; set; }
    public string? BillType { get; set; }
    public DateTime? CreateDate { get; set; }
    public string? BillStatus { get; set; }
    public string? BusinessTypeName { get; set; }
    public decimal ItemQuantity { get; set; }
}

// 2. 报表名PagedQueryDto — 分页查询参数
public class OutStockOrderReportPagedQueryDto : PagerQuery
{
    public string? SyncCode { get; set; }
    public string[]? BillType { get; set; }
    public DateTime? StartTime { get; set; }
    public DateTime? EndTime { get; set; }
}

// 3. 报表名ExportDto — 导出Excel
public class OutStockOrderExportDto
{
    [DisplayName("T100单号")]
    public string SyncCode { get; set; }

    [DisplayName("创建时间")]
    [ExcelFormat("yyyy-MM-dd HH:mm:ss")]
    public DateTime? CreateDate { get; set; }
}
```

## 报表查询实现模式

### 多表关联查询
```csharp
var baseQuery = _headRepository.Queryable()
    .LeftJoin<DetailEntity>((a, b) => a.Id == b.HeadId)
    .LeftJoin<OtherEntity>((a, b, c) => b.OtherId == c.Id);
```

### 条件过滤
```csharp
.WhereIF(!string.IsNullOrEmpty(parm.Code), a => a.Code.StartsWith(parm.Code))
.WhereIF(parm.StartTime.HasValue, a => a.CreateOn >= parm.StartTime)
.WhereIF(parm.EndTime.HasValue, a => a.CreateOn < parm.EndTime)
.WhereIF(queryIds.Any(), a => queryIds.Contains(a.Id))
```

**约束：**
- 使用 `WhereIF` 替代 `if {}` 块
- 所有 `Contains` 前先判空，空列表填充 `[-1]`
- 时间范围使用 `>= start` 和 `< end`

### 数据后处理
```csharp
var userDic = sysUserEntities.ToDictionary(a => a.UserName ?? "");
var detailLookup = detailEntities.ToLookup(a => a.HeadId);

foreach (var item in pageData.Result)
{
    item.StatusName = item.Status.ToEnum<EStatus>().GetDescription();
    item.CreatorName = userDic.TryGetValue(item.CreateBy, out var u) ? u.NickName : item.CreateBy;
}
```

**约束：**
- Lookup/ToDictionary 在循环外构建
- 枚举转显示名统一用 `ToEnum<T>().GetDescription()`

## 导出规范

```csharp
var lockKey = $@"ReportName:Export:" + WMSApp.GetUserId();
var _lock = await _cachingService.LockAsync(lockKey);
if (!_lock) throw new CustomException("其他页面正在导出中，请稍后重试！");
try
{
    parm.PageNum = 1;
    parm.PageSize = 100001;
    var exportResult = dataList.Result.Adapt<List<ExportDto>>();
    string filePath = HandleExcelHepler.GetFilePath(fileName, out string newFileName);
    MiniExcel.SaveAs(filePath, exportResult, excelType: ExcelType.XLSX);
    return newFileName;
}
finally
{
    await _cachingService.LockReleaseAsync(lockKey);
}
```

**约束：**
- 必须使用 Redis 锁防止重复导出
- 导出行数限制最大 50w 行
- 空数据时抛出 `CustomException`
- 导出DTO用 `[DisplayName]` 定义列头，`[ExcelFormat]` 定义时间格式
