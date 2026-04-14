# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project

**CloudChart** — a Shiny-based scientific research visualization platform.
It turns common research analyses (plotting, dimension reduction, statistics,
data wrangling) into point-and-click workflows. Pure R; no Node, no Python,
no database.

## Architecture: portal hub + independent sub apps

CloudChart is **not** a monolithic Shiny app. It ships as a lightweight portal
plus four independent sub apps, each of which boots only the packages and
modules its domain needs.

```
CloudChart/
├── app.R                        # Portal hub entrypoint (loads all 4 groups)
├── apps/
│   ├── core_plots/app.R         # groups = "core"
│   ├── advanced_plots/app.R     # groups = "advanced"
│   ├── statistics/app.R         # groups = "statistics"
│   ├── data_tools/app.R         # groups = "data_tools"
│   └── app_template.R           # Copy-paste template for a new sub app
├── R/
│   ├── core/
│   │   ├── app_bootstrap.R      # bgc_bootstrap(root_dir, groups)
│   │   ├── app_factory.R        # bgc_plot_app_ui / bgc_plot_app_server
│   │   ├── app_specs.R          # THE registry — specs, packages, file lists
│   │   ├── component4UI.R       # Head / header / footer / sidebar chrome
│   │   ├── homepage.R           # Hub landing page
│   │   └── Introduction_UI.R    # Shared intro tab
│   ├── shared/
│   │   ├── basic_advance_plot_UI.R   # Plot tab shell (core + advanced)
│   │   ├── basic_stats_UI.R          # Stats tab shell + bind_stats_outputs()
│   │   ├── basic_data_tools_UI.R     # Data-tools tab shell
│   │   ├── module_file_upload.R      # Shared upload/preview
│   │   ├── module_show_example_data.R
│   │   ├── module_ggplot2_plot_download.R
│   │   ├── module_ggplot2_plotly.R
│   │   └── module_plot_helpers.R
│   └── modules/
│       ├── core/                # 18 plot module pairs
│       ├── advanced/            # 7+ advanced plot module pairs
│       ├── statistics/          # 13 stats module pairs
│       └── data_tools/          # 6 data-wrangling module pairs
├── www/                         # Static assets (logo, carousel images)
├── data/                        # Example datasets
└── legacy/                      # Pre-refactor monolith — DO NOT RUN / EDIT
```

### Boot flow

Every entrypoint does exactly three things:

1. `source("R/core/app_bootstrap.R")`
2. `bgc_bootstrap(root_dir, groups = <groups>)` — loads base packages,
   group-specific packages (from `bgc_group_packages`), and sources the
   module files listed in `bgc_module_files`.
3. `bgc_plot_app_ui(...)` + `bgc_plot_app_server(...)` — the factory reads
   `bgc_plot_specs` and auto-wires sidebar, tabs, and servers.

The hub (`app.R`) loads all four groups. A single sub app loads only its one
group, so startup stays fast and dependencies stay contained.

## Module convention (hard rule)

Every analysis is a **pair** of files under `R/modules/<group>/`:

- `module_<name>_parameters.R` — parameter UI, returns a `fluidPage(...)`
- `module_<name>.R` — the `moduleServer` implementation

Naming is `ggplot2_*` for plots and `data_*` / `stats_*` for the tool groups.
Both files must be listed in `bgc_module_files` inside `app_specs.R` or the
bootstrap loader will not find them.

## The registry: `R/core/app_specs.R`

This file is the single source of truth. Adding a module means editing
**only** this file plus the two new module files — never the factory or
sidebar. It defines:

- `bgc_group_packages` — per-group package lists; `base` is always loaded.
- `bgc_plot_specs` — list keyed by group; each entry has
  `id`, `title`, `parameter_ui`, `server_fun`, `example_data`, `icon`,
  and (for non-plot groups) `layout = "stats"` or `layout = "data_tools"`
  so the factory picks the right tab shell.
- `bgc_module_files` — filenames to source per group.
- `bgc_group_menu_config` — sidebar heading + icon per group.

## Shared tab shells

Do not reinvent per-module layout. Use the matching shell:

| Group      | Shell function         | Layout key         |
|------------|------------------------|--------------------|
| core       | `basic_advance_plot_UI`| (default)          |
| advanced   | `basic_advance_plot_UI`| (default)          |
| statistics | `basic_stats_UI`       | `layout = "stats"` |
| data_tools | `basic_data_tools_UI`  | `layout = "data_tools"` |

Every shell provides the standard `Example Data → Data & Parameters → Results`
tab layout, upload widget, and example-data pane.

Statistics modules should push results through
`bind_stats_outputs(output, input, print_fn, table_fn, filename_prefix)`
(defined in `R/shared/basic_stats_UI.R`) to get the summary pane, results
table, and CSV download for free.

## Running

```r
# Hub — all groups (default)
shiny::runApp(".")

# Single sub app
shiny::runApp("apps/core_plots")
shiny::runApp("apps/advanced_plots")
shiny::runApp("apps/statistics")
shiny::runApp("apps/data_tools")
```

Do not start the Shiny server as a "check" unless the user asks — R smoke
tests under `/tmp/smoke_test_cloudchart.R`-style scripts are the usual way
the user wants boot correctness verified.

## Adding a new module (the only workflow)

1. Write `R/modules/<group>/module_<name>_parameters.R` and
   `module_<name>.R`. Copy the closest existing sibling as a starting point.
2. Append a spec to `bgc_plot_specs[[<group>]]` in `R/core/app_specs.R`.
   Set `layout` for stats / data_tools.
3. Append both filenames to `bgc_module_files[[<group>]]`.
4. If you need new packages, add them to `bgc_group_packages[[<group>]]`.
5. That's it — factory, sidebar, and tab wiring pick it up automatically.

## Adding a new sub app (new domain)

1. `cp apps/app_template.R apps/<domain>/app.R` and set `group_name`.
2. Add the new group to `bgc_plot_specs`, `bgc_group_menu_config`,
   `bgc_module_files`, and `bgc_group_packages`.
3. Put modules under `R/modules/<domain>/`.

## Things to avoid

- **Never** touch `legacy/` — it is the pre-refactor monolith, kept only
  for reference.
- Do not edit `app_factory.R` to register a new module; use `app_specs.R`.
- Do not hardcode package `library()` calls inside a module — declare them
  in `bgc_group_packages` so other sub apps stay slim.
- Do not introduce build tools, Node, bundlers, or non-R infra. This is a
  pure R + Shiny project.
- Do not add emojis, comments restating what code does, or backwards-compat
  shims. Follow the user's global coding-style rules.

## Language and tone

The user is Chinese; respond in Chinese when the user writes in Chinese.
UI strings inside the app are a mix of English and Chinese — match the
surrounding file.
