# FK 链速查

> 需要跨表查字段时看这里，省去逐个实体翻 FK 属性。

## 入库链 FK

```
InStockUpShelves (上架单)
  .ArnId          → InStockArnHead.Id      → .AsnId → InStockAsnHead.Id
  .ReceiptHeadId  → InStockReceiptHead.Id  → .ArnHeadId → InStockArnHead.Id
  .CheckHeadId    → QualChecklist.Id

InStockReceiptHead (收货单)
  .ArnHeadId      → InStockArnHead.Id
  .SupplierId     → BaseSupplier.Id

InStockArnHead (ARN)
  .AsnId          → InStockAsnHead.Id
  .SupplierId     → BaseSupplier.Id

InStockAsnHead (ASN)
  .SupplierId     → BaseSupplier.Id
```

## 上架单明细链

```
InStockUpShelvesDetail
  .UpShelvesId       → InStockUpShelves.Id
  .ReceiptDetailId   → InStockReceiptDetail.Id
  .SupplierId        → BaseSupplier.Id
  .WarehouseId       → BaseWarehouse.Id
  .MaterialId        → BaseMaterial.Id
```

## 立库过滤条件

- 仓库分组: `BaseWarehouse.Group == GroupKeyConst.WarehouseAutomation`
- 上架单过滤: 上架明细的仓库属于立库组，且 `UpStatus != 1`（未完成上架）
- 快照同步范围: `BuildLevel1BaseQuery()` 中定义
