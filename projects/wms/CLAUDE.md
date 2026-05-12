# WMS 领域上下文

> 对应项目：`IMTC.WMS.AdminWebApi`（核心 WMS 业务部分）

## 业务模块

| 模块 | 说明 |
|------|------|
| InStock | ASN → 收货 → 分选 → 上架 → ARN（退货） |
| OutStock | 拣料单 → 配送 → 发货 |
| OnStock | 调拨、移库、料件转换、盲盘 |
| Stock | 库存查询、库存交易、库存标签 |

## 核心技能

- 防重复提交（PDA 场景）
- 库存一致性校验
- PDA 数据同步检查
