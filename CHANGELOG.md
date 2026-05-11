# CHANGELOG

> 代码变更记录，用于后续更新 ai-lab 上下文时快速了解变动。

## 格式

```
## YYYY-MM-DD
- [新增/删除/修改] 说明 → 影响: 需更新哪些 ai-lab 文件
```

---

## 2026-05-11 — 初始基线

### 项目结构
- 仓库根目录 `D:\Project\WMS`，三个子项目：AdminWebApi（.NET 8）、AdminUI（Vue 3）、PDA（UniApp）
- ai-lab 目录初次搭建完成

### 后端控制器清单（AdminWebApi）

| 模块 | Controllers |
|------|-------------|
| System | SysUser, SysRole, SysMenu, SysDept, SysPost, SysDictType, SysDictData, SysConfig, SysFile, SysNotice, SysLogin, SysVersion, SysLang, SysArticle, SysProfile, SysUserRole, SysSite |
| InStock | InstockReceipt, InStockReceiptPDA, InStockAsn, InStockAsnPDA, InStockArn, InStockSorting, InStockUpShelvesPDA, InStockUpShelvesPDARefactor, InstockStorekeeperConfig |
| OutStock | OutStockPickOrder, OutStockPickOrderPDA, OutStockDelivery, OutStockWarehouseDelivery, OutStockShipment |
| OnStock | OnStockInventory, OnStockInventoryType, OnStockTransferOrder, OnStockModalshift, OnStockBlindInventory, OnStockMaterialPreparelist, Trade |
| Quality | QualChecklist, QualityInspection |
| Report | InStockReport, InStockSortingReport, OutStockReport, OutStockProductReport, InventoryReport, CheckReport, TransferReport, OnStockAllot, InspectionReturnReport, ExceptionOrderReport, UrgentMaterialReport, QualReport, StockReport, ReceiptReport, TradeReport, StockChangeRecordReport, MaterialTransformReport |
| Basic | BaseMaterial, BaseSupplier, BaseCustomer, BaseWarehouse, BaseWarehouseArea, BaseWarehouseBin, BaseWarehouseRack, BaseWarehouseLoadType, BaseContainer, BaseContainerType, BaseProject, BaseLabel, BaseException, BaseUrgencyMaterial |
| Operations | OperationsOrderDelivery, OperationsWarehouseException |
| Interface/Integration | Erp, Inventory, StockQuery, StockChanges, MaterialTransform, ModalShift, BillUpdateCheck, QualOperation |
| Common | Common, CommonSelected, Printer, UploadImg |
| Wh | WhStock, WhLabel, WhStockSnapshot |
| Other | OtherLabel |
| DataInit | DataInit |
| Test | Test |
| Logistics | Logistics |
| Sponsor | InstockRejection |

影响: 需同步 `projects/webapi/CLAUDE.md` 和 `projects/webapi/rules/04-report-module.md`

### 报表清单（Report Controllers — 共 17 个）
- 入库报表、入库分拣报表、出库报表、出库产品报表、库存报表、质检报表、移库报表、调拨报表、检验退货报表、异常单据报表、紧急物料进度、Qual报表、Stock报表、Receipt报表、Trade报表、库存变更记录报表、料件转换报表

影响: `projects/webapi/rules/04-report-module.md` 报表清单需同步

### 枚举层（Domain.Shared/Enums/）
- 约 130 个枚举，以 `E` 为前缀，集中在 `Domain.Shared/Enums/`
- 关键枚举：EBillStatus, EInstockReceiptHeadStatus, EPickingStatus, EDeliveryStatus, ELabelStatus 等

影响: 无（枚举变更较少，按需更新即可）

### ai-lab 结构
- 初始搭建完成，包含 `core/` + `projects/` + `runtime/` 三层
- registry.json 注册了所有 skill/rule/agent
- 旧 `workspace/` 已弃用
- 根目录 `CLAUDE.md` 引用已指向 `ai-lab/`

## 2026-05-11 — 迁移企业微信通知到 NoticeJobController

### 代码变更
- **AutoPostController.cs** — 移除 `NotificationWeChatUnpostedAsync` 方法
- **NoticeJobController.cs** — 新增 `ICommonQueueAutoPostService` 注入 + 添加 `NotificationWeChatUnpostedAsync`
- 方法体和路由名完全保留，仅控制器位置变更
- 已创建 workflow 文件待 Pro 审查：`workflows/active/20260511-code-review-move-notification.md`

影响: `projects/wms/context.md` 模块清单需补充 Notice 模块

## 2026-05-11 — v4 Pro 深度设计：多模型协作+Workflow

### 新增：Workflow 体系（v4 Pro 设计）
- `runtime/workflows/workflow-protocol.md` — 完整的多模型文件交互协议
  - YAML frontmatter 定义参与者、步骤、状态机
  - 串行/并行/迭代三种执行模式
  - 5 种状态：pending → in_progress → completed / failed / re_opened
  - `active/` 和 `archive/` 目录管理
- `runtime/workflows/code-review.workflow.md` — 5 步代码审查流程
  - Flash 自查(Step1) → Pro 深审(Step2) → Flash 修改(Step3) → Pro 重审(Step4) → 结论(Step5)
  - 职责交叉说明表（Flash 看语法，Pro 看逻辑）
- `runtime/workflows/architecture.workflow.md` — 6 步架构设计流程
  - Flash 需求梳理 → Pro 方案设计 → Flash 反审 → Pro 定稿 → Flash 实施 → Pro 调整
  - 突出"Flash 质疑 Pro"的环节
- `runtime/workflows/performance.workflow.md` — 4 步性能诊断流程
  - Step1a(Flash) 和 Step1b(Pro) 可并行执行

### 更新：Agent 路由（v4 Pro 重写）
- `runtime/agent-routing.md` — 全面重写
  - 8 个 Agent，每个区分 Flash/Pro 变体
  - 5 条路由规则（显式标记、任务匹配、多领域联合、workflow 触发、复杂度自评）
  - 路由流程图
- 新增 `debugger` 和 `v4pro_debugger` agent
- 新增 `[quick]` 标记（对应 Flash 快速模式）

### 更新：模型切换
- `core/skills/general/model-switch.md` — 新增多模型协作模式文档
- 新增 `@workflow` 指令集（创建/处理/列表/查看/归档/监控）

### 更新：核心索引
- `core/registry.json` → v2.0
  - 新增 `workflows` 注册段
  - 新增 `routing` 注册段
  - Models 增加 `role` 字段（executor / reviewer）

### 更新：CLAUDE.md
- 新增模型切换章节
- 新增多模型协作章节（含 5 种场景用法）
- 新增 Workflow 操作指令表
- 新增职责互补原则说明
