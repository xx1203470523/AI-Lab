# Workflow: Code Review — 调拨过账失败企业微信通知

## 类型

code-review

## 状态

Pro 审查完成，已通过（1 个问题已修复 + 2 个需确认项）

## 变更概要

调拨单（BusinessType 15/16）T100 过账失败时，通过企业微信通知相关操作人及指定角色。

## 变更文件

### 1. `Domain/Domain.Shared/Constants/PostMessage/PostMessageConst.cs`

新增常量：
- `CONTEXT_MSG_ALLOT_POST_FAILED = "AllotPostFailed"`
- `ROLE_NAME_ALLOT_UNPOSTED_NOTIFY = "UnAllotPostNotifyRole"`

### 2. `Services/Services.Warehouse/ServiceConstants.cs`

新增配置键：
- `CONFIG_NAME_ALLOT_POST_FAILED_NOTICE_CYCLE = "AllotPostFailedNoticeCycle"`

### 3. `Services/Services.Warehouse/Services/Interfaces/OnStock/Allot/IOnStockAllotNoticeService.cs`（新文件）

```csharp
public interface IOnStockAllotNoticeService
{
    Task<bool> TryNoticeAsync(bool? isSuccess, OnStockAllot? head, DateTime? failureTime = null);
}
```

### 4. `Services/Services.Warehouse/Services/Implementations/OnStock/Allot/OnStockAllotNoticeService.cs`（新文件）

核心通知服务，包含：
- `TryNoticeAsync` — 入口，成功则停止通知，失败则创建/更新通知
- `NoticeFirstFailedAsync` — 首次失败，构建消息并调用 `EmitAsync`
- `NoticeOnFailedAgainAsync` — 重复失败，更新内容并重发
- `StopNoticeOnSuccessAsync` — 过账成功，停止通知
- `ResolveReceiverUserCodesAsync` — 解析接收人（制单人/一键备料人/一键过账人 + 各阶段操作记录人）
- `BuildContentAsync` — 构建消息文案
- `GetNoticeResendCycleAsync` — 获取重发周期

扩展方法类 `OnStockAllotNoticeServiceExtensions`：
- `SetContext` — 设置 `ContextId` + `ContextMsg` 用于上下文去重
- `GetSysPostMessageQueryable` — 按上下文查询消息记录
- `ResetSysPostMessage` — 恢复消息为可发送状态

### 5. `Services/Services.Warehouse/Services.Integration/Implementations/OrderPostResultService.cs`

变更：
- 注入 `IOnStockAllotNoticeService` + `OnStockAllotRepository`
- 在 `BusinessType 15/16` 过账失败分支（`RemoteConfirmAsync` 后）调用通知服务

## 通知人解析逻辑

消息内容：`【{SiteCode}】【{SyncCode}】【{failureTime}】过账失败，请及时处理！`

接收人（`ReceiverUserCodes`）：
1. `head.MakeBillUser` — 制单人
2. `head.EasyPickBy` — 一键备料人（捡料人）
3. `head.EasyPostingBy` — 一键过账人
4. `OnStockAllotRecord.CreateBy` where `Stage == AllocateStockOut` — 拨出拣料操作人（捡料人）
5. `OnStockAllotRecord.CreateBy` where `Stage == IssueMaterialsForProduction` — 生产领料操作人（领料确认人）
6. `OnStockAllotRecord.CreateBy` where `Stage == ShelveReceivedStock` — 拨入上架操作人（上架人）

接收角色（`ReceiverRoles`）：
- `UnAllotPostNotifyRole` — 调拨未过账通知角色（系统配置中分配用户）

## 通知循环机制

- 失败时通过 `SysPostMessageService.EmitAsync` 发送
- 后台 `SysPostMessageService.PostAsync` 定时重发
- 重发周期通过系统配置 `AllotPostFailedNoticeCycle` 控制（秒）
- 使用 `ContextMsg = "AllotPostFailed"` + `ContextId = head.Id` 唯一标识上下文，防止重复创建
- 过账成功后通过 `StopNoticeOnSuccessAsync` 停止通知

---

## 审查结果（Pro）

### 审查要点逐项结论

1. **通知人解析是否正确？** — ✅ 通过。`MakeBillUser`/`EasyPickBy`/`EasyPostingBy` 字段含义正确，操作记录按 Stage 分类合理，接收角色名清晰。

2. **调用时机是否合适？** — ✅ 通过。在 `RemoteConfirmAsync` 之后、事务外调用，不影响主流程。`TryNoticeAsync` 内部不抛异常，不会中断外层。

3. **幂等性处理是否正确？** — ✅ 通过。`ContextMsg + ContextId` 去重逻辑与 `InStockUpShelvesNoticeService` 一致，重复失败时复用已有消息而非新建。

4. **异常处理是否完善？** — ✅ 通过。`TryNoticeAsync` 内部 try-catch 兜底并记录日志，通知失败不影响过账主流程。

5. **消息内容是否符合业务要求？** — ⚠️ 需确认。格式 `【SiteCode】【SyncCode】【时间】过账失败，请及时处理！`，只用 `SyncCode`（T100 同步码）。上架单通知同时包含 `SyncCode + UpShelvesNo`。建议确认 `SyncCode` 对业务人员是否可读、是否足够定位调拨单。

### 关于 `FirstAsync()` 的说明

`OrderPostResultService.cs:233` 使用 `.FirstAsync()` 查调拨单。SqlSugar 的 `FirstAsync()` 无记录时返回 `default(T)`（null），等同于 EF Core 的 `FirstOrDefault`，不会抛异常。`TryNoticeAsync` 入口已做 `head == null` 防御，逻辑安全。**无需修改。**

> 注意：SqlSugar **没有** `FirstOrDefaultAsync` 方法，不要尝试改为该方法。

### 需确认项

1. **`SyncCode` 唯一性**：`OrderPostResultService` 用 `SyncCode == parm.BillNo` 查调拨单，需确认 `SyncCode` 在调拨单表有唯一约束
2. **通知内容可读性**：消息只包含 `SyncCode`（T100 同步码），建议确认业务人员能否凭此定位调拨单

### 与 InStockUpShelvesNoticeService 一致性

整体框架完全对齐：TryNoticeAsync 路由 → EmitAsync/PostAsync/StopAsync 三步走 → 扩展方法 SetContext/GetSysPostMessageQueryable/ResetSysPostMessage。模式一致，可维护性良好。
