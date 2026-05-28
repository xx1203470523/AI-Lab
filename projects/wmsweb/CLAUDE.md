# WMS 管理端 (AdminUI) 项目上下文

> 对应项目：`IMTC.WMS.AdminUI`
> 技术栈：Vue 3 + Element Plus + Pinia + Vue Router + Axios + Vite
> 包管理：pnpm

## 目录结构

| 目录                 | 说明                                                     |
| -------------------- | -------------------------------------------------------- |
| `src/views/`         | 页面视图，按业务模块分（instock/outstock/onstock/stock） |
| `src/api/`           | API 接口封装，按模块分，与 views 对应                    |
| `src/store/modules/` | Pinia 状态管理                                           |
| `src/router/`        | 路由配置                                                 |
| `src/components/`    | 通用组件                                                 |
| `src/composition/`   | 组合式函数 (Composables)                                 |
| `src/utils/`         | 工具函数                                                 |
| `src/enums/`         | 枚举常量                                                 |
| `src/directive/`     | 自定义指令                                               |
| `src/plugins/`       | 插件注册                                                 |
| `src/layout/`        | 布局组件                                                 |

## 业务模块

| 模块 | views 目录                    | API 目录                    | 说明                     |
| ---- | ----------------------------- | --------------------------- | ------------------------ |
| 入库 | `views/instock/`              | `api/instock/`              | ASN → 收货 → 分选 → 上架 |
| 出库 | `views/outstock/`             | `api/outstock/`             | 拣料 → 配送 → 发货       |
| 在库 | `views/onstock/`              | `api/onstock/`              | 调拨、移库、转换、盲盘   |
| 库存 | `views/stock-transformation/` | `api/stock-transformation/` | 库存查询、交易、标签     |
| 报表 | `views/reports/`              | `api/reports/`              | 入库/出库/库存等报表     |
| 系统 | `views/system/`               | `api/system/`               | 用户、角色、菜单、字典   |
| 质检 | `views/quality/`              | `api/quality/`              | 质检管理                 |
| 看板 | `views/kanban/`               | `api/kanban/`               | 看板展示                 |
| 物流 | `views/logistics/`            | `api/logistics/`            | 物流管理                 |

## 执行环境

Shell: **PowerShell**（始终使用 PowerShell 执行命令，不使用 Bash）

## 开发命令

```bash
pnpm dev          # 启动开发服务器
pnpm build        # 生产构建
pnpm preview      # 预览构建结果
pnpm lint:eslint  # ESLint 检查
```

## 编码规范

- 使用 Composition API + `<script setup>` 语法
- API 请求统一通过 `src/api/` 封装，不在视图层直接调用 axios
- 状态管理使用 Pinia，按模块拆分 store
- 路由懒加载，按模块配置
- 枚举值统一在 `src/enums/` 定义，避免魔法数字
- 通用逻辑抽取到 `src/composition/` composables

## 页面规范（本仓库规则）

| 规则         | 路径                         | 说明                              |
| ------------ | ---------------------------- | --------------------------------- |
| 页面结构规范 | `rules/page-structure.md`    | 目录组织、路由、文件命名          |
| API 调用规范 | `rules/api-layer.md`         | 请求方法、响应处理、参数约定      |
| 组件模式规范 | `rules/component-pattern.md` | 新架构 vs 传统模式、列表/弹窗约定 |
| 状态管理规范 | `rules/state-management.md`  | Pinia store、权限控制、事件通信   |

## 技能（模板存于 ai-lab，启用需复制到 ~/.claude/skills/ 或真实项目 .claude/skills/）

业务流程类技能以 SKILL.md（含 frontmatter）形式存放在 ai-lab，凭关键词稳定触发。模板仅在 ai-lab 维护，使用前需手动复制到启用位置。

| 技能      | ai-lab 模板位置                                   | 触发关键词示例                           |
| --------- | ------------------------------------------------ | ---------------------------------------- |
| API 调试  | `projects/wmsweb/.claude/skills/api-debug/SKILL.md` | 接口报错、Network、跨域、proxy、token 过期 |
| 新增页面  | 真实项目内置 `gen` skill                         | 新增、生成、create、new                  |

## 关联规则（跨项目）

| 规则         | 路径                                 | 适用场景               |
| ------------ | ------------------------------------ | ---------------------- |
| 架构分层规范 | `core/rules/architecture.md`         | 理解后端架构依赖       |
| API 设计规范 | `core/rules/api-design.md`           | 对接后端接口约定       |
| 并发安全规范 | `core/rules/concurrency.md`          | 分布式锁、防重复提交   |
| WMS 业务规范 | `projects/wms/rules/wms-business.md` | 入库/出库/库存业务规则 |

## 关联技能（后端模板，启用后凭关键词触发）

下列技能存放于 `projects/webapi/.claude/skills/`，复制到启用位置后才会触发：

| 技能             | 触发关键词示例                           |
| ---------------- | ---------------------------------------- |
| 防重复提交检查   | 重复提交、防重复、幂等、分布式锁         |
| 库存一致性检查   | 库存、扣减、超卖、库存事务               |
| PDA 数据同步检查 | PDA 同步、数据不同步（在 PDA 项目中触发） |

## 领域上下文

参见 `projects/wms/context.md` 获取 WMS 完整模块概览和技术栈信息。

## 上下文路由

参见 `context-map.md` 按任务类型快速定位规则/技能。

## Agent 路由

- 默认使用 v4 Flash 模型处理日常开发
- 代码审查类任务可添加 `[v4pro]` 标记切换到深度审查
