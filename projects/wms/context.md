# WMS 项目上下文

## 模块概览

| 项目                 | 技术栈                     | 说明          |
| -------------------- | -------------------------- | ------------- |
| IMTC.WMS.AdminWebApi | .NET 8 + Furion + SqlSugar | 后端 API 核心 |
| IMTC.WMS.AdminUI     | Vue 3 + Element Plus       | 管理端 Web    |
| IMTC.WMS.PDA         | UniApp + HBuilder          | PDA 手持终端  |

## 后端模块

### 入库 InStock

ASN（预到货通知）→ 收货 → 分选 → 上架 → ARN（退货），PDA 收货/PDA 上架

### 出库 OutStock

拣料单 → 配送 → 发货，PDA 拣料/PDA 配送

### 在库 OnStock

调拨、移库、料件转换、盲盘

### 库存 Stock

库存查询、库存交易、库存标签

### 报表 Report

入库/出库/库存/质检/调拨等综合报表

### 系统 System

用户、角色、菜单、部门、字典、配置

### 集成 Integration

T100、WMS 调拨
