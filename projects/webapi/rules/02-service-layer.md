# Service Layer 规范

> 项目特定约束，通用 DI/分页/导出模式不再重复。

## 命名空间陷阱（关键）

**Service 层绝大多数使用扁平命名空间 `Services.Warehouse`，物理文件夹仅用于组织。**

```
物理路径:  Services/Services.Warehouse/Services/Implementations/AutoPost/AutoPostService.cs
命名空间:   namespace Services.Warehouse;              ← 扁平
```

**少数历史遗留的深层命名空间（添加 using 时以实际 namespace 为准）：**

| 接口 | 实际命名空间 |
|------|-------------|
| `IInStockUpShelvesNoticeService` | `Services.Warehouse.Services.Interfaces.InStock` |
| `IErpIQCResultSyncService` | `Services.Warehouse.Interfaces.Sync` |
| `IMatchMakingService` | `Services.Warehouse.Services.Interfaces.Fix` |

**规则：新代码一律 `namespace Services.Warehouse;`，Controller 引用时先确认目标文件的 namespace 声明，禁止按文件夹路径猜测。**

`Application.Admin/GlobalUsing.cs` 已全局引入 `Services.Warehouse`，覆盖大多数接口。

## DTO 规范

- DTO 三件套：响应DTO + 查询DTO(继承 PagerQuery) + 导出DTO(带 [DisplayName])
- 导出用 `[DisplayName]`（MiniExcel 识别），非 `[Description]`
- 时间字段标注 `[ExcelFormat("yyyy-MM-dd HH:mm:ss")]`
- 枚举状态不直接导出原始值，改用 `StatusName` 字段 + `ToEnum<T>().GetDescription()` 映射

## 导出防重复

```csharp
var lockKey = $@"ReportName:Export:" + WMSApp.GetUserId();
var _lock = await _cachingService.LockAsync(lockKey);
if (!_lock) throw new CustomException("...");
try { ... }
finally { await _cachingService.LockReleaseAsync(lockKey); }
```

导出行数最大 50w，空数据抛 `CustomException`。

## 跨库查询

- 使用 `.LeftJoin` / `.InnerJoin` 多表关联
- 条件用 `.WhereIF`（条件成立才拼接）
- 空列表 `Contains` 前先判空并填充 `[-1]`
