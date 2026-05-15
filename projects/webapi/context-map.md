# WebApi 任务路由

> AI 根据任务判断是否查阅 rules/skills，禁止扫描全 ai-lab。
> 任务判断是否补充

## 代码审查

| 场景              | 加载文件                                                                                        |
| ----------------- | ----------------------------------------------------------------------------------------------- |
| 后端代码审查      | `core/skills/code-review/dotnet-service.md` + `core/rules/concurrency.md` + `core/rules/sql.md` |
| Service 层审查    | + `projects/webapi/rules/02-service-layer.md`                                                   |
| Controller 层审查 | + `projects/webapi/rules/03-controller-layer.md`                                                |
| Domain 层审查     | + `projects/webapi/rules/01-domain-layer.md`                                                    |
| 报表审查          | + `projects/webapi/rules/04-report-module.md`                                                   |
| WMS 业务审查      | + `projects/wms/rules/wms-business.md`                                                          |
| 安全审查          | + `core/rules/api-design.md`                                                                    |

## 新增/修改功能

| 场景          | 加载文件                                                           |
| ------------- | ------------------------------------------------------------------ |
| Controller    | `projects/webapi/rules/03-controller-layer.md`                     |
| Service       | `projects/webapi/rules/02-service-layer.md`                        |
| Domain/Entity | `projects/webapi/rules/01-domain-layer.md`                         |
| 报表          | `projects/webapi/rules/04-report-module.md`                        |
| WMS 库存操作  | `projects/wms/rules/wms-business.md` + `core/rules/concurrency.md` |
| 立库同步快照  | 先查 `projects/webapi/quick-ref/entity-map.md` → 再读对应 Service  |

## 调试/Bug

| 场景       | 加载文件                                     |
| ---------- | -------------------------------------------- |
| Bug 分析   | `core/skills/general/bug-analysis.md`        |
| 报表调试   | `projects/webapi/skills/debug-report.md`     |
| 防重复提交 | `projects/wms/skills/repeat-submit-check.md` |
| 库存一致性 | `projects/wms/skills/stock-consistency.md`   |
| PDA 同步   | `projects/wms/skills/pda-sync-check.md`      |

## SQL

| 场景     | 加载文件                         |
| -------- | -------------------------------- |
| 查询优化 | `core/skills/sql/optimize.md`    |
| 索引检查 | `core/skills/sql/index-check.md` |
| SQL 规范 | `core/rules/sql.md`              |

## 架构

| 场景     | 加载文件                     |
| -------- | ---------------------------- |
| 架构咨询 | `core/rules/architecture.md` |
| 并发设计 | `core/rules/concurrency.md`  |
| API 设计 | `core/rules/api-design.md`   |

## WMS 业务

| 场景                | 加载文件                                                           |
| ------------------- | ------------------------------------------------------------------ |
| 入库/出库/调拨/库存 | `projects/wms/rules/wms-business.md` + `core/rules/concurrency.md` |
| 防重复提交          | `projects/wms/skills/repeat-submit-check.md`                       |
| 库存一致性          | `projects/wms/skills/stock-consistency.md`                         |
| PDA 同步            | `projects/wms/skills/pda-sync-check.md`                            |
| 通知/消息           | `projects/wms/rules/wms-business.md`                               |
