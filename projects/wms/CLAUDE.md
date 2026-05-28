# CLAUDE.md

## Project Identity

- **Project**: WMS 管理端 (AdminUI)
- **Stack**: Vue 3 + Element Plus + Pinia + Vue Router + Axios + Vite
- **Package Manager**: pnpm
- **Scope**: 当前仓库仅负责 WMS 前端管理界面，后端 API 为独立仓库 `IMTC.WMS.AdminWebApi`

## AI Workspace

```
../ai-lab/
  core/              — 全局规则 (SQL / API / 架构 / 并发)
  projects/
    webapi/          — 后端规则 (Controller / Service / Domain / Report)
    wms/             — WMS 领域上下文 + 技能
    wmsweb/          — ⭐ 本前端项目详细上下文
    pda/             — PDA 规则
  runtime/           — 执行流程、路由、workflow
```

## Project Context

项目详细技术栈、目录结构、业务模块、编码规范见：

`../ai-lab/projects/wmsweb/CLAUDE.md`

## Context Routing

按任务类型导航规则/技能：

`../ai-lab/projects/wmsweb/context-map.md`

## Loading Rules

按需加载，禁止一次性扫描全部 ai-lab：

1. 当前任务相关代码（`src/` 对应模块）
2. `../ai-lab/projects/wmsweb/context-map.md`（上下文路由）
3. `../ai-lab/projects/wmsweb/rules/`（前端页面规范）
4. 业务流程类技能模板存于 ai-lab `core/.claude/skills/` 与 `projects/{webapi,wmsweb,pda}/.claude/skills/`，启用后凭关键词自动触发
5. `../ai-lab/projects/wms/`（WMS 业务领域）
6. `../ai-lab/core/rules/`（全局规范）
7. `../ai-lab/runtime/workflows/`（仅用户明确要求时）

## Search Constraints

- 禁止全项目扫描 `node_modules/` `dist/`
- 按业务模块定位：`src/views/{module}/` → `src/api/{module}/` → `src/store/modules/`
- 枚举值查 `src/enums/`，组件查 `src/components/`，组合式函数查 `src/composition/`

## 执行环境

Shell: **PowerShell**（始终使用 PowerShell 执行命令，不使用 Bash）

## Build Commands

```bash
pnpm dev              # 启动开发服务器
pnpm build            # 生产构建
pnpm preview          # 预览构建结果
pnpm lint:eslint      # ESLint 检查
```

## Key Patterns (速查)

- **组件**: Composition API + `<script setup>` 语法
- **API**: 通过 `src/api/` 封装调用，不在视图层直接调用 axios
- **状态**: Pinia 按模块拆分 `src/store/modules/`
- **路由**: 懒加载，按模块配置 `src/router/`
- **枚举**: 统一在 `src/enums/` 定义，避免魔法数字
- **通用逻辑**: 抽取到 `src/composition/` composables
- **两套页面模式**: 新架构（`@/lebg/` + schemas.tsx + useTable）和传统模式（直接 Element Plus），不可混用

## 回写

功能完成后，评估是否涉及非显而易见的页面规范/数据流，若是则追加到 ai-lab 对应文件。

### 什么该写
- 页面→API 映射（entity-map）：新增页面涉及的新接口链路
- 数据流向（data-flows）：跨页面的数据流转路径
- 业务规则（wms-business）：代码里看不出来的前端处理逻辑

### 什么不写
- 组件属性调整、样式修改——代码本身就能看出来
- 通用的 CRUD 页面——entity-map 已覆盖

### 粒度
面向 AI 检索缓存：本次用到的链路才写，不推测未涉及的。精简到能在一屏内定位入口即可。
