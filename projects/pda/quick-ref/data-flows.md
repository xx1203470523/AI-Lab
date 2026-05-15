# PDA 业务数据流

> 查数据来源和页面跳转链路时先看这个，不用逐个页面翻代码。

## 菜单加载链路

```
App Launch (App.vue onLaunch)
  ↓ 加载字典、配置、版本检查
  ↓ 登录成功获取 token
  ↓
tabbar/work.nvue
  → API: getRouters() → GET /getRouters
  → 后端返回菜单树，过滤 pda 根节点
  → 渲染为可折叠分组菜单
  → 点击叶子节点 → navigateToPage(meta.link)
```

## 入库链路

```
登录 → 工作台(work) → 收货(receipt)
  ├── 扫描 ASN/ARN 标签 → API: check() → 检查是否可收货
  ├── 显示收货明细 → 填写实收数量
  ├── 确认收货 → API: confirm() → POST /business/InstockReceipt/confirm
  └── 紧急上架 → API: emergencyOn() → POST /business/InstockReceipt/emergencyOn

收货 → 上架(putaway)
  ├── 扫描收货标签 → 获取上架任务
  ├── 扫描库位标签 → 确认上架库位
  └── 确认上架 → API: POST /business/InstockUpShelves/confirm
```

### 收货常用字段来源

| 目标字段 | 来源 | 说明 |
|----------|------|------|
| 标签内容 | PDA 蓝牙扫描 | 格式: `MaterialCode#Feature#Qty#...#SerialNo` |
| 解析后物料信息 | `explainLabel()` | mixins/global.js 解析标签 |
| ASN/ARN 信息 | API check() 返回 | 后端查 InStockAsnHead/InStockArnHead |
| 实收数量 | 用户手动输入 | 提交到 confirm() |

## 出库链路

```
登录 → 工作台(work) → 拣料(pickorder)
  ├── 扫描发货单/拣料单标签 → 获取拣料任务
  ├── 扫描物料标签 → 确认拣料
  ├── 输入拣料数量
  └── 确认拣料 → API: POST /business/OutStockPickOrder/confirm

拣料 → 发货(outbound)
  ├── 扫描拣料单标签 → 获取发货任务
  ├── 扫描物料标签 → 确认发货
  └── 确认发货 → API: POST /business/OutStockShipment/confirm
```

## 调拨链路

```
登录 → 工作台(work) → 调拨(allot)
  ├── 调出扫描 → API: allotOutLabelScanAsync() → POST /onstock/OnStockAllot/out/scan
  ├── 调入扫描 → API: allotInLabelScanAsync() → POST /onstock/OnStockAllot/in/scan
  ├── 调入上架扫描 → API: allotInPutawayLabelScanAsync() → POST /onstock/OnStockAllot/in/putaway/scan
  ├── 确认 → API: confirmAsync() → POST /onstock/OnStockAllot/confirm
  ├── 便捷过账 → API: easyPostingAsync() → POST /onstock/OnStockAllot/easy/posting/{id}
  ├── 反审 → API: countertrialAsync() → POST /onstock/OnStockAllot/countertrial/{id}
  └── 冲销过账 → API: reversePostingAsync() → POST /onstock/OnStockAllot/reverse/posting/{id}
```

## 盘点链路

```
登录 → 工作台(work) → 盘点(inventory)
  ├── 扫描盘点单标签 → 获取盘点任务
  ├── 扫描库位/物料标签 → 录入盘点数据
  └── 提交盘点 → API: 盘点确认接口

明盘 vs 盲盘:
  ├── 明盘(inventory): 知晓理论库存，逐项核对
  └── 盲盘(blindInventory): 不知理论库存，扫描后系统比对
```

## 库存转换链路

```
登录 → 工作台(work) → 库存转换(stock-transformation)
  ├── 形态转换: 物料A → 物料B (同一物料不同形态)
  └── 属性转换: 物料属性变更 (批次/等级等)
```

## 标签解析规则

```
扫描标签字符串:
  MaterialCode#Feature#Qty#ProjectNo#PurchaseNo#PurchaseItem#DeliverNo#DeliverItem#SN#SerialNo

解析入口: mixins/global.js → explainLabel()
  ├── 旧版 9 段规则 (兼容)
  └── 新版 10 段规则 (当前标准)
```

## 分选链路

```
登录 → 工作台(work) → 分选(sorting)
  ├── 扫描分选单标签 → 获取分选任务
  ├── 扫描物料标签 → 分配到目标库位/容器
  └── 确认分选 → API: 分选确认接口
```

## HTTP 请求公共链路

```
页面调用 API 函数 (e.g. api/onstock/allot.js)
  → utils/request.js (get/post/put/del/upload)
  → 自动注入 Headers:
      Authorization: Bearer <token>
      site: <当前站点>
      device: PDA
      traceId: <UUID>
      timezone: <时区>
      timestamp: <时间戳>
      version: <App版本>
  → uni.request()
  → 响应拦截:
      ├── 200: 返回 data
      ├── 401: 触发重新登录 (debounced)
      ├── 业务错误: 播放错误语音 + toast (1200ms 冷却)
      └── 网络错误: 幂等方法自动重试 (指数退避, 300ms base)
```
