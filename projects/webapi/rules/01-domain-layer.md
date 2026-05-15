# Domain Layer 规范

> 项目特定约束，通用 Entity/Repository 模式不再重复。

## 命名空间

Domain 下所有文件统一扁平命名空间 `namespace Domain.{Module};`，**禁止按子文件夹加层级**。
`Application.Admin/GlobalUsing.cs` 已全局引入 `Domain.Warehouse` / `Domain.System`。

## 实体继承链

```
TableEntityAbstract → DataPermissionEntityAbstract → (VersionEntityAbstract 等)
```

所有实体实现 `IDeletedFilter`（启用全局软删除过滤）。

## 字段约束（SugarColumn）

- `string` 必须指定 `Length`，使用 `FieldLengthConst` 预定义常量
- `decimal` 必须指定 `DecimalDigits`，使用 `DecimalDigitsConst.DefaultLong`
- 非数据库字段统一放在 `#region 非数据库字段`，标注 `[SugarColumn(IsIgnore = true)]`
- 废弃字段必须同时标注 `[Obsolete]` + `[SugarColumn]`，放在 `#region 废弃字段`
- `ColumnDescription` 必须与属性含义对应，**禁止复制粘贴后忘记修改**
- `[SugarTable].TableDescription` 必须与 `/// <summary>` 一致
- XML 注释使用中文直接描述，不用工具生成的"描述 :xxx 空值 :false"格式

## 踩坑

- `[DBGeneration]` 仅用于代码生成工具标记新实体，**禁止对已在生产的实体添加**，否则代码生成工具会覆盖
- `FieldLengthConst` 路径：`Domain.Shared/Constants/FieldLengthConst.cs`
- `DecimalDigitsConst` 路径：`Domain.Shared/Constants/DecimalDigitsConst.cs`
- 仓储只操作单个实体，跨实体查询在 Service 层通过多表 Join 实现
