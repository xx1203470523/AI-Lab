---
id: "20260511-code-review-move-notification"
workflow: "code-review"
status: "pending"
priority: "normal"
created_at: "2026-05-11T18:30:00+08:00"

participants:
  - id: "flash-1"
    model: "deepseek-v4-flash"
    role: "author"
  - id: "pro-1"
    model: "deepseek-v4-pro"
    role: "reviewer"

steps:
  - step: 1
    name: "快速自查"
    assigned: "flash-1"
    status: "completed"
    summary: "编译通过，路由无冲突，逻辑无改动"

  - step: 2
    name: "深度审查"
    assigned: "pro-1"
    status: "pending"
    depends_on: [1]
    focus: ["路由冲突", "依赖注入", "职责边界"]

  - step: 3
    name: "按审查意见修改"
    assigned: "flash-1"
    status: "pending"
    depends_on: [2]

  - step: 4
    name: "确认通过"
    assigned: "pro-1"
    status: "pending"
    depends_on: [3]
---

# 任务描述

## 背景
新增了 `NoticeJobController` 专门处理消息推送，需要将 `AutoPostController` 中的企业微信通知方法迁移过去。

## 变更内容

将 `AutoPostController.NotificationWeChatUnpostedAsync` 移到 `NoticeJobController`。

### 涉及文件

| 文件 | 变更 |
|------|------|
| `Application.Admin/Controllers/AutoPost/AutoPostController.cs` | 移除 `NotificationWeChatUnpostedAsync` 方法 |
| `Application.Admin/Controllers/Notice/NoticeJobController.cs` | 新增 `ICommonQueueAutoPostService` 注入 + `NotificationWeChatUnpostedAsync` 方法 |

### 业务逻辑
- 方法体完全一致，无任何逻辑修改
- 路由从 `[HttpGet("notice/qywx")]` 迁移到同名路由

---

## Step 1 — 快速自查（flash-1）

### 检查结果
- 编译通过：✅
- 路由无冲突：AutoPostController 下原路径 `autopost/notice/qywx` 已移除，NoticeJobController 下新增 `job/notice/qywx`
- 业务逻辑未改动：✅ 方法体完全复制
- 依赖注入正确：`ICommonQueueAutoPostService` 已注册于 DI 容器，NoticeJobController 构造函数新增参数

### 提交给 Pro 的问题
1. 路由路径变化 `autopost/notice/qywx` → `job/notice/qywx`，是否需要确认上游调用方已同步更新？
2. AutoPostController 仍持有 `_autoPostService` 引用用于另两个方法，是否需要考虑后续拆分 Service？
