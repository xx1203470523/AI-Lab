# 业务数据链路速查

> 查数据来源时先看这个，不用逐个实体去翻 FK。

## 入库链路

```
ASN (预到货通知)
  → ARN (预收货通知, ARN.AsnId → ASN.Id)
    → Receipt (收货单, Receipt.ArnHeadId → ARN.Id)
      → UpShelves (上架单, UpShelves.ArnId → ARN.Id, UpShelves.ReceiptHeadId → Receipt.Id)
        → UpShelvesDetail (上架明细, Detail.UpShelvesId → UpShelves.Id)
```

### 常用字段来源

| 目标字段 | 直接来源 | 取数路径 |
|----------|----------|----------|
| ShippingDate (送货日期) | ASN | `UpShelves.ArnId → ArnHead.AsnId → AsnHead.ShippingDate` |
| ShippingNo (送货单号) | ASN/Receipt | `UpShelves.ReceiptHeadId → ReceiptHead.ShippingNo` |
| SupplierCode/Name | ARN/Receipt/ASN | Receipt 层拿 `ReceiptHead.SupplierCode`，或明细 Join `BaseSupplier` |
| BusinessType | ARN/Receipt | `ReceiptHead.BusinessType`，查 `SysDictData(DictType="BusinessType")` 获取中文名 |

## 出库链路

```
Delivery (发货单)
  → PickOrder (拣料单, PickOrder.DeliveryId → Delivery.Id)
    → Shipment (发货确认, Shipment.PickOrderId → PickOrder.Id)
```

## 立库同步快照链路

```
源表 (e.g. InStockUpShelves)
  → Snapshot (快照表, Snapshot.SourceId → 源表.Id, 字段冗余+PayloadHash)
    → SyncOutbox (出站箱, 记录同步任务)
      → 立库方拉取 GetPendingData → Ack/MarkFailed
```
