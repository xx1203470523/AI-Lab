# Bug 分析技能

## 通用排查流程
1. **复现路径** — 确定触发条件（输入数据、操作步骤、环境）
2. **日志定位** — 查 NLog 日志（`Admin.WebApi/NLog.config`），找异常堆栈
3. **数据追溯** — 查数据库确认数据状态是否符合预期
4. **代码走读** — 从 Controller 到 Service 到 Repository 逐层检查
5. **边界条件** — 空值、并发、状态冲突、大数量

## 常见 Bug 模式

### 空引用
- Min()/Max() 在空集合上抛 `InvalidOperationException`
- 修复：使用前 `.Count > 0` 判断

### 并发状态冲突
- 两个请求同时修改同一条记录的状态
- 修复：乐观锁或分布式锁

### 数据权限遗漏
- 查询未过滤站点 (`SiteCode`)
- 修复：Repository 层默认加 `DataPermission` 过滤
