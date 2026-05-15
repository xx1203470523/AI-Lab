# 实体→Controller/Service 速查

> 改某个功能时快速定位入口文件，避免全仓搜索。

## 入库 (InStock)

| 业务对象 | 主实体 | Controller | 核心 Service |
|----------|--------|------------|-------------|
| ASN 预到货通知 | `InStockAsnHead` | `InStockAsnController` | `IInStockArnHeadService` |
| ARN 预收货通知 | `InStockArnHead` | `InstockArnHeadController` | `IInStockArnHeadService` |
| 收货单 | `InStockReceiptHead` | `InStockReceiptController` | — |
| 上架单 | `InStockUpShelves` | `InStockUpShelvesController` | — |
| 上架单明细 | `InStockUpShelvesDetail` | — | — |
| 上架单同步快照 | `InStockUpShelvesSnapshot` | `InStockUpShelvesSyncController` (AutomationWarehouse) | `InStockUpShelvesSyncSnapshaotService` |
| 调拨过账通知 | `OnStockAllot` | — | `OnStockAllotNoticeService` |
| 分选单 | `InStockSortingHead` | `InStockSortingController` | — |
| 质检单 | `QualChecklist` | `QualChecklistController` | — |

## 出库 (OutStock)

| 业务对象 | 主实体 | Controller | 核心 Service |
|----------|--------|------------|-------------|
| 拣料单 | `OutStockPickOrder` | `OutStockPickOrderController` | — |
| 发货单 | `OutStockDelivery` | `OutStockDeliveryController` | — |
| 配送单 | `OutStockShipment` | `OutStockShipmentController` | — |

## 同步快照基类体系 (AutomationWarehouse)

```
ISyncSnapshotService
  └── BaseThreeLayerSyncSnapshotService<T1,T2,T3,S1,S2,S3,R1,R2,R3,SRepo1,SRepo2,SRepo3>
        ├── InStockUpShelvesSyncSnapshaotService    (上架单)
        ├── OutStockPickOrderSnapshotService         (拣料单)
        ├── OnStockModalshiftSnapshotService         (形态转换)
        └── ...
```

### 基类关键钩子（改快照字段时重点看）

| 方法 | 作用 |
|------|------|
| `MapToLevel1Snapshot()` | 源实体→快照映射，**加字段改这里** |
| `TryLoadAheadRelationLevelDataAsync()` | 预加载关联表数据，**加外键字段前在这里预加载字典** |
| `BuildLevel1BaseQuery()` | 定义哪些源实体进入同步范围 |
| `ComputeLevel1Hash()` | 决定哪些字段变更触发重新同步 |
