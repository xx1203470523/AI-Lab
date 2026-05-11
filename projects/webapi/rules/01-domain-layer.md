# Domain Layer (仓储层) 规范

> 对应项目：`Domain.Warehouse`, `Domain.System`, `Domain.Logging`, `Domain.BI`, `Domain.Shared` 等
> 物理位置：`Domain/` 目录下

## 实体继承体系

所有实体必须遵循以下继承链之一：

```
EntityAbstract (空基类)
  └── TableEntityAbstract     -- 主数据实体（带审计、软删除）
        ├── DataPermissionEntityAbstract      -- 带站点编码
        ├── DataPermissionHierarchicalEntityAbstract
        ├── VersionEntityAbstract             -- 带乐观锁版本号
        ├── DataPermissionVersionEntityAbstract
        └── HierarchicalVersionEntityAbstract
```

### TableEntityAbstract 内置字段

| 字段 | 类型 | 说明 |
|------|------|------|
| Id | long | 雪花ID主键 |
| CreateBy | string | 创建人（仅插入） |
| CreateOn | DateTime | 创建时间（仅插入） |
| UpdateBy | string? | 更新人 |
| UpdateOn | DateTime? | 更新时间 |
| IsDeleted | bool | 软删除标志（默认 false） |
| Remark | string? | 备注 |

### 实体 Attribute 规范

```csharp
/// <summary>
/// 物料基础信息表
/// </summary>
[Tenant(DBTenant.Default)]                    // 多租户标识
[SugarTable("base_material", TableDescription = "物料基础信息表")]  // 表名映射
[SugarIndex("unique_MaterialCode_IsDeleted",   // 唯一索引
    nameof(MaterialCode), OrderByType.Asc,
    nameof(IsDeleted), OrderByType.Asc, isUnique: true)]
public class BaseMaterial : DataPermissionEntityAbstract, IDeletedFilter
{
    /// <summary>物料编码</summary>
    [SugarColumn(ColumnDescription = "物料编码", Length = FieldLengthConst.Code)]
    public string? MaterialCode { get; set; }

    [SugarColumn(IsNullable = true, ColumnDescription = "描述", Length = FieldLengthConst.Name)]
    public string? Description { get; set; }
}
```

**约束：**
- 必须标注 `[Tenant(...)]` 和 `[SugarTable(...)]`
- 必须实现 `IDeletedFilter` 接口（启用全局软删除过滤）
- 字段长度优先使用 `FieldLengthConst` 中的预定义常量
- 主键统一为 `long Id`，使用雪花ID，由 `[SugarColumn(IsPrimaryKey = true)]` 标注

## 仓储层

### 仓储基类

```csharp
// 每个实体对应一个仓储
public class BaseMaterialRepository : Repository<BaseMaterial>
{
    public BaseMaterialRepository(ISqlSugarClient db) : base(db) { }
}
```

### IRepository<T> 提供的标准方法

```
Insert / InsertAsync            — 插入
Update / UpdateAsync            — 更新（支持指定列、忽略空值）
Delete / DeleteAsync            — 删除
SoftDelete / SoftDeleteAsync    — 软删除
GetAll / GetAllAsync            — 全量查询（支持缓存）
GetId / GetIdAsync              — 主键查询
GetPages / GetPagesAsync        — 分页查询
Any / AnyAsync                  — 是否存在
Queryable / QueryableToPage     — 可组装查询
SqlQuery / SqlQueryAsync        — SQL查询
Storageable                     — 大批量插入
UseTran / UseTranAsync          — 事务
```

**约束：**
- 仓储只操作**单个实体**，跨实体查询在 Service 层通过多表 Join 实现
- 查询入参用 `Expression<Func<T, bool>>`，不用SQL字符串（除非极端情况）
- 仓储不包含业务逻辑，只做数据访问

## Commands & Queries 目录

按模块划分在 `Domain/{Module}/` 下：

```
Domain.Warehouse/
  Commands/
    InStock/
      InStockUpShelvesCreateCommand.cs
    OutStock/
      OutStockPickOrderDetailCreateCommand.cs
      OutStockPickOrderDetailUpdateCommand.cs
  Queries/
    InStock/
      InStockAsnHeadQuery.cs
      InstockArnDetailPagerQuery.cs
    OutStock/
      OutStockPickOrderQueryDto.cs
```

**约束：**
- Command：用于 CUD 操作的参数封装，以 `Command` 为后缀
- Query：用于查询条件封装，以 `Query` / `QueryDto` / `PagerQuery` 为后缀

## 枚举层

枚举集中在 `Domain.Shared/Enums/`，以 `E` 为前缀：

```
EAllotType.cs
EBillStatus.cs
EBusinessType.cs
ECheckResult.cs
ECheckStatus.cs
...
```

**约束：**
- 枚举必须提供 `[Description("中文名")]` 特性
- 使用 `ToEnum<T>()` 和 `GetDescription()` 扩展方法转换

## 属性规范（审计补充）

### `[SugarColumn]` 全覆盖

所有持久化属性**必须**标注 `[SugarColumn]`，即使列名与属性名一致：

```csharp
/// <summary>站点编码</summary>
[SugarColumn(ColumnDescription = "站点编码", Length = FieldLengthConst.Code)]
public string SiteCode { get; set; }
```

**约束：**
- `string` 类型必须指定 `Length`，优先使用 `FieldLengthConst` 预定义常量
- `decimal` 类型必须指定 `DecimalDigits`，使用 `DecimalDigitsConst.DefaultLong`
- 数值主键/外键（`long`/`int`/`byte`/`bool`）只需 `ColumnDescription`
- 非数据库字段使用 `[SugarColumn(IsIgnore = true)]`，统一放在 `#region 非数据库字段` 内

### `[DBGeneration]` 使用限制

`[DBGeneration]` 仅用于代码生成工具标记新实体，**禁止对已在生产环境运行的实体添加此特性**，否则可能引发代码生成工具异常覆盖已有实体定义。

### `TableDescription` 与类描述一致性

`[SugarTable]` 的 `TableDescription` 必须与类 `/// <summary>` 描述一致，且准确反映表的内容：

```csharp
/// <summary>分选单明细</summary>              // 类注释
[SugarTable("table_name", TableDescription = "分选单明细")]  // 表描述必须一致
```

### `ColumnDescription` 防复制粘贴错误

每个属性的 `ColumnDescription` 必须与属性本身的含义对应，**禁止复制粘贴后忘记修改**。代码审查时应特别关注连续多个属性的 `ColumnDescription` 是否有重复值。

### 废弃字段规范

废弃字段必须同时标注 `[Obsolete]` 和 `[SugarColumn]`，并统一放在 `#region 废弃字段` 内：

```csharp
#region 废弃字段

[Obsolete]
[SugarColumn(ColumnDescription = "旧字段说明")]
public string? OldField { get; set; }

#endregion
```

### 禁止遗留注释代码

实体文件中不允许保留被注释的属性或代码块（含 `///` 注释的旧属性）。如确需保留历史参考，应记录在外部文档或 Git 历史中。

### XML 注释格式

所有属性必须包含 `/// <summary>` 注释，内容使用**直接的中文描述**，不使用工具自动生成的"描述 :xxx 空值 : false"格式。
