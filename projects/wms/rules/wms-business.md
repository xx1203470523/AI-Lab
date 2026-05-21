# WMS 业务规范

> 只记录代码看不出来的决策和规则。实体链路、文件路径去 `projects/webapi/quick-ref/` 找。

## 入库

- 退货走 ARN（Advance Return Notice），不走 ASN

## SN 序列号管控

- `BaseMaterial.IsSerialNumberControl == "1"` 的物料，收货标签 `Sn` 必须有值，否则阻断
- 校验入口：`AutoPostServicePartial.cs` → `GenerateInStockReceiptLabelsAsync()`
- 已废弃字段：`InStockReceiptDetail.MaterialNo` / `InStockReceiptDetail.Sn` → 改用 `MaterialCode` / `BaseMaterialPrintcenter.Sn`

## PDA

- 防重复提交：前端按钮置灰 + 后端分布式锁兜底
- 离线容错：关键操作需在信号恢复后同步确认

## 质检判定

- 判定合格/不合格的依据是 **T100 qcbc012（判定区分）**，不是 qcbc002
- qcbc002 仅保留用于 QualityStatus 细分（如 qcbc002="01"→special）和仓库指定
- 合格：1-良品 / 2-不良品入库 / 3-报废入库
- 不合格：4-验退 / 5-PQC破坏性检验下线 / 6-转回当站在制 / 7-转回当站报废
- 分组常量: `EQualJudgmentGroup` (Domain.Shared/Constants/)

## 立库同步

- 只有立库仓库组 (`GroupKeyConst.WarehouseAutomation`) 的明细对应的上架单才进入同步
- 上架单 `UpStatus != 1`（未完成上架）才同步
