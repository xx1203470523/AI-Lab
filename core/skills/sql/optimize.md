# SQL 优化技能

## 适用场景
- 报表查询慢
- 导出 OOM
- 接口响应超时

## 排查流程
1. **检查查询计划** — 确认 Join 顺序和索引使用
2. **检查 Select 投影** — 是否拉了不需要的列
3. **检查数据量** — 过滤条件是否能有效减少数据
4. **检查后处理** — 是否有 foreach 内逐条查库

## 优化手段

### Select 投影
```csharp
// 差：查全部列
var data = _repo.Queryable().ToList();
// 好：只查需要的列
var data = _repo.Queryable().Select(a => new { a.Id, a.Name }).ToList();
```

### 批处理替代逐条
```csharp
// 差：foreach 内查库
foreach (var item in list) {
    var detail = _repo.GetById(item.Id);
}
// 好：批量查 + Lookup
var ids = list.Select(a => a.Id).ToList();
var details = _repo.Queryable().Where(a => ids.Contains(a.Id)).ToList();
var lookup = details.ToLookup(a => a.HeadId);
```

### 拆大 Join
- 超过 5 表 Join 考虑拆成多次查询
- 主查询只查头表 + 核心维度
- 子表数据在内存中通过 ToLookup 关联
