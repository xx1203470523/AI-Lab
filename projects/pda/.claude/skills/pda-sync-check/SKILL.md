---
name: pda-sync-check
description: "PDA 数据同步核查：PDA 提交后 Web 数据未更新、PDA 离线同步失败、PDA 与 Web 数据不一致。触发关键词：PDA 同步、数据不同步、离线同步、提交超时、同步失败、PDA 提交、PDA 数据丢失、PDA 一致性。"
shell: powershell
version: 1.0.0
---

# PDA 数据同步检查

## Trigger

- PDA 提交后 Web 端数据未更新
- PDA 离线操作同步失败
- PDA 与 Web 数据不一致

## Goal

防止：

- 数据丢失
- 状态不同步
- 重复提交

## Checklist

- [ ] PDA 端是否显示提交成功
- [ ] 后端 API 请求是否有日志记录
- [ ] 数据库数据状态是否符合预期
- [ ] 重复提交是否被正确拦截

## Common Fix

1. 提交超时但后端已处理 → 前端重新查询状态，不重复提交
2. 离线操作 → 恢复连接后批量同步，每条有唯一标识
3. 数据不一致 → 对比 PDA 本地记录与后端数据库，差异上报

## Forbidden

- 禁止 PDA 端仅凭提交成功提示判断流程结束
- 禁止离线同步时不带幂等标识
