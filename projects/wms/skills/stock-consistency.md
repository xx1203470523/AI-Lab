# 库存一致性检查

## 适用场景
- 出库扣库存
- 入库加库存
- 调拨转移库存
- 盘点调整

## 检查点
1. **乐观锁** — 更新库存时使用 `WHERE quantity >= required` 条件
2. **事务** — 库存变更 + 交易记录在同一事务内
3. **日志** — 每次库存变更记录操作人、时间、变更前后值
4. **对账** — 定期库存快照与交易流水比对

## 典型 SQL
```sql
UPDATE warehouse_stock
SET quantity = quantity - @pickQty
WHERE id = @stockId AND quantity >= @pickQty;
```
影响行数为 0 则库存不足，抛异常回滚事务。
