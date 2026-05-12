# Workflow: 架构设计 — 分选提交前增加立库反审核检查

## 模型分工

Flash (当前窗口) → Pro (待处理)

---

## Step 1 — 需求梳理（Flash ✅ 已完成）

### 业务目标

分选提交（`PDA/commit`）时，如果上架单已经推送给立库，必须先调用立库反审核接口，成功后才能执行分选操作。防止立库与 WMS 数据不一致。

### 现有模块关系和调用链

```
分选提交流程（当前）：
InStockSortingController.PDACommitAsync
  → InStockSortingService.PDASortingCommitAsync
    → 校验（任务/收货单/标签/上架单状态）
    → GenerateInStockSortingOrder (核心逻辑)
      - 一般采购完全分选 → 软删原单 + 新增拆单（InStockUpShelves）
      - 一般采购部分分选 → 更新原单数量 + 新增拆单
      - 非一般采购 → 更新明细和标签仓库/储位
    → 事务提交（软删/更新/插入）

立库同步流程：
上架单变更 → UpdateOn 更新
  → 下次定时同步（快照对比 hash）
  → 立库方通过 GET /sync/stock/in/pending 拉取
  → 立库方 POST /sync/stock/in/ack 确认

反审核（已有参考实现）：
InstockUpShelvesService.DeApproval (第740-767行)
  → 查 IsAbleReversePosting == false 的仓库(=立库)
  → 调用 IAutomationWarehouseRemoteCoreService.ReverseAuditAsync
  → 失败则抛异常"请到下游立库进行反审"
```

### 技术约束

- 框架：Furion + SqlSugar, .NET 8
- 远程调用：声明式 HTTP 接口 `IHttpDeclarative` (`IAutomationWarehouseRemoteCoreService`)
- 跨数据库：快照表在 `AutomationWarehouse` 租户，业务表在 `Default` 租户
- 分选服务 `InStockSortingService` 当前不依赖任何自动化仓库相关服务
- 依赖注入：`IAutomationWarehouseRemoteCoreService` + `InStockUpShelvesSnapshotRepository` 需要注入

### 业务约束

- 不影响现有分选流程（非立库单据不受影响）
- PDA 操作的时效性不能受影响太多（网络请求可能慢）
- 反审核失败要有明确的中文错误提示
- 对于"部分分选"场景（原单保留、数量减少），立库侧也需要处理数据变更

### 不确定项（需 Pro 决策）

1. **检查同步状态的粒度**：是查 snapshot 表的 `SyncStatus`（有 `Success/Pending` 等状态），还是直接查仓库 `Group == "立库"` 就调反审核？
   - 方案A：只要上架单涉及立库仓库 → 无条件调反审核
   - 方案B：查 snapshot 确认已同步成功（`SyncStatus == Success`）→ 才调反审核
2. **部分分选场景**：原单保留只减数量，立库侧需要如何处理？是调反审核重新推，还是仅靠后续增量同步覆盖？
3. **调用时机**：反审核应在校验阶段做（事务外），还是事务内？
4. **批量处理**：分选可能涉及多张上架单，反审核是逐张调还是允许批量？
5. **非一般采购单场景**：不分单只改仓库/储位，立库侧的反审核逻辑是否相同？

---

## 待 Step 2 — Pro 方案设计

领域建模、分层设计、数据模型、风险评估。

## 待 Step 3 — Flash 质疑

## 待 Step 4 — Pro 定稿

## 待 Step 5 — Flash 实施

## 待 Step 6 — 方案调整
