---
name: sql-index-check
description: "SQL 索引检查：新增查询接口、查询慢、新增 WHERE/JOIN/ORDER BY 条件。检查全表扫描、索引失效、filesort。触发关键词：索引、index、慢查询、全表扫描、filesort、执行计划、explain、索引失效、复合索引、查询慢。"
shell: powershell
version: 1.0.0
---

# 索引检查

## Trigger

- 新增查询接口
- 查询慢排查
- 新增 WHERE / JOIN / ORDER BY 条件
- Code Review 发现新 SQL

## Goal

防止：

- 全表扫描
- 索引失效
- 排序无索引导致 filesort

## Checklist

- [ ] WHERE 条件列是否有索引
- [ ] JOIN 关联列是否有索引
- [ ] ORDER BY 列是否有索引
- [ ] 复合索引列顺序是否合理（等值在前，范围在后）

## Common Fix

1. 时间范围查询 → 加单列索引
2. 状态字段区分度低 → 复合索引或过滤索引
3. OR 条件导致索引失效 → 拆成 UNION
4. 用 SqlSugar `.ToSql()` 查看生成 SQL，数据库工具分析执行计划

## Forbidden

- 禁止在大表上无索引的时间范围查询
- 禁止在 WHERE 中对索引列使用函数（如 `DATE(column)`）
- 禁止隐式类型转换导致索引失效
