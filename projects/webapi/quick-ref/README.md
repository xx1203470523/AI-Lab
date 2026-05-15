# Quick-Ref 回写格式标准

> AI 回写时遵循此格式，保证条目一致、可检索。

## data-flows.md

```markdown
## {业务场景}

### 链路
SourceEntity → MiddleEntity → TargetEntity (FK 说明)

### 常用字段来源

| 目标字段 | 直接来源 | 取数路径 |
|----------|----------|----------|
| FieldName | SourceTable | `Entity.FK → Other.PK → Other.Field` |
```

- 链路用 `→` 连接，括号标注 FK
- 取数路径用 `` ` `` 包裹代码
- 只写验证过的路径

## entity-map.md

```markdown
| 业务对象 | 主实体 | Controller | 核心 Service |
|----------|--------|------------|-------------|
| {中文名} | `EntityName` | `XxxController` | `IXxxService` |
```

- Controller 标注所在项目（如非 Admin 项目）
- Service 写接口名（`I` 前缀）
- 同步快照类需要额外标注基类和关键钩子

## fk-chains.md

```markdown
## {领域}链 FK

### {实体名}
```
EntityName
  .FkField1  → TargetEntity1.Field
  .FkField2  → TargetEntity2.Field
```
```

- 用树形缩进表示层级
- 只写实际用到的 FK，不全量列出
- 跨库/特殊过滤条件追加在下方注释
