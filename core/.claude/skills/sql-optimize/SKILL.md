---
name: sql-optimize
description: "SQL 优化：报表查询慢、导出 OOM、3+ 表 Join 分页查询。拆 Join、Select 投影、批量替换逐条、WhereIF 判空。触发关键词：sql 优化、查询慢、报表慢、导出慢、OOM、内存溢出、N+1、行爆炸、分页查询、大 Join、ToList、性能优化。"
shell: powershell
version: 1.0.0
---

# SQL 优化

## Trigger

- 报表查询慢
- 导出 OOM
- 接口响应超时
- 涉及 3+ 表 Join 的分页查询

## Goal

防止：

- 全表扫描
- 行爆炸
- N+1 查询
- 不必要的数据传输

## Checklist

- [ ] 主查询 Join 是否超过 5 表
- [ ] Select 是否只投影需要的列
- [ ] Where 条件是否有效减少数据量
- [ ] 是否在 foreach 内逐条查库
- [ ] 时间范围查询是否有索引

## Common Fix

1. 拆大 Join：主查询只查头表+核心维度，子表数据用 ToLookup 内存关联
2. Select 投影：只选需要的列，不拉大字段
3. 批量替换逐条：先收集 ID 集合，一次查回，再 Lookup/Dictionary
4. WhereIF 判空：Contains 前判空，空列表填充 `[-1]`

## Forbidden

- 禁止 foreach 内访问数据库
- 禁止 select * 查全部列
- 禁止 5+ 表 Join 不分页直接 ToList
- 禁止在应用层做聚合替代数据库 GROUP BY
