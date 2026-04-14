# Changelog

All notable changes to **CloudChart** are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project aims to follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- **Core plots** — Slope Chart (`slope_chart`) and Waffle Chart (`waffle_chart`).
- **Advanced plots** — NMDS (`nmds`), Manhattan (`manhattan`), and MA Plot (`ma_plot`).
- **Statistics** — Permutation Test (`stats_permutation`), Mixed Effects Model
  (`stats_mixed_effects`, `lme4`), and Pairwise Comparison matrix
  (`stats_pairwise`).
- **Data Tools** — Separate / Unite (`data_separate_unite`),
  Parse Date / Time (`data_date_parse`), Find Duplicates (`data_duplicates`),
  and Sample / Slice (`data_sample_slice`).
- **Statistics — Post-hoc Tests** (`stats_posthoc`)
  - Tukey HSD (after one-way ANOVA), pairwise t-test, pairwise Wilcoxon
  - Holm / BH (FDR) / Bonferroni / none p-value adjustment
- **Statistics — Logistic Regression** (`stats_logreg`)
  - Binary outcome via `glm(family = binomial)`
  - Coefficients with odds ratios and confidence intervals
  - McFadden pseudo R² in the summary pane
- **Statistics — Survival / Kaplan–Meier** (`stats_survival`)
  - `survival::survfit` fit with optional grouping
  - Log-rank test via `survdiff`, configurable `rho` (log-rank vs Peto)
  - Requires the `survival` package (auto-loaded by the statistics sub app)
- **Statistics — Effect Size** (`stats_effect_size`)
  - Cohen's d for 2-group numeric comparisons (with magnitude label)
  - η² / partial η² / ω² for one-way ANOVA layouts
  - Cramér's V (and φ for 2×2) for contingency tables
- README: new **Modules at a glance** table listing every module group
- README: documented the `layout = "stats"` / `"data_tools"` contract and the
  `bind_stats_outputs` helper used by statistics modules
- `docs/screenshots/` placeholder directory for upcoming UI captures

### Changed
- **Lazy tab materialization** — `bgc_plot_tabs` now emits cheap
  `uiOutput(NS(spec$id, "tab_body"))` placeholders, and
  `bgc_register_plot_servers` defers `bs4TabCard` construction, module
  server registration, and per-group package loading until
  `input$sidebarmenu` first activates a given tab. Cold start on the full
  hub drops from **3.27s → 0.55s** and UI build from **2.0s → 0.11s**.
  Every group's `library()` calls are pulled in exactly once, on first
  entry, via `bgc_ensure_group_loaded()`.
- `R/shared/basic_advance_plot_UI.R`,
  `R/shared/basic_stats_UI.R`,
  `R/shared/basic_data_tools_UI.R` — extracted each shell's inner
  `fluidPage(bs4TabCard(...))` into a pure `*_body(inputid, fun)` helper
  so the factory can call it on demand inside the lazy `renderUI`. The
  public `basic_*_UI(tabName, inputid, title, fun)` wrappers are unchanged.
- `R/core/app_factory.R` — added `bgc_body_fn_for(spec)` layout dispatcher,
  rewrote `bgc_plot_tabs`, `bgc_register_plot_servers`, and
  `bgc_plot_app_server` around the lazy-install pattern.
- `R/core/app_specs.R`
  - Registered 10 new specs: `slope_chart`, `waffle_chart` (core);
    `nmds`, `manhattan`, `ma_plot` (advanced);
    `stats_permutation`, `stats_mixed_effects`, `stats_pairwise`
    (statistics); `data_separate_unite`, `data_date_parse`,
    `data_duplicates`, `data_sample_slice` (data_tools).
  - Added 20 module source files to the matching `bgc_module_files` lists.
  - Declared `lme4` in `bgc_group_packages$statistics` so the new mixed
    effects module pulls it on first entry to the statistics group.
  - Registered the four new statistics specs inside `bgc_plot_specs$statistics`
  - Added their 8 source files to `bgc_module_files$statistics`
  - Declared `survival` inside `bgc_group_packages$statistics` so the
    statistics sub app pulls it via `bgc_ensure_group_loaded("statistics")`

### Fixed
- **Example-data download round-trip** — the download handler in
  `R/shared/module_show_example_data.R` now writes with
  `row.names = FALSE` (previously defaulted to `TRUE`, leaking an
  unnamed index column). Re-uploading the downloaded CSV no longer
  yields a phantom 6th column, and the DataTables JS warning
  `searchable[j] argument is of length zero` is gone.
- **File upload default quote** — `file_upload_UI` now defaults to
  `Double Quote` instead of `None` so vanilla CSVs (including our own
  example downloads) parse correctly without requiring users to change
  the Quote option. `None` and `Single Quote` remain available for
  files that need them.

### Added
- **Statistics sub app** with initial 9 modules: t-test, one-way ANOVA,
  correlation, linear regression, Wilcoxon, chi-square, Kruskal–Wallis,
  Fisher's exact, Shapiro–Wilk
- **Data Tools sub app** with 6 modules: filter rows, select / rename,
  summarize, missing values, pivot wider/longer, sort / distinct
- Category icons on every sidebar submenu group
- Orphan plots registered into the core/advanced groups

### Changed
- `R/core/app_specs.R`, `R/core/app_factory.R`, `R/core/homepage.R` updated to
  wire the new statistics and data tools sub apps through the existing
  factory pipeline

## [0.1.0] — Initial refactor

### Added
- Portal hub + independent sub apps architecture
  - `app.R` as a lightweight portal
  - `apps/core_plots/`, `apps/advanced_plots/` as standalone entrypoints
- `R/core/` factory (`bgc_plot_app_ui`, `bgc_plot_app_server`,
  `bgc_bootstrap`, `bgc_ensure_group_loaded`)
- `R/shared/` helpers for file upload, example data, parameter shells,
  plot download, theme and palette wiring
- Core plot modules (dot, bubble, bar, line, box, smooth line, violin, pie,
  donut, density, density+histogram, histogram, ridgeline, lollipop, radar,
  heatmap, stacked area)
- Advanced plot modules (PCA, PCoA, t-SNE, UMAP, RDA, volcano, correlation
  matrix)
- Legacy monolithic dashboard kept under `legacy/` for reference only
