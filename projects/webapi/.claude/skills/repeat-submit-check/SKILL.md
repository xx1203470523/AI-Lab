---
name: repeat-submit-check
description: "防重复提交核查：PDA 提交接口、按钮点击、异步回调。前端置灰、后端分布式锁、幂等 Key、唯一约束。触发关键词：重复提交、防重复、幂等、idempotent、分布式锁、LockAsync、重复扫描、并发提交、按钮置灰。"
shell: powershell
version: 1.0.0
---

# 防重复提交检查

## Trigger

- PDA 提交类接口
- 按钮点击类操作
- 异步回调处理

## Goal

防止：

- 重复提交导致数据重复
- 并发写入导致状态错乱

## Checklist

- [ ] 前端 — 点击后按钮是否立即置灰/禁用
- [ ] 后端锁 — 关键操作是否有分布式锁保护
- [ ] 幂等 Key — 锁 Key 是否包含业务唯一标识（单号+操作类型+用户）
- [ ] 数据库 — 是否有唯一约束兜底

## Common Fix

```csharp
var lockKey = $@"{Module}:{Action}:{WMSApp.GetUserId()}";
var _lock = await _cachingService.LockAsync(lockKey);
if (!_lock) throw new CustomException("操作正在执行中，请稍后重试");
try { /* 业务逻辑 */ }
finally { await _cachingService.LockReleaseAsync(lockKey); }
```

## Forbidden

- 禁止仅前端防重复
- 禁止锁 Key 不含业务唯一标识
- 禁止在 try 内获取锁、在 finally 外释放锁
