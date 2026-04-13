# CloudChart

<div align="center">
  <img src="./www/CloudChart.png" width="220">
</div>

A Shiny visualization platform for the **Biogeochemistry Group** of the Institute of
Applied Ecology, Chinese Academy of Sciences. CloudChart turns common biogeochemical
data analysis tasks (plotting, dimension reduction, statistics, data wrangling) into
point-and-click workflows.

## Architecture

CloudChart ships as a **portal hub + independent sub apps**, not as one monolithic Shiny
app. Each sub app boots only the packages and modules it needs, so startup stays fast
and future work stays contained.

```
CloudChart/
├── app.R                    # Portal hub (lightweight, default entrypoint)
├── apps/
│   ├── core_plots/          # dot, bubble, bar, line, box, violin, pie ...
│   ├── advanced_plots/      # PCA, PCoA, t-SNE, UMAP, RDA, volcano
│   ├── statistics/          # reserved scaffold
│   └── data_tools/          # reserved scaffold
├── R/
│   ├── core/                # Bootstrap, factory, specs, layout chrome
│   ├── shared/              # Plot upload / download / helpers / parameter shell
│   └── modules/
│       ├── core/            # Basic plot module pairs (15 plots × 2 files)
│       ├── advanced/        # Advanced plot module pairs (6 plots × 2 files)
│       ├── statistics/      # (placeholder)
│       └── data_tools/      # (placeholder)
├── www/                     # Static assets
├── data/                    # Example datasets
└── legacy/                  # Pre-refactor monolithic snapshot (do not use)
```

The **portal hub** is a thin landing page that points users at each sub app. It
intentionally does NOT load any plotting dependencies, so the hub itself starts
in well under a second.

Each sub app is just an `app.R` file that:

1. Sources `R/app_bootstrap.R`
2. Calls `bgc_bootstrap(root_dir, groups = "<group_name>")` to load only the
   packages and modules that group needs
3. Builds its UI/server through `bgc_plot_app_ui()` / `bgc_plot_app_server()`

## Running

From the project root:

```r
# Hub (recommended starting point)
shiny::runApp(".")

# Or any single sub app directly
shiny::runApp("apps/core_plots")
shiny::runApp("apps/advanced_plots")
shiny::runApp("apps/statistics")
shiny::runApp("apps/data_tools")
```

## Adding a new plot

1. Create the parameter UI module and the plotting server module under
   `R/modules/<group>/` (e.g. `R/modules/core/` or `R/modules/advanced/`).
2. Register the plot in `R/core/app_specs.R` under the matching group inside
   `bgc_plot_specs`.
3. List its files in `bgc_module_files` so the bootstrap loader can find them.
4. (Optional) Declare any extra packages it needs in `bgc_group_packages`.

No edit to the factory, sidebar, or tab wiring is required — `app_factory.R`
will pick up the new spec automatically.

## Adding a new sub app (new domain)

1. Copy `apps/app_template.R` into `apps/<your_domain>/app.R`.
2. Pick a `group_name` and add it to `bgc_plot_specs`, `bgc_group_menu_config`,
   `bgc_module_files`, and `bgc_group_packages` in `R/core/app_specs.R`.
3. Add the modules under `R/`.

## Status

This project is undergoing an active refactor from a single monolithic dashboard
into the hub + sub app architecture above. The legacy entrypoint (`legacy/app_2.R`)
is kept for reference only; do not run it.

## Affiliation

Biogeochemistry Group · Institute of Applied Ecology · Chinese Academy of Sciences
[http://www.iae.cas.cn/biogeochemistry/](http://www.iae.cas.cn/biogeochemistry/)
