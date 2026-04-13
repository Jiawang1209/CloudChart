# Changelog

All notable changes to **CloudChart** are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project aims to follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
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
- `R/core/app_specs.R`
  - Registered the four new statistics specs inside `bgc_plot_specs$statistics`
  - Added their 8 source files to `bgc_module_files$statistics`
  - Declared `survival` inside `bgc_group_packages$statistics` so the
    statistics sub app pulls it via `bgc_ensure_group_loaded("statistics")`

## [0.2.0] — 2026-04-13

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
