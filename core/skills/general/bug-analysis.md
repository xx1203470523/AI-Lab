# Bug 分析

## Trigger

- 生产环境报错
- 数据状态异常
- 接口返回不符合预期

## Goal

快速定位根因，避免反复试错。

## Checklist

- [ ] 复现路径 — 输入数据、操作步骤、环境
- [ ] 日志定位 — NLog 日志找异常堆栈
- [ ] 数据追溯 — 数据库确认数据状态
- [ ] 代码走读 — Controller → Service → Repository 逐层
- [ ] 边界条件 — 空值、并发、状态冲突、大数量

## Common Fix

1. 空引用 — Min/Max 前判 `.Count > 0`
2. 并发状态冲突 — 乐观锁或分布式锁
3. 数据权限遗漏 — Repository 层默认加 SiteCode 过滤
4. SqlSugar `.FirstAsync()` 无记录返回 null，不是抛异常

## Forbidden

- 禁止不查日志直接改代码
- 禁止不确认数据状态就下结论
- 禁止只修表面不复现验证
