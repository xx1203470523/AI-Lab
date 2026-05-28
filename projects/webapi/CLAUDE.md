# CLAUDE.md

## 项目身份

- **Project**: WMS Backend API
- **Stack**: .NET 8 + Furion + SqlSugar + DDD-layered
- **Scope**: 当前仓库仅负责 WMS 后端，PDA/AdminUI 为独立仓库

## 执行环境

Shell: **PowerShell**（始终使用 PowerShell 执行命令，不使用 Bash）

## Commands

```bash
dotnet build IMTC.WMS.sln
dotnet run --project Presentation/Admin.WebApi
dotnet test UnitTest/TestProject1
```

## 入口

动手前先判断是否查 ai-lab，满足**任一**条件则先读速查表再动手：

- 任务包含业务域关键词：质检/同步/入库/上架/拣料/立库/出库/调拨/分选/一键入库
- 跨层改动（同时涉及 Entity + Service + DTO 中至少两层）
- 涉及 T100/ERP/SRM 外部系统对接
- 修改文件路径含 `Sync`、`Integration`、`AutomationWarehouse`

以下情况跳过，直接搜索：
- 单文件字段增删、DTO 属性调整
- 用户已给出具体文件路径和改法
- 纯编译错误修复

一次加载 ≤ 3 个文件。禁止全仓 `grep *.cs`。

## 速查

| 需求                 | 文件                                                |
| -------------------- | --------------------------------------------------- |
| 实体→Controller 映射 | `../ai-lab/projects/webapi/quick-ref/entity-map.md` |
| 数据链路             | `../ai-lab/projects/webapi/quick-ref/data-flows.md` |
| FK 链                | `../ai-lab/projects/webapi/quick-ref/fk-chains.md`  |
| WMS 业务规范         | `../ai-lab/projects/wms/rules/wms-business.md`      |

## 回写

功能完成后，评估本次改动是否涉及非显而易见的知识，若是则追加到 ai-lab 对应文件。

### 什么该写
- 模块实体链路（entity-map）：本次遍历过的实体依赖链，帮助下次快速定位
- 数据流向（data-flows）：跨系统的数据入口、转换点、落库路径
- 业务规则（wms-business）：代码里看不出来的决策（如 qcbc012/qcbc002 职责划分）、特殊判定逻辑
- FK 依赖（fk-chains）：新发现的跨表关联

### 什么不写
- 字段增删、DTO 重命名——代码本身就能看出来
- 通用的 CRUD 路径——模块 entity-map 已覆盖

### 粒度
面向 AI 检索缓存：本次用到的实体/链路才写，不推测未涉及的。精简到能在一屏内定位入口即可。

### 淘汰
满足任一条件则删除已有条目：
1. 当前代码已能直接表达
2. 不再存在跨层理解成本（如数据流已整合到 data-flows）
3. 被更高层规则覆盖（如 entity-map 已包含的 Controller/Service 映射）
4. 超过 3 个月未再次引用
