# 并发安全规范

## 分布式锁
- Redis 锁 Key 格式：`{Module}:{Action}:{UserId}`
- Lock/Release 成对出现，Lock 在 try 外获取，Release 在 finally 执行
- `await _cachingService.LockAsync(lockKey)` 返回 false 时抛 `CustomException`

```csharp
var lockKey = $@"ReportName:Export:" + WMSApp.GetUserId();
var _lock = await _cachingService.LockAsync(lockKey);
if (!_lock) throw new CustomException("正在执行中，请稍后重试");
try
{
    // 业务逻辑
}
finally
{
    await _cachingService.LockReleaseAsync(lockKey);
}
```

## 防重复提交
- 前端按钮点击后立即置灰
- 后端用分布式锁兜底
- 关键操作（扣库存、状态变更）必须幂等

## 数据一致性
- 库存扣减使用 `UPDATE ... WHERE quantity >= required` 条件更新
- 状态变更记录操作日志便于回溯
