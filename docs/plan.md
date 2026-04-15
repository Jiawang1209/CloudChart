# CloudChart 后续计划

> **当前状态**：Hub + 4 个子应用（core 21 / advanced 13 / statistics 16 / data_tools 14，共 **64 个模块**）已跑通。Tab body 与 module server 均为 lazy 挂载：点开哪个 tab 才构建对应 `bs4TabCard`、注册对应 `moduleServer`、attach 该组依赖包。**冷启动 3.27s → 0.55s（6×）**，UI build **2.0s → 0.11s（18×）**。`tests/smoke/` 下 4 个脚本、**512 个断言**一键执行，通过 `Rscript tests/smoke/run_all.R` 验证 registry / example 回环 / lazy 启动 / 上传+DT filter 链路。

---

## 近期（1–2 周）

### 1. 上传 / DataTable 链路加固
- [x] 复现 "Submit File 后 DT `searchable[j] argument is of length zero`"：
  `tests/smoke/test_dt_click.R` 走 `shiny::testServer()` 驱动
  `file_upload_Server` + 直接调用 `DT:::dataTablesFilter()` 同时覆盖
  "submit → sanitize → render" 和 server-side filter path，并带一条
  "长度为零" 回归探针（缺 `q$escape` 时才触发）。
- [x] 在 `file_upload_Server` 的 `renderDT` 外层加 `tryCatch`，失败时
  渲染成单行 "Preview failed: …" 表而不是抛裸 JS warning；
  `renderUI` 里 `bgc_data_summary()` 也外包 tryCatch，坏帧走
  红色 `bgc_upload_error_panel()`。
- [x] `read_uploaded_table` 读到结果后调用 `sanitize_uploaded_table()`：
  trim 列名空白、空/NA 名补 `V<idx>`、`make.unique()` 去重、默认丢掉
  全 NA 列（可 `drop_all_na_cols = FALSE` 保留）。合法列名原样保留。
- [x] `.xlsx` / `.tsv` 单独回归用例入 `test_example_roundtrip.R`
  （xlsx 要 `writexl`，缺失时 skip 不 fail）。

### 2. 回归测试扩展
- [x] `tests/smoke/test_module_registry.R`、`test_example_roundtrip.R`、
  `test_lazy_boot.R`、`test_dt_click.R` 与 `run_all.R` runner（512 断言全绿）。
- [ ] 加一个 headless Playwright / chromote 脚本：启动 hub → 对每个组第一个
  模块点 Preview Example → 断言 DT 无 console error。**环境注记**：本机
  chromote 0.5.1 + Chrome 当前组合下 "Chrome debugging port not open"，即使
  `--headless=new` + 隔离 `--user-data-dir` 也起不来；直接 shell 跑 Chrome
  DevTools 端口能开——怀疑是 chromote 的 stderr scrape 在新版 Chrome 下
  漏读。暂用 in-process `testServer` + `DT:::dataTablesFilter()` mock
  顶上，这一条留作跨环境真浏览器冒烟的后续项。
- [ ] 在 CI（或本地 `make smoke`）里串起 `Rscript tests/smoke/run_all.R`
  + headless 点击脚本，PR 合并前必跑。

### 3. 日志与诊断
- [ ] 把现存所有 `cat("[bgc] …")` / `message("[bgc] …")` 统一收敛到
  `bgc_log(..., level = "debug")`，由 `options(bgc.debug = TRUE)` 开关驱动，
  默认关闭，避免 CI / 生产输出噪音。
- [ ] `bgc_loaded_groups` 状态暴露一个 `bgc_debug_report()` 辅助函数，
  dump 当前已加载组 + 时间戳，便于排查 lazy 加载时序问题。

### 4. 文件输入体验补完
- [x] 上传 widget "记住上次文件名"：`bgc_session_upload_cache()` 在
  `session$rootScope()$userData` 上挂一个共享 `reactiveVal`，
  `uploaded_table_reactive()` 改为写入/读取该 rv，58 个调用方零改动继承。
  切 tab 到新模块后 `df()` 直接返回上次上传的数据；若新模块需要
  `row_names = TRUE`（PCA / UMAP / NMDS 等），通过 `bgc_cached_compute()`
  按原始 datapath 重新解析一次并记忆。`file_upload_Server` 的 Data Summary
  在当前模块尚未提交时展示 "`shared.csv` (shared from another tab)" 提示。
- [x] Preview 表统一走 `DT::DTOutput` + 分页：`basic_stats_UI` /
  `basic_data_tools_UI` / `module_data_export` 的 `tableOutput` 全部迁移到
  `DT::DTOutput`，经由新的 `bgc_preview_datatable()` helper 统一走
  `server = FALSE` + `formatSignif(digits = 4)` + tryCatch 错误回退。
- [x] 大文件（>50MB）上传时显示 `withProgress`：`uploaded_table_reactive()`
  里的 `observeEvent(input$submit_file, ...)` 包一层
  `shiny::withProgress(message = sprintf("Reading %s", fu$name), ...)`
  含 parsing → done 两档进度，解析失败改由
  `shiny::showNotification(..., type = "error")` 提示，不再静默等待或崩栈。

---

## 中期（1–2 个月）

### 5. 统一结果导出
- [x] `bind_plot_outputs()`：在现有 helper 基础上扩出 PDF / PNG / SVG 三档
  切换（`input$Format` radioGroupButtons），新增 `DownloadParams`（当前
  input 序列化为 yaml，过滤 `file_upload` / `file_output_*` / 按钮等控制项）
  与 `DownloadData`（可选 `data_fn` 返回处理后 data.frame → CSV）。
  40 个 plot 模块（27 现代 + 13 迁移）统一继承，无需改模块。
  `ggplot2_plot_download_UI` 同步加入 Format / Params / Data 三枚按钮。
  `yaml` 加入 `bgc_group_packages$base`。新增 10 条冒烟断言覆盖
  `bgc_plot_extension` / `bgc_plot_device` 三格式写入 / `bgc_serialize_inputs`
  过滤规则 + yaml round-trip。
- [x] 每个模块支持 **"复现脚本" 导出**：`bgc_reproduce_script()` 把当前
  input 序列化成一段带 `library()` / `params <- list(...)` / 数据加载
  stub / ggplot2 骨架的 R 代码块，用户贴回 RStudio 替换 `df` 即可继续
  分析。`output$DownloadScript` 由 `bind_plot_outputs()` 自动注册，所有
  40 个 plot 模块零改动继承。下载 UI 用 `shinyWidgets::dropdownButton`
  把 Params / Data / Script 收进 "Export" 菜单，主按钮维持 "Plot"。

### 6. 性能与启动
- [x] Lazy tab materialization（tab body + server + 包加载）—— 冷启动
  3.27s → 0.55s。
- [x] PCA / UMAP / t-SNE / PCoA / NMDS 计算结果走 `bgc_cached_compute()`：
  全局 `bgc_dr_cache_env` + `digest::xxhash64`，key 包含算法 id + 输入
  矩阵 + 可调参数（seed / distance / k / trymax / correction），命中
  直接返回，失命才调用真 compute。切换美化参数不触发重算，连续切到
  同一组合的降维无成本。提供 `bgc_dr_cache_clear()` / `bgc_dr_cache_size()`
  辅助 + 6 条冒烟断言覆盖命中 / key 变化 / 数据突变 / 清空。
- [ ] 首页 logo / adminlte 图标走本地 `www/`，去掉残留的 CDN 外链
  （离线 / 代理环境下体验不好）。
- [x] 把 Preview / Results 的 `DT::renderDT` 降级为 `server = FALSE`，
  规避 server-side filter 的 `searchable[j] length zero` 一类 bug；
  小数据集下 client-side 渲染成本可忽略。

### 7. UI 一致性
- [ ] 把 `basic_advance_plot_UI` / `basic_stats_UI` / `basic_data_tools_UI`
  抽出一个共同 shell，四类 tab 的 Example / Data / Run / Results 顺序
  完全一致。
- [ ] 参数面板统一使用 `bgc_advanced_options()`（已存在的
  `<details>` 组件），把 "Advanced Options" 默认收起。
- [ ] Dark / Light 皮肤在首页 feature card、valueBox、DT 表头下都保持
  足够对比度。

### 8. 文档与示例
- [ ] `docs/modules/` 为每个模块写一页最小示例（输入列 / 参数 / 输出样例），
  Introduction tab 直接引用。
- [ ] README 增加 "故障排查" 一节：DT 报错、jQuery 冲突、pandoc 缺失、
  lme4 编译失败等高频问题。
- [ ] 写一篇 "从 iris 到论文图" 的 end-to-end 教程。

---

## 长期（季度级）

### 9. 部署
- [ ] `Dockerfile` + `docker-compose`（R + renv + 依赖锁定）。
- [ ] shinyapps.io / Posit Connect 部署说明。
- [ ] 公网演示站点（只开 core + advanced，关闭文件写入）。

### 10. 数据持久化（可选）
- [ ] 登录后保存 "最近打开的分析"。目前纯 stateless，不做登录；如果加，
  优先 sqlite + 本地模式。

### 11. 扩展生态
- [ ] `tools/register_module.R` 交互脚本：向导式注册新模块，自动生成
  两个 module 文件骨架 + 追加到 `app_specs.R` + 追加到 `bgc_module_files`，
  降低外部贡献者出错概率。
- [ ] 外部模块包机制：支持 `bgc_plugin::register("<group>", spec, files)`，
  不需要改主仓库就能装第三方模块。

---

## 非目标（明确不做）

- 不引入 Node / bundler / TypeScript，保持纯 R + Shiny。
- 不做登录 / 多租户 / 云存储（与 "桌面级科研工具" 定位冲突）。
- 不替换 bs4Dash；主题与布局依赖它提供的网格与组件。
- 不追求 90%+ 单元测试覆盖；以冒烟 + 回归点击脚本 + 手工验收为主。

---

## 风险与观察点

- **bs4Dash 升级风险**：lazy 挂载依赖 `sidebarMenu(id = "sidebarmenu")`
  通过 `input$sidebarmenu` 暴露当前 tabName。升级 bs4Dash 后需再次确认；
  若行为回归，需要降级为 eager 注册或改为 `input$<tabName>` 轮询方案。
- **jQuery / bootstrap-select 冲突**：任何从 CDN 引入 jQuery / bootstrap
  的改动都可能破坏 `shinyWidgets` 的 selectpicker / pickerInput。涉及
  `bgc_head()` 的 PR 需要重点审查并跑 headless click smoke。
- **DT `searchable[j]` 类故障**：DT server-side filter 对列名空字符串 /
  重复列名非常敏感。所有进入 `DT::datatable` 的数据都应先走一层
  "列名健康检查"（见近期 §1）。
- **外链资源**：首页 logo、adminlte 图标来自外链，离线 / 代理环境下
  404 不影响功能但体验差——搬到 `www/` 是必要清理。
