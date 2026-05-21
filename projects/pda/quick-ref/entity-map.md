# PDA 页面→API 速查

> 改某个页面时快速定位 API 文件和后端 Controller，避免全仓搜索。

## 入库 (Receipt/Putaway)

| 业务对象 | PDA 页面 | API 文件 | 后端 Controller |
|----------|----------|----------|----------------|
| 收货单 | `pages/receipt/*` | `api/instock/receipt.js`, `api/instock/receipt-pda.js` | `InstockReceiptController` |
| ASN 预到货 | `pages/receipt/*` | `api/instock/asn.js` | `InStockAsnController` |
| ARN 预收货 | `pages/receipt/*` | `api/instock/arn.js` | `InstockArnHeadController` |
| 上架单 | `pages/putaway/*` | `api/instock/on.js` | `InStockUpShelvesController` |
| 上架单-修改过账日期 | `pages/putaway/operation/index.nvue` | `api/instock/on.js` → `updatePostDateAsync()` | `InStockUpShelvesController` → `updatePostDate` |
| 紧急上架 | `pages/on/*` | `api/instock/receipt.js` (emergencyOn) | `InstockReceiptController` |

## 出库 (Pick/Shipment)

| 业务对象 | PDA 页面 | API 文件 | 后端 Controller |
|----------|----------|----------|----------------|
| 拣料单 | `pages/pickorder/*` | `api/outstock/pick.js`, `api/outstock/pick-pda.js` | `OutStockPickOrderController` |
| 发货单 | `pages/outbound/*` | `api/outstock/warehouse-delivery.js` | `OutStockDeliveryController` |
| 发货确认 | `pages/outbound/*` | `api/outstock/confirm.js` | `OutStockShipmentController` |

## 在库 (Allot/Transfer/Inventory)

| 业务对象 | PDA 页面 | API 文件 | 后端 Controller |
|----------|----------|----------|----------------|
| 调拨单 | `pages/allot/*` | `api/onstock/allot.js` | `OnStockAllotController` |
| 库存转移 | `pages/stock/*` | `api/onstock/transfer.js` | — |
| 盘点单 | `pages/inventory/*` | `api/onstock/inventory.js` | — |
| 盲盘 | `pages/blindInventory/*` | `api/onstock/blindinventory.js` | — |
| 形态转换 | `pages/stock-transformation/*` | `api/stock-transformation/material.js`, `api/stock-transformation/properties.js` | `OnStockModalshiftController` |
| 物料备料 | — | `api/onstock/materialprepare.js` | — |
| 库位查询 | `pages/warehouseBin/*` | `api/onstock/bin.js` | — |

## 运营 (Operations)

| 业务对象 | PDA 页面 | API 文件 | 后端 Controller |
|----------|----------|----------|----------------|
| 订单配送 | `pages/operations/*` | `api/operations/order-delivery.js` | — |
| 仓库异常 | `pages/operations/*` | `api/operations/warehouse-exception.js` | — |

## 分选 (Sorting)

| 业务对象 | PDA 页面 | API 文件 | 后端 Controller |
|----------|----------|----------|----------------|
| 分选单 | `pages/sorting/*` | `api/sorting/sorting.js` | `InStockSortingController` |

## 标签 (Label)

| 业务对象 | PDA 页面 | API 文件 | 后端 Controller |
|----------|----------|----------|----------------|
| 标签拆分 | `pages/labelSpilit/*` | `api/label/index.js` | — |
| 标签打印 | `pages/labels/*`, `pages/print/*` | `api/common/label.js`, `api/common/printer.js` | — |
| 库存标签 | `pages/stock/*` | `api/wh/label.js`, `api/wh/stock.js` | — |

## 质检 (Qual)

| 业务对象 | PDA 页面 | API 文件 | 后端 Controller |
|----------|----------|----------|----------------|
| 质检单 | `pages/qual/*` | `api/qual/index.js` | `QualChecklistController` |

## 通用 (Common/System)

| 业务对象 | PDA 页面 | API 文件 | 后端 Controller |
|----------|----------|----------|----------------|
| 登录 | `pages/login.vue` | `api/login.js` | — |
| 动态菜单 | `pages/tabbar/work.nvue` | `api/system/menu.js` | `SysMenuController` |
| 用户信息 | `pages/mine/*` | `api/system/user.js` | `SysUserController` |
| 字典数据 | — | `api/system/dict/` | `SysDictDataController` |
| 站点切换 | — | `api/system/site.js` | — |
| 系统配置 | — | `api/system/config.js` | — |
| 容器查询 | — | `api/common/container.js` | — |
| 物料查询 | — | `api/common/material.js` | — |
| 拣料员 | — | `api/common/picker.js` | — |
| 仓库查询 | — | `api/base/warehouse.js` | — |
| 版本更新 | — | `api/app/version.js` | — |
| 物流 | `pages/logistics/*` | `api/logistics/index.js` | — |
| 单据 | `pages/doc/*` | `api/doc/whstocklabeldoc.js` | — |

## PDA 特有扫描 API 模式

PDA 页面扫描标签后通常调用命名如 `xxxScanAsync` 的 API，遵循以下模式：

```javascript
// 出库扫描
allotOutLabelScanAsync(input)   → POST /onstock/OnStockAllot/out/scan
// 入库扫描
allotInLabelScanAsync(input)    → POST /onstock/OnStockAllot/in/scan
// 上架扫描
allotInPutawayLabelScanAsync(input) → POST /onstock/OnStockAllot/in/putaway/scan
```

这类 API 接收扫描到的标签字符串，返回解析后的业务数据。
