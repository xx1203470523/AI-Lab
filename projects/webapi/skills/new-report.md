# 新增报表

## Trigger

- 新增数据报表
- 新增导出功能

## Goal

按报表模块规范快速创建，避免漏掉 DTO 三件套或导出锁。

## Checklist

- [ ] 通读 `projects/webapi/rules/04-report-module.md`
- [ ] DTO 三件套完整（Dto / PagedQueryDto / ExportDto）
- [ ] Service 接口在 `Services.Report/`，实现 `[AppService(ELifeTime.Scoped)]`
- [ ] Controller 在 `Report/` 目录
- [ ] 导出方法有 Redis 锁保护
- [ ] `[DisplayName]` 定义导出列名
- [ ] 主查询用 Select 投影，不分页不查全部列
- [ ] 多表 Join 后处理用 FillDetailDataAsync 批量回查

## Common Fix

1. **DTO 三件套**：参考 `04-report-module.md` 模板
2. **分页查询**：`.Select().ToPageAsync(parm)`
3. **导出 OOM**：导致行爆炸的表从主查询移除，在 `FillDetailDataAsync` 中回查
4. **枚举显示**：`ToEnum<T>().GetDescription()`

## Forbidden

- 禁止忘记导出 Redis 锁
- 禁止主查询 5+ 表 Join 后直接导出
- 禁止 DTO 三件套不完整就提 PR
