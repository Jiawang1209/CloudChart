# CloudChart 未来计划

> 当前状态：Hub + 4 个子应用（core 19 / advanced 10 / statistics 13 / data_tools 10，共 52 个模块）已跑通。首页、测试数据预览、所有模块 server 已在 session 初始化时 eager 注册。

---

## 近期（1–2 周）

### 1. 稳定性与回归测试
- [ ] `tests/smoke/` 下补齐 4 个组的冒烟脚本：加载 app、逐个 spec 校验 `server_fun` / `example_data` / `parameter_ui` 可解析。
- [ ] 增加一个 "启动并点一遍 Preview Example" 的 Playwright/chromote 脚本，回归检测 jQuery / bootstrap-select 之类的 UI 冲突。
- [ ] 把 `[bgc]` 级别的诊断日志收敛到 `options(bgc.debug = TRUE)` 开关，避免 CI 输出噪音。

### 2. 模块补缺
- [ ] **core**：补 waffle / streamgraph / slope chart 等常见但尚未覆盖的类型。
- [ ] **advanced**：补 NMDS、CCA（RDA 的近亲）、MA plot、Manhattan。
- [ ] **statistics**：补 permutation test、mixed effects (lme4)、多重比较矩阵可视化。
- [ ] **data_tools**：补 unite/separate、date parsing、duplicates 检测、sample/slice。

### 3. 文件输入体验
- [ ] 上传模块支持 `.xlsx`（readxl）与 `.tsv`，当前只支持 csv。
- [ ] Preview 表支持分页（DT）而非 `tableOutput`，大文件不崩。
- [ ] 记住上一次上传文件名，避免每次切 tab 重新上传。

---

## 中期（1–2 个月）

### 4. 统一结果导出
- [ ] 把 `bind_stats_outputs()` 的模式推广到 core/advanced：`bind_plot_outputs()` 统一 PNG/PDF/SVG + 处理后数据 CSV 导出。
- [ ] 每个模块支持 "复现脚本" 导出（把当前参数序列化成可运行的 R 代码块）。

### 5. 性能与启动
- [ ] `bgc_ensure_group_loaded()` 改成真正的 lazy：用户首次进入该 group 的 tab 时再 `library()`，而不是 server 初始化就全部 attach。
- [ ] 大模块（PCA/UMAP）的计算结果在 session 内 memoise，切换参数不反复重算。
- [ ] 首页图片/图标走本地 `www/` 而不是外链 CDN，去掉残留的网络依赖。

### 6. UI 一致性
- [ ] 把 `basic_advance_plot_UI` / `basic_stats_UI` / `basic_data_tools_UI` 抽出一个共同 shell，四类 tab 的控件/标签顺序完全一致。
- [ ] 参数面板使用可折叠的 `details`（已有 `.bgc-advanced-options` 样式），把 "高级选项" 收起。
- [ ] Dark / Light 皮肤在首页 feature card、valueBox 下都保持可读。

### 7. 文档与示例
- [ ] `docs/modules/` 为每个模块写一页最小示例（输入列、参数、输出样例），Introduction tab 直接引用。
- [ ] README 补齐 "添加一个新模块" 的 5 步 checklist（目前在 CLAUDE.md 内，应该给最终用户看）。
- [ ] 写一篇 "从 iris 到论文图" 的 end-to-end 教程。

---

## 长期（季度级）

### 8. 部署
- [ ] Dockerfile + docker-compose（R + renv + 依赖锁定）。
- [ ] shinyapps.io / Posit Connect 部署说明。
- [ ] 公网演示站点（只开 core + advanced，关闭文件写入）。

### 9. 数据持久化（可选）
- [ ] 登录后保存 "最近打开的分析"。目前纯 stateless，不做登录；如果加，优先 sqlite + 本地模式。

### 10. 扩展生态
- [ ] 外部贡献者只需新增 `R/modules/<group>/module_<name>*.R` + 在 `app_specs.R` 追加一条 spec 就能加模块，完善开发者文档。
- [ ] 把 `bgc_plot_specs` 结构抽成 `tools/register_module.R` 交互脚本，降低注册出错概率。

---

## 非目标（明确不做）

- 不引入 Node / bundler / TS，保持纯 R + Shiny。
- 不做登录 / 多租户 / 云存储（与"桌面级科研工具"定位冲突）。
- 不替换 bs4Dash；主题与布局都依赖它提供的网格与组件。
- 不追求 90%+ 测试覆盖，冒烟 + 手工回归为主。

---

## 风险与观察点

- **bs4Dash 升级风险**：`sidebarMenu` 未暴露 `input$sidebarmenu` 绑定，当前靠 eager 注册回避。后续升级要重新确认这个行为。
- **jQuery 冲突**：任何从 CDN 引入 jQuery / bootstrap 的改动都可能破坏 `shinyWidgets` 的 selectpicker / pickerInput。PR 里涉及 `bgc_head()` 的改动要重点审查。
- **外链资源**：首页 logo 和 adminlte 图标来自外链，离线/代理环境下 404 不影响功能但体验差——搬到 `www/` 是必要清理。
