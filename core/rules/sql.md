# SQL 规范

## 查询原则
- 避免 SELECT *，只查需要的列
- 多表 JOIN 超过 3 张时考虑拆查询或批处理
- 所有 `WHERE IN` 子查询必须判空，空列表填充 `[-1]` 防止全表扫描
- 时间范围使用 `>= start AND < end`（排除边界问题）

## 索引建议
- 查询条件列必须建索引（WarehouseCode, Status, CreateOn）
- 排序字段（CreateOn, Id）建议建索引
- 联合索引考虑列顺序：等值条件 → 范围条件

## SqlSugar 约定
- 多表查询优先 `.LeftJoin` 而非 `.Where + subquery`
- 使用 `.WhereIF` 替代 `if {}` 块保持链式可读性
- 大批量数据使用 `.ToPageAsync()` 分页
- 枚举字段用 `.ToEnum<T>().GetDescription()` 转换显示值
