# WMS 业务规范

## 入库流程

ASN 预到货通知 → ARN 预收货通知 → 收货确认 → 分选（可选）→ 上架
退货走 ARN（Advance Return Notice）。

## 出库流程

拣料单生成 → PDA 拣料 → 配送 → 发货确认
配送涉及交接（HandOver）和签收。

## 库存核心规则

- 库存扣减使用条件更新 `UPDATE ... WHERE quantity >= required`
- 库存交易记录每笔操作都生成明细
- 库存标签用于批次/SN 追溯

## PDA 特殊规则

- 防重复提交：前端按钮置灰 + 后端分布式锁兜底
- 离线容错：关键操作需在信号恢复后同步确认

## 立库同步

- 入库同步快照：`InStockUpShelvesSyncSnapshaotService`（基类 `BaseThreeLayerSyncSnapshotService`）
- 立库仓库过滤：`BaseWarehouse.Group == GroupKeyConst.WarehouseAutomation`
- 上架单同步仅包含立库明细对应的上架单，且 `UpStatus != 1`
- 同步回传入口：`InStockUpShelvesSyncController` (AutomationWarehouse)
- 数据链和 FK 详见：`projects/webapi/quick-ref/`
