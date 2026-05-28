---
name: stock-consistency
description: "库存一致性核查：出库扣库存、入库加库存、调拨转移、盘点调整。检查超卖、并发、事务边界。触发关键词：库存、stock、扣减、加库存、库存一致性、超卖、负库存、库存事务、quantity、库存异动、warehouse_stock。"
shell: powershell
version: 1.0.0
---

# 库存一致性检查

## Trigger

- 出库扣库存
- 入库加库存
- 调拨转移库存
- 盘点调整

## Goal

防止：

- 超卖（扣减超过实际库存）
- 库存数据与交易记录不一致
- 并发扣减导致负数库存

## Checklist

- [ ] 更新库存是否用条件更新（`WHERE quantity >= required`）
- [ ] 库存变更与交易记录是否在同一事务
- [ ] 是否记录操作人、时间、变更前后值
- [ ] 扣减前是否加行锁或使用乐观锁

## Common Fix

```sql
UPDATE warehouse_stock
SET quantity = quantity - @pickQty
WHERE id = @stockId AND quantity >= @pickQty;
```

影响行数为 0 → 库存不足，抛异常回滚。

## Forbidden

- 禁止无事务的库存变更
- 禁止不加 WHERE 条件直接 UPDATE 库存
- 禁止先查后改不加锁（TOCTOU 问题）
- 禁止库存扣减在事务外执行
