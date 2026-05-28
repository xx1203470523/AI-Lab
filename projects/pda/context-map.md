# PDA 任务路由

> AI 根据任务判断是否查阅 rules/skills，禁止扫描全 ai-lab。
> 任务判断是否补充

## 新增/修改页面

| 场景              | 加载文件                                                              |
| ----------------- | --------------------------------------------------------------------- |
| 新增业务页面      | `projects/pda/quick-ref/entity-map.md` + `projects/pda/rules/01-pda-patterns.md` |
| 新增 API 调用     | `projects/pda/quick-ref/entity-map.md`                                |
| 修改扫描流程      | `projects/pda/quick-ref/data-flows.md` + `projects/pda/rules/01-pda-patterns.md` |
| 注册路由          | `projects/pda/rules/01-pda-patterns.md`（pages.json 规范）            |
| nvue 原生页开发   | `projects/pda/rules/01-pda-patterns.md`（nvue 约束）                  |

## Bug 调试

| 场景              | 加载文件                                                              |
| ----------------- | --------------------------------------------------------------------- |
| PDA Bug 分析      | ai-lab 模板 `core/.claude/skills/bug-analysis/`（启用后凭"bug、报错、异常"等触发） |
| 扫描/PDA 硬件     | `projects/pda/rules/01-pda-patterns.md`（蓝牙/扫描部分）              |
| 数据不一致        | `projects/pda/quick-ref/data-flows.md`；启用 ai-lab 模板 `pda-sync-check` / `stock-consistency` 后凭关键词触发 |
| 防重复提交        | ai-lab 模板 `projects/webapi/.claude/skills/repeat-submit-check/`     |
| 语音/提示异常     | `projects/pda/rules/01-pda-patterns.md`（voice-utils 部分）           |
| 401/登录态问题    | `projects/pda/rules/01-pda-patterns.md`（request.js 部分）            |

## 入库 (收货/上架)

| 场景              | 加载文件                                                              |
| ----------------- | --------------------------------------------------------------------- |
| 收货流程          | `projects/pda/quick-ref/data-flows.md`（入库链路）                    |
| 上架流程          | `projects/pda/quick-ref/data-flows.md`（入库链路）                    |
| WMS 入库规范      | `projects/wms/rules/wms-business.md`                                  |

## 出库 (拣料/发货)

| 场景              | 加载文件                                                              |
| ----------------- | --------------------------------------------------------------------- |
| 拣料流程          | `projects/pda/quick-ref/data-flows.md`（出库链路）                    |
| 发货确认          | `projects/pda/quick-ref/data-flows.md`（出库链路）                    |
| WMS 出库规范      | `projects/wms/rules/wms-business.md`                                  |

## 在库 (调拨/盘点/转移)

| 场景              | 加载文件                                                              |
| ----------------- | --------------------------------------------------------------------- |
| 调拨流程          | `projects/pda/quick-ref/data-flows.md`（调拨链路）                    |
| 盘点/盲盘         | `projects/pda/quick-ref/data-flows.md`（盘点链路）                    |
| 库存转换          | `projects/pda/quick-ref/data-flows.md`；启用 ai-lab 模板 `stock-consistency` 后凭关键词触发 |
| 物料转移          | `projects/pda/quick-ref/data-flows.md`                                |

## 通用/系统

| 场景              | 加载文件                                                              |
| ----------------- | --------------------------------------------------------------------- |
| 动态菜单          | `projects/pda/quick-ref/data-flows.md`（菜单加载链路）                |
| 字典数据          | `projects/pda/quick-ref/data-flows.md`（字典加载链路）                |
| 蓝牙打印          | `projects/pda/rules/01-pda-patterns.md`（bluetooth.js 部分）          |
| 标签解析          | `projects/pda/rules/01-pda-patterns.md`（explainLabel 部分）          |
| App 更新          | `projects/pda/rules/01-pda-patterns.md`（version 部分）               |
