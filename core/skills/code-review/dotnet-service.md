# .NET Service 代码审查

## Trigger

- Service 层新增/修改代码
- PR 提交前自查
- 涉及库存、事务、并发的变更

## Goal

防止：

- 并发安全问题
- N+1 查询
- 事务边界错误
- 异常被吞没

## Checklist

### 并发安全
- [ ] Lock 是否在 try 外获取、finally 内释放
- [ ] 库存扣减是否用条件更新（`WHERE quantity >= required`）
- [ ] 关键操作是否有幂等校验

### 数据访问
- [ ] 是否有 N+1 查询
- [ ] 大批量查询是否有 Select 投影
- [ ] foreach 内是否查了数据库

### 异常处理
- [ ] 业务异常用 `CustomException`（非 `Exception`）
- [ ] catch 块是否吞没了错误
- [ ] finally 是否释放了资源

### 事务
- [ ] 跨库操作是否使用 DBTransactionScope
- [ ] 事务范围是否合理

## Common Fix

1. N+1 → 批量查 + ToLookup/Dictionary
2. 并发冲突 → 乐观锁或分布式锁
3. 异常吞没 → 记录日志后重新 throw 或转 CustomException

## Forbidden

- 禁止在事务外执行库存变更
- 禁止 Service 直接返回 Entity
- 禁止 catch 后不处理也不重新抛出
