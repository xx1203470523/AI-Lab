---
name: allot-flow
description: "调拨业务全链路：T100 同步、PDA 拣料、收货、上架、一键过账、立库回调。涉及 OnStockAllot、AllotCallback、SyncCode 路由、SplitOrderId 分组。触发关键词：调拨、allot、拨出、拨入、拣料、上架、收货、OnStockAllot、AllotCallback、一键过账、EasyPosting、立库回调、SyncCode、SplitOrder、ScanLabel。"
shell: powershell
version: 1.0.0
---

# 调拨业务流程

## Trigger
涉及调拨（allot）功能的开发、调试、问题排查时加载。关键词：调拨、allot、拨出、拨入、拣料、上架、OnStockAllot、AllotCallback、一键过账。

## Goal
理解调拨从 T100 同步到 PDA 扫描再到过账的完整业务链路，避免跨层改动时破坏流程正确性。

## 数据模型

```
OnStockAllot (主单, onstock_allot)
  ├── OnStockAllotSplit (拆单/阶段单, onstock_allot_split) — 按仓库对拆分，ClonedFromID 串联多阶段
  │     ├── OnStockAllotDetail (汇总明细, onstock_allot_detail) — 按 SyncItem 聚合
  │     │     └── OnStockAllotDetailPiece (阶段明细, onstock_allot_detail_piece)
  │     │           └── OnStockAllotDetailBatch (SN 级明细, onstock_allot_detail_batch)
  │     └── OnStockAllotRecord (扫描记录, onstock_allot_record)
  │           └── OnStockAllotRecordRemoteDetail (关联 T100 原始明细)
  ├── OnStockAllotDetailRemote (T100 原始数据)
  └── OnStockAllotRecommendLabelRecord (推荐标签缓存)
```

## 阶段流转

| EAllotStage | 名称 | PDA 页面目录 | 操作 |
|---|---|---|---|
| `AllocateStockOut` (1) | 调出拣料 | `allot-out/` | 扫描物料标签拨出 |
| `IssueMaterialsForProduction` (2) | 生产领料 | `allot-in-production-receipt/` | 交接确认 |
| `ReceiveStockIn` (3) | 调入收货 | `allot-in/` | 扫描标签确认收货 |
| `ShelveReceivedStock` (4) | 调入上架 | `allot-in-putaway/` | 扫描储位+标签上架 |

### 调拨类型 (EAllotType)

| 类型 | 值 | 覆盖阶段 | 说明 |
|---|---|---|---|
| `DirectStockTransfer` | 1 | 全部 1→2/3→4 | 一步调拨，所有阶段在同一个 SyncCode 下 |
| `PhasedStockTransfer` | 2 | 仅阶段1 | 分阶段调拨的出库部分 |
| `ReceiveTransferInbound` | 3 | 仅 2/3→4 | 分阶段调拨的入库部分，通过 SecAllotNo 关联 |

### 调拨方式 (EAllotMethod)

| 方式 | 阶段1 → 阶段2 → 阶段3 |
|---|---|
| `DedicatedToGeneral` | AllocateStockOut → ReceiveStockIn → ShelveReceivedStock |
| `GeneralToGeneral` | AllocateStockOut → ReceiveStockIn → ShelveReceivedStock |
| `GeneralToDedicated` | AllocateStockOut → IssueMaterialsForProduction → ShelveReceivedStock |
| `DedicatedToDedicated` | AllocateStockOut → IssueMaterialsForProduction → ShelveReceivedStock |
| `SameGeneral` | AllocateStockOut → ReceiveStockIn → ShelveReceivedStock |

## 完整流程链路

### Phase 0: T100 同步 → 创建调拨单

- **入口**: `OnStockAllotService`Sync.cs` → `SyncFromT100Async`
- **流程**: 拉取 T100 数据 → `OrderBuild` 创建主单 → `SplitBuild` 按仓库对拆单 → `DetailBuild` 按 SyncItem 聚合 → `DetailPieceBuild` 创建阶段明细 → `DetailBatchBuild` 创建 SN 级明细
- **初始状态**: `Status = Approved`, `Stage = AllocateStockOut`

### Phase 1: 拨出扫描 → PCA 拣料

- **推荐标签**: `CalcRecommendLabelAsync` 按 FIFO + 数量匹配策略推荐库存标签
- **标签拆分**: `RecommendedLabelSplitAndSaveAsync` 物理拆分标签（原标签软删除）
- **PDA 扫描**: `ScanLabelAsync` 校验标签（物料/特性/状态/未重复扫描）→ 匹配明细 → 拆分标签（如需要）→ 创建扫描记录 → 扣减 `ScanTransferQty` → 锁定标签
- **一键拣料**: `EasyPickAsync` 自动扫描全部推荐标签
- **确认**: `ConfirmAsync` 验证 → 自动处理（如适用）→ 锁定/解锁标签 → 库存异动 → T100 回调 → 克隆下一阶段数据

### Phase 2-4: 收货 → 领料 → 上架

- **收货/领料**: 标签必须来自上一阶段的扫描记录，通过 `ClonedFromID` 链追溯
- **上架**: 必须先扫描储位编码，再扫描物料标签；可使用推荐储位；支持"按标签上架"模式（自动匹配订单）
- **每个阶段确认后**: 自动克隆数据创建下一阶段 Split/Detail/Piece/Batch

### Phase 5: 一键过账

- **入口**: `EasyPostingAsync`（按 splitOrderId / 按 syncCode 批量）
- **流程**: 遍历所有阶段拆单，按 Stage 排序，逐阶段 `ConfirmAsync(isAutoCompleteAnyStage: true)`
- **限制**: 仅操作 `IsAbleEasyPosting = true` 的仓库；跳过立库上架阶段（等待回调）

### Phase 6: 立库回调

- **入口**: `AllotCallbackService.AllotCallbackAsync`
- **流程**: 接收 `AllotCallbackDto` → 按 `SyncCode + SyncItem + WarehouseCode` 精确定位拆单 → 分组标签 → Pending 状态执行 `DelScanLabelAsync` / Complete 状态执行 `ScanLabelAsync` → 全部完成后自动 `ConfirmAsync(ConfirmSource = Callback)`
- **关键约束**: 拆单定位必须用 `SyncCode + SyncItem + WarehouseCode` 三元组，不允许仅 SyncCode 匹配

## 核心规则

### 扫描规则
- [ ] 物料标签必须匹配物料的 MaterialCode + StockManageFeature
- [ ] 标签状态必须为 OnStock 且未被锁定
- [ ] 不可重复扫描同一标签（立库回调除外：`ThrowExceptionOnDuplicate = false`）
- [ ] 扫描数量 = min(标签数量, 明细剩余需求)
- [ ] AllocateStockOut 阶段：若标签数量 > 需求，自动拆分标签
- [ ] 上架阶段：必须先扫描储位编码，`warehouseBinCode` 随每次扫描提交

### 库存规则
- [ ] 拨出阶段：标签移出仓库（OutStock 状态），生成库存异动记录
- [ ] 分阶段调拨：标签移入在途中转仓库
- [ ] 上架阶段：标签设为 OnStock 状态，写入目标储位
- [ ] 库存变更必须使用条件 UPDATE `WHERE quantity >= required`
- [ ] 库存变更和流水记录必须在同一事务中

### 立库回调规则（CLAUDE.md 已有，此处仅列关键点）
- [ ] 定位拆单：`SyncCode + SyncItem + WarehouseCode` 三元组
- [ ] 先路由 Detail→拆单，再按 `SplitOrderId` 分组标签
- [ ] 支持幂等重试
- [ ] 仅立库回调可传 `ThrowExceptionOnDuplicate = false`
- [ ] 失败时按标签逐条填 `AllotCallbackFailedDto`
- [ ] 立库仓库上架阶段仅接受 `ConfirmSource = Callback`

### 状态机
- [ ] `Approved` → `Executing`（首次扫描后）→ `PostingInProgress`（确认中）→ `Posted`（过账完成）
- [ ] 过账失败 → `PostingFailed`，允许重试
- [ ] `BusinessCompleted`：阶段完成但未过账

## PDA 端业务规则

- [ ] 提交按钮仅 Status ∈ {Executing, Approved, PostingFailed} 时显示
- [ ] 直接提交需要权限：拨出 `onstock:allot:easy:out`，拨入 `onstock:allot:easy:in`，上架 `onstock:allot:easy:up`
- [ ] Status ≥ 6 时禁止删除标签（上架阶段 Status=10 例外）
- [ ] 扫描成功 → 播放语音 + 自动打印标签 + 焦点回到输入框
- [ ] 确认前弹窗 "是否提交单据？"

## 关键文件索引

| 文件 | 职责 |
|------|------|
| `Services/Services.Warehouse/Services/Implementations/OnStock/Allot/OnStockAllotService.cs` | 主服务，构造函数+DI+PrepareData |
| `OnStockAllotService`Scan.cs` | 标签扫描逻辑 |
| `OnStockAllotService`Confirm.cs` | 确认、库存、过账、T100 回调 |
| `OnStockAllotService`Auto.cs` | 自动拣料/收货/上架 |
| `OnStockAllotService`Easy.cs` | 一键过账/拣料 |
| `OnStockAllotService`Sync.cs` | T100 数据同步 |
| `OnStockAllotService`Factory.cs` | 实体构建器 |
| `Services/Services.AutomationWarehouse/.../AllotCallbackService.cs` | 立库回调 |
| `Application/.../OnStockAllotController.cs` | API 控制器 |

## Forbidden

- 不要在调拨确认前手动修改 `ScanTransferQty` 或 `ActualTransferQty`
- 不要在立库回调中使用 `SyncCode` 单一条件定位拆单
- 不要在非立库场景下抑制重复扫描报错
- 不要在库存变更事务外单独提交库存异动记录
- 不要跳过 PDA 扫描直接修改过账状态（应走 confirm API）
- 不要在分阶段调拨的出库部分创建入库阶段的 Split（应由对端订单同步）
