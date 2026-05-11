# 报表调试

报表查询慢 / 导出 OOM / 数据不对的排查流程。

## 查询慢

1. 检查主查询 Join 表数 — 超过 5 表 Join 考虑拆查询
2. 检查 `.Select()` 投影 — 只选需要的 3-5 列
3. 检查 `WhereIF` 条件 — 所有 `Contains` 前判空，空列表填充 `[-1]`
4. 检查后处理 — 不用 foreach 逐条查库，用 Lookup/Dictionary

## 导出 OOM

**根因：** 主查询多表 LEFT JOIN 导致行爆炸
- 例：`PickOrder 1:N Detail 1:N Label M:N Supplier`
- 把导致行爆炸的表从主查询中移除，在 `FillDetailDataAsync` 中批量回查

```csharp
var headIds = pageData.Result.Select(a => a.Id).ToList();
var labels = await _labelRepo.Queryable()
    .Where(a => headIds.Contains(a.HeadId)).ToListAsync();
var labelLookup = labels.ToLookup(a => a.HeadId);
```

## 其他问题
- **空数据** → 检查时间/状态条件是否过严
- **枚举显示不对** → 确保使用 `ToEnum<T>().GetDescription()`
- **人员名称为登录名** → 批量查 SysUser 做 Dictionary 映射
