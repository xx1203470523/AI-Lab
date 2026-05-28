---
name: api-debug
description: "前端 API 调试：页面数据加载失败、接口返回异常、新增接口对接。检查请求链路、参数、响应、权限、环境。触发关键词：接口报错、接口异常、API 报错、Network、跨域、proxy、token 过期、接口对接、参数不一致、404、500、401、CORS。"
shell: powershell
version: 1.0.0
---

# Skill: API Debug

## Trigger

- 页面数据加载失败
- 接口返回异常
- 新增接口对接

## Goal

快速定位前后端接口问题

## Checklist

### 1. 请求链路检查
- API 函数是否正确导入（`@/api/{module}/{file}`）
- URL 路径与后端路由是否匹配
- HTTP 方法是否正确（get/post/put/delete）
- 参数位置：get 用 `params`，post/put 用 `data`

### 2. 参数检查
- 分页参数：`pageNum` / `pageSize` 是否传递
- 日期格式：是否与后端期望一致（`YYYY-MM-DD HH:mm:ss`）
- 必填字段是否遗漏
- 参数名大小写是否与后端一致

### 3. 响应检查
- `res.code == 200` 判断是否正确
- 数据路径：`res.data.result` / `res.data.totalNum`
- 后端返回格式是否与 API 文件注释一致

### 4. 权限检查
- 接口是否需要 `[ActionPermissionFilter]`
- 当前用户是否拥有权限标识
- `v-hasPermi` 权限字符串是否与后端一致

### 5. 环境检查（开发环境常见）
- 是否正确站点/据点
- API Proxy URL 是否配置正确
- 刷新 token 是否过期

## Common Fix

1. URL 拼写错误 → 对照后端路由修正
2. 参数名不一致 → 统一使用 camelCase
3. 缺少必填参数 → 补充后重试
4. 权限不足 → 检查用户角色权限分配
5. 跨域/代理问题 → 检查 Vite proxy 配置

## Forbidden

- 不检查 Network 面板直接怀疑后端
- 请求失败后不查看错误响应体
