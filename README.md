# CloudChart

<div align="center">
  <img src="./www/CloudChart.png" width="220">
</div>

A Shiny-based scientific research visualization platform. CloudChart turns
common research data workflows (plotting, dimension reduction, statistics,
data wrangling) into point-and-click analyses. Pure R — no Node, no Python,
no database.

## Architecture

CloudChart ships as a **portal hub + four independent sub apps**, not as a
monolithic Shiny app. Each sub app boots only the packages and modules its
domain needs, so startup stays fast and dependencies stay contained.

```
CloudChart/
├── app.R                      # Portal hub (loads all 4 groups)
├── apps/
│   ├── core_plots/            # groups = "core"
│   ├── advanced_plots/        # groups = "advanced"
│   ├── statistics/            # groups = "statistics"
│   └── data_tools/            # groups = "data_tools"
├── R/
│   ├── core/                  # Bootstrap, factory, registry, layout chrome
│   ├── shared/                # Upload / download helpers, tab shells
│   └── modules/               # 64 module pairs across 4 groups
├── tests/smoke/               # Regression smoke suite (registry / round-trip / lazy boot)
├── www/                       # Static assets
├── data/                      # Example datasets
└── legacy/                    # Pre-refactor monolith (reference only)
```

Every entrypoint does the same three things:

1. `source("R/core/app_bootstrap.R")`
2. `bgc_bootstrap(root_dir, groups = <groups>)` — load base + group-specific
   packages, source the module files listed in `bgc_module_files`
3. `bgc_plot_app_ui()` + `bgc_plot_app_server()` — the factory reads
   `bgc_plot_specs` and auto-wires sidebar, tabs, and servers

Tab bodies and module servers are **lazy**: a tab's `bs4TabCard`,
`moduleServer`, and per-group `library()` calls only run the first time the
user clicks into that tab. Cold start on the full hub dropped from
**3.27s → 0.55s** (6×), UI build from **2.0s → 0.11s** (18×).

## Modules at a glance (64 total)

| Group | Count | Coverage |
|---|---|---|
| **Core Plots** | 21 | Dot, Bubble, Bar, Line, Box, Smooth Line, Violin, Pie, Donut, Density, Density+Histogram, Histogram, Ridgeline, Lollipop, Radar, Heatmap, Stacked Area, Waterfall, Dumbbell, Slope Chart, Waffle |
| **Advanced Plots** | 13 | PCA, PCoA, t-SNE, UMAP, RDA, Volcano, Correlation Matrix, Sankey / Alluvial, Treemap, Dendrogram, NMDS, Manhattan, MA Plot |
| **Statistics** | 16 | t-test, One-way ANOVA, Correlation, Linear Regression, Wilcoxon, Chi-square, Kruskal–Wallis, Fisher's Exact, Shapiro–Wilk, Post-hoc (Tukey / pairwise t / pairwise Wilcoxon), Logistic Regression (OR + CI + McFadden R²), Survival (Kaplan–Meier + log-rank), Effect Size (Cohen's d / η² / Cramér's V), Permutation Test, Mixed Effects (lme4), Pairwise Comparison Matrix |
| **Data Tools** | 14 | Filter Rows, Select / Rename, Summarize, Missing Values, Pivot Wider/Longer, Sort / Distinct, Mutate / Cast, Join Tables, Group & Aggregate, Export, Separate / Unite, Parse Date / Time, Find Duplicates, Sample / Slice |

Every module follows the same `Example Data → Data & Parameters → Results`
tab layout. Statistics modules share a one-click **Run Analysis** button,
printable summary, results table, and CSV download via `bind_stats_outputs()`.

## Running

```r
# Hub — all four groups (default)
shiny::runApp(".")

# Or any single sub app directly
shiny::runApp("apps/core_plots")
shiny::runApp("apps/advanced_plots")
shiny::runApp("apps/statistics")
shiny::runApp("apps/data_tools")
```

## Adding a new module

The registry in `R/core/app_specs.R` is the single source of truth. Adding a
module only touches that file plus the two new module files — never the
factory or sidebar.

1. Write the pair under `R/modules/<group>/`:
   - `module_<name>_parameters.R` — parameter UI returning a `fluidPage`
   - `module_<name>.R` — the `moduleServer` implementation
2. Append a spec to `bgc_plot_specs[[<group>]]` in `R/core/app_specs.R`.
   For statistics / data-tools modules set `layout = "stats"` or
   `layout = "data_tools"` so the factory picks the right tab shell.
3. Append both filenames to `bgc_module_files[[<group>]]`.
4. (Optional) Declare extra packages in `bgc_group_packages[[<group>]]` so
   other sub apps stay slim.

Factory, sidebar, and tab wiring pick it up automatically on next boot.

Statistics modules should render through `bind_stats_outputs(output, input,
print_fn, table_fn, filename_prefix)` (in `R/shared/basic_stats_UI.R`). That
gives every module a consistent summary pane, results table, and CSV
download for free.

## Adding a new sub app (new domain)

1. `cp apps/app_template.R apps/<domain>/app.R` and set `group_name`.
2. Add the new group key to `bgc_plot_specs`, `bgc_group_menu_config`,
   `bgc_module_files`, and `bgc_group_packages` in `R/core/app_specs.R`.
3. Put module pairs under `R/modules/<domain>/`.

## Regression smoke tests

```bash
Rscript tests/smoke/run_all.R
```

Three scripts, run in fresh Rscript subprocesses, currently 486 assertions:

| Script | What it pins |
|---|---|
| `test_module_registry.R` | every spec's `id`/`title`/`parameter_ui`/`server_fun`/`example_data`/`layout` resolves; every `bgc_module_files` path exists on disk |
| `test_example_roundtrip.R` | every example dataset survives a `write.csv(row.names=FALSE)` → `read_uploaded_table()` round-trip with preserved ncol / nrow / column names (guards the DT `searchable[j]` warning) |
| `test_lazy_boot.R` | `bgc_loaded_groups` is empty at boot; `bgc_body_fn_for(spec)` renders the right `nav-item` count per layout; all groups flip to loaded after probing |

## Screenshots

UI captures live in [`docs/screenshots/`](docs/screenshots/README.md), named
`<sub_app>__<module_id>.png`.

## Changelog & Plan

- [`CHANGELOG.md`](CHANGELOG.md) — release history.
- [`docs/plan.md`](docs/plan.md) — short / medium / long-term roadmap.

## Status

The refactor from the original monolithic dashboard into the hub + four
sub apps above is complete. All 64 modules are registered and boot-tested
via the smoke suite. The legacy entrypoint (`legacy/app_2.R`) is kept for
reference only — do not run it.

## Affiliation

Biogeochemistry Group · Institute of Applied Ecology · Chinese Academy of Sciences
[http://www.iae.cas.cn/biogeochemistry/](http://www.iae.cas.cn/biogeochemistry/)
