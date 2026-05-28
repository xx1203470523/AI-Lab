# WebApi 任务路由

> AI 根据任务判断是否查阅 rules/skills，禁止扫描全 ai-lab。
> 任务判断是否补充

## 代码审查

| 场景              | 加载文件                                                                                        |
| ----------------- | ----------------------------------------------------------------------------------------------- |
| 后端代码审查      | 内置 skill `code-review` + `core/rules/concurrency.md` + `core/rules/sql.md` |
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

## 调试/Bug（ai-lab 模板，启用后凭关键词触发）

| 场景       | ai-lab 模板位置                                          | 触发关键词                                   |
| ---------- | -------------------------------------------------------- | ------------------------------------------ |
| Bug 分析   | `core/.claude/skills/bug-analysis/`                      | bug、报错、异常、根因、定位问题             |
| 报表调试   | `projects/webapi/.claude/skills/debug-report/`           | 报表慢、报表导出、报表数据不对、Report      |
| 防重复提交 | `projects/webapi/.claude/skills/repeat-submit-check/`    | 重复提交、防重复、幂等、分布式锁           |
| 库存一致性 | `projects/webapi/.claude/skills/stock-consistency/`      | 库存、扣减、超卖、库存事务                 |
| PDA 同步   | `projects/pda/.claude/skills/pda-sync-check/`            | PDA 同步、数据不同步（在 PDA 项目中触发）   |

## SQL（ai-lab 模板，启用后凭关键词触发）

| 场景     | ai-lab 模板位置                              | 触发关键词                              |
| -------- | -------------------------------------------- | --------------------------------------- |
| 查询优化 | `core/.claude/skills/sql-optimize/`          | sql 优化、查询慢、N+1、行爆炸、ToList    |
| 索引检查 | `core/.claude/skills/sql-index-check/`       | 索引、index、慢查询、全表扫描、explain   |
| SQL 规范 | `core/rules/sql.md`                          | （静态规则文件）                        |

## 架构

| 场景     | 加载文件                     |
| -------- | ---------------------------- |
| 架构咨询 | `core/rules/architecture.md` |
| 并发设计 | `core/rules/concurrency.md`  |
| API 设计 | `core/rules/api-design.md`   |

## WMS 业务

| 场景                | 加载文件 / 触发关键词                                              |
| ------------------- | ------------------------------------------------------------------ |
| 入库/出库/调拨/库存 | `projects/wms/rules/wms-business.md` + `core/rules/concurrency.md` |
| 调拨流程            | ai-lab 模板 `projects/webapi/.claude/skills/allot-flow/`（关键词：调拨、allot、拨出、AllotCallback） |
| 防重复提交          | ai-lab 模板 `projects/webapi/.claude/skills/repeat-submit-check/`  |
| 库存一致性          | ai-lab 模板 `projects/webapi/.claude/skills/stock-consistency/`    |
| PDA 同步            | ai-lab 模板 `projects/pda/.claude/skills/pda-sync-check/`          |
| 通知/消息           | `projects/wms/rules/wms-business.md`                               |
