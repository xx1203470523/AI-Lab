# Workflow: Code Review — 分选提交增加立库反审核检查

## 类型

code-review

## 状态

Pro 审查完成，已通过（1 个 TODO 已添加）

## 变更概要

分选提交（`PDA/commit`）时，如果上架单已同步到立库，**必须先调立库反审核接口**，成功后才能分选。

## 变更文件

**`Services/Services.Warehouse/Services/Implementations/InStock/Sorting/InStockSortingService.cs`**

改动：
1. 添加 `using System.Net;`
2. 注入 `IAutomationWarehouseRemoteCoreService`
3. 在 `PDASortingCommitAsync` 校验阶段（`#region 立库反审核检查`）新增：
   - 查 `BaseWarehouse.IsAbleReversePosting == false` 定位立库仓库
   - 判断 upShelvesDetails 是否存在立库仓库的明细
   - 存在则逐张调 `ReverseAuditAsync`（`EAutomationWarehouseOrderType.UpShelves`）
   - 失败抛异常

## 审查结果（Pro）

### 审查要点逐项结论

1. **`IsAbleReversePosting == false` 是否准确标识立库？** — ✅ 通过。与 `InstockUpShelvesService.DeApproval` 现有逻辑一致，字段含义正确。

2. **反审核放在事务外（校验阶段）是否安全？** — ✅ 通过。外部接口调用不应在事务内，失败即抛异常阻止后续处理。

3. **逐张调 `ReverseAuditAsync` 性能问题？** — ⚠️ 串行可接受（分选涉及上架单数量通常不多），但已添加 TODO 标注多张单部分失败的幂等性风险。

4. **异常文案是否合适？** — ✅ 通过。比 DeApproval 的通用文案更好，带了具体单号。

5. **是否遗漏其他需要反审核的分选场景？** — ✅ 通过。分选提交只有一个入口，已覆盖。

6. **与 `InstockUpShelvesService.DeApproval` 的一致性？** — ✅ 通过。调用方式、参数、条件判断均一致。前置条件 `erpIsSuccess` 差异经确认不需要（分选优先级低于 ERP/T100/立库三系统）。

### 其他发现

- **ERP 前置条件**：DeApproval 有 `erpIsSuccess == true` 前置条件，分选场景不需要（经确认，WMS 优先级最后）
- **立库仓库缓存**：优先级低，等后续全局统一

### 已添加 TODO

- 多张上架单逐张反审的中途失败风险：前几张反审成功 + 后续失败 → 分选整体回滚但立库已反审。依赖立库接口幂等性，联调阶段暂无更好方案。
