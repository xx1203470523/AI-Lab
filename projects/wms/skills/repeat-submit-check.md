# 防重复提交检查

## 适用场景
- PDA 重复提交（信号不稳定导致多次请求）
- 按钮多次点击（前端防抖失效）
- 异步回调重复触发

## 检查点
1. **前端** — 点击后按钮是否立即置灰/禁用
2. **后端锁** — 关键操作是否有分布式锁保护
3. **幂等 Key** — 锁 Key 是否包含业务唯一标识（订单号 + 操作类型 + 用户）
4. **数据库** — 是否有唯一约束兜底

## Lock 模板
```csharp
var lockKey = $@"{Module}:{Action}:{WMSApp.GetUserId()}";
var _lock = await _cachingService.LockAsync(lockKey);
if (!_lock) throw new CustomException("操作正在执行中，请稍后重试");
try { /* 业务逻辑 */ }
finally { await _cachingService.LockReleaseAsync(lockKey); }
```
