# 报表调试

## Trigger

- 报表查询慢
- 导出 OOM
- 报表数据不对

## Goal

快速定位报表性能/数据问题根因。

## Checklist

- [ ] 主查询 Join 表数是否超过 5 表
- [ ] `.Select()` 是否只投影需要的列
- [ ] `WhereIF` 条件中 Contains 前是否判空
- [ ] 后处理是否用了 foreach 逐条查库
- [ ] 枚举显示是否用 `ToEnum<T>().GetDescription()`

## Common Fix

1. **查询慢** → 拆 Join、加 Select 投影、WhereIF 判空
2. **导出 OOM** → 行爆炸的表移出主查询，在 FillDetailDataAsync 批量回查
3. **空数据** → 检查时间/状态过滤条件是否过严
4. **人员名称显示登录名** → 批量查 SysUser 做 Dictionary 映射

## Forbidden

- 禁止导出不加 Redis 锁
- 禁止多对多关系 Join 进主查询导出
- 禁止 foreach 逐条查库填充明细
