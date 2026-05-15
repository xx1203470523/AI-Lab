# Report Module 规范

> 报表模块贯穿三层：Controller → Service → Domain（使用现有实体，不新增报表实体）。

## 现有报表清单

| 报表 | Controller | Service |
|------|-----------|---------|
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

## 数据后处理

- Lookup/Dictionary 在循环外构建，避免循环内查 DB
- 枚举转显示名统一用 `ToEnum<T>().GetDescription()`
- 人员编码→名称：先批量查 `SysUser` 构建字典，再 Select 中映射

## 导出规范

- 必须使用 Redis 锁防重复导出（模式见 `02-service-layer.md`）
- 空数据抛 `CustomException`，最大 50w 行
- DTO 用 `[DisplayName]` 定义列头，`[ExcelFormat]` 定义时间格式
