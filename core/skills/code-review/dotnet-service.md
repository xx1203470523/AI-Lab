# .NET Service 代码审查

## 审查要点

### 并发安全
- [ ] LockAsync 是否在 try 外部获取，finally 内释放
- [ ] 库存扣减是否有条件更新（`WHERE quantity >= required`）
- [ ] 关键操作是否有幂等校验

### 数据访问
- [ ] 是否有不必要的 N+1 查询
- [ ] 大批量查询是否有 Select 投影
- [ ] foreach 内是否查了数据库

### 异常处理
- [ ] 业务异常使用 `CustomException`（非 `Exception`）
- [ ] catch 块是否吞没了错误
- [ ] finally 是否释放了资源（锁、连接）

### 事务
- [ ] 跨库操作是否使用了 TransactionScope
- [ ] 事务范围是否合理（不要跨不必要的操作）
