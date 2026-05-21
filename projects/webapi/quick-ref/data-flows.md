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

## 一键入库 / AutoPost 链路

```
一键入库请求 (receiptAutoUpShelves)
  → AutoPostService.RunAsync() / RunBatchAsync()
    → ParsesReceiptDto()         加载收货单+明细+物料
    → GenerateArnPurchaseLabelsAsync()  生成/加载 ARN 标签
    → GenerateInStockReceiptLabelsAsync()  生成收货标签（含 SN 管控校验）
    → GenerateQualChecklistAsync()  生成质检单
    → GenerateUpShelvesAsync()   生成上架单+明细+标签
    → WriteToDb()                事务写入数据库
    → InformT100ToWriteInStockReceipt()  通知 T100
```

### 关键校验

| 校验 | 触发条件 | 阻断逻辑 |
|------|----------|----------|
| SN 管控 | `BaseMaterial.IsSerialNumberControl == "1"` 且标签 `Sn` 为空 | 抛异常 `物料【{code}】启用序列号管控，请先录入SN` |

### 入口

- Controller: `InStockUpShelvesController.receiptAutoUpShelves` (`PUT instock/inStockUpShelves/receiptAutoUpShelves`)
- Service: `AutoPostService` (`Services/Services.Warehouse/AutoPost/`)
- SN 校验位置: `AutoPostServicePartial.cs` → `GenerateInStockReceiptLabelsAsync()`

## ERP 质检结果同步链路

```
T100 ERP 质检结果 (IQC Result)
  → ErpIQCResultDto / ErpIQCResultDetailDto
      qcbc012 (判定区分) 经 NumberStringToEnumConverter<EQualJudgment> 反序列化
    → ErpIQCResultSyncService
        合格/不合格判定依据 EQualJudgmentGroup.Qualified / Unqualified
        写入 BaseMaterialPrintcenter.UnqualifiedType (EQualJudgment)
```

### 判定分组

| 分组 | 枚举值 | 含义 |
|------|--------|------|
| Qualified | 1-良品, 2-不良品入库, 3-报废入库 | 合格 |
| Unqualified | 4-验退, 5-PQC破坏性检验下线, 6-转回当站在制, 7-转回当站报废 | 不合格 |

### 关键文件

- DTO: `Infrastructure.Remote/Response/ErpIQCResultDto.cs` (ErpIQCResultDetailDto.qcbc012)
- 转换器: `Infrastructure.Common/Converter/Json/NumberStringToEnumConverter.cs`
- 同步服务: `Services/Services.Warehouse/Services.Sync/Implementations/ErpIQCResultSyncService.cs`
- 枚举: `Domain.Shared/Enums/EQualJudgment.cs`
- 分组常量: `Domain.Shared/Constants/EQualJudgmentGroup.cs`

## 立库同步快照链路

```
源表 (e.g. InStockUpShelves)
  → Snapshot (快照表, Snapshot.SourceId → 源表.Id, 字段冗余+PayloadHash)
    → SyncOutbox (出站箱, 记录同步任务)
      → 立库方拉取 GetPendingData → Ack/MarkFailed
```
