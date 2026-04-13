# ---------------------------------------------------------------------------
# Per-group package declarations.
#
# `base` packages are loaded for every entrypoint (including the portal hub).
# Group-specific packages are loaded only when that group is requested.
# Keep heavy dependencies (Rtsne, umap, factoextra, leaflet, ...) inside the
# group that needs them.
# ---------------------------------------------------------------------------
bgc_group_packages <- list(
  base = c(
    "shiny",
    "bs4Dash",
    "shinyWidgets",
    "colourpicker",
    "waiter"
  ),
  core = c(
    "ggplot2",
    "dplyr",
    "stringr",
    "plotly",
    "ggthemes",
    "hrbrthemes",
    "ggprism",
    "colourpicker",
    "ggsci"
  ),
  advanced = c(
    "ggplot2",
    "dplyr",
    "stringr",
    "plotly",
    "ggthemes",
    "ggsci",
    "colourpicker",
    "Rtsne",
    "umap",
    "vegan",
    "FactoMineR"
  ),
  statistics = character(),
  data_tools = character()
)

bgc_plot_specs <- list(
  core = list(
    list(
      id = "dot_plot",
      title = "Dot Plot",
      parameter_ui = "ggplot2_parameters_dotplot_UI",
      server_fun = "ggplot2_dotplot_Server",
      example_data = "iris_df"
    ),
    list(
      id = "bubble_plot",
      title = "Bubble Plot",
      parameter_ui = "ggplot2_parameters_bubble_UI",
      server_fun = "ggplot2_bubble_plot_Server",
      example_data = "diamond_df"
    ),
    list(
      id = "bar_plot",
      title = "Bar Plot",
      parameter_ui = "ggplot2_parameters_barplot_UI",
      server_fun = "ggplot2_barplot_Server",
      example_data = "barplot_df"
    ),
    list(
      id = "line_plot",
      title = "Line Plot",
      parameter_ui = "ggplot2_parameters_line_UI",
      server_fun = "ggplot2_lineplot_Server",
      example_data = "line_df"
    ),
    list(
      id = "box_plot",
      title = "Box Plot",
      parameter_ui = "ggplot2_parameters_boxplot_UI",
      server_fun = "ggplot2_boxplot_Server",
      example_data = "boxplot_df"
    ),
    list(
      id = "smooth_line_plot",
      title = "Smooth Line Plot",
      parameter_ui = "ggplot2_parameters_smooth_line_UI",
      server_fun = "ggplot2_smooth_lineplot_Server",
      example_data = "smooth_df"
    ),
    list(
      id = "violin_plot",
      title = "Violin Plot",
      parameter_ui = "ggplot2_parameters_violin_UI",
      server_fun = "ggplot2_violin_Server",
      example_data = "violin_df"
    ),
    list(
      id = "pie_plot",
      title = "Pie Plot",
      parameter_ui = "ggplot2_parameters_pieplot_UI",
      server_fun = "ggplot2_pieplot_Server",
      example_data = "pie_df"
    ),
    list(
      id = "donut_plot",
      title = "Donut Plot",
      parameter_ui = "ggplot2_parameters_dountplot_UI",
      server_fun = "ggplot2_dountplot_Server",
      example_data = "pie_df"
    ),
    list(
      id = "density_plot",
      title = "Density Plot",
      parameter_ui = "ggplot2_parameters_density_plot_UI",
      server_fun = "ggplot2_density_plot_Server",
      example_data = "density_df"
    ),
    list(
      id = "density_plot_2",
      title = "Density + Histogram",
      parameter_ui = "ggplot2_parameters_density_plot_2_UI",
      server_fun = "ggplot2_density_plot_2_Server",
      example_data = "density_df"
    ),
    list(
      id = "histogram_plot",
      title = "Histogram Plot",
      parameter_ui = "ggplot2_parameters_histogram_plot_UI",
      server_fun = "ggplot2_histogram_plot_Server",
      example_data = "histogram_df"
    ),
    list(
      id = "ridgeline_plot",
      title = "Ridgeline Plot",
      parameter_ui = "ggplot2_parameters_rigeline_UI",
      server_fun = "ggplot2_rigeline_Server",
      example_data = "diamond_df"
    ),
    list(
      id = "lollipop_plot",
      title = "Lollipop Plot",
      parameter_ui = "ggplot2_parameters_lollipop_UI",
      server_fun = "ggplot2_lollipop_plot_Server",
      example_data = "lollipop_df"
    ),
    list(
      id = "radar_plot",
      title = "Radar Plot",
      parameter_ui = "ggplot2_parameters_radar_plot_UI",
      server_fun = "ggplot2_radar_plot_Server",
      example_data = "radar_df"
    ),
    list(
      id = "heatmap",
      title = "Heatmap",
      parameter_ui = "ggplot2_parameters_heatmap_UI",
      server_fun = "ggplot2_heatmap_Server",
      example_data = "diamond_df"
    ),
    list(
      id = "stacked_area",
      title = "Stacked Area",
      parameter_ui = "ggplot2_parameters_stacked_area_UI",
      server_fun = "ggplot2_stacked_area_Server",
      example_data = "line_df"
    )
  ),
  advanced = list(
    list(
      id = "pca",
      title = "PCA Plot",
      parameter_ui = "ggplot2_parameters_pca_UI",
      server_fun = "ggplot2_pca_Server",
      example_data = "iris_df"
    ),
    list(
      id = "pcoa",
      title = "PCoA Plot",
      parameter_ui = "ggplot2_parameters_pcoa_UI",
      server_fun = "ggplot2_pcoa_Server",
      example_data = "iris_df"
    ),
    list(
      id = "tsne",
      title = "t-SNE Plot",
      parameter_ui = "ggplot2_parameters_tsne_UI",
      server_fun = "ggplot2_tsne_Server",
      example_data = "iris_df"
    ),
    list(
      id = "umap",
      title = "UMAP Plot",
      parameter_ui = "ggplot2_parameters_umap_UI",
      server_fun = "ggplot2_umap_Server",
      example_data = "iris_df"
    ),
    list(
      id = "rda",
      title = "RDA Plot",
      parameter_ui = "ggplot2_parameters_rda_UI",
      server_fun = "ggplot2_rda_Server",
      example_data = "iris_df"
    ),
    list(
      id = "volcano_plot",
      title = "Volcano Plot",
      parameter_ui = "ggplot2_parameters_volcano_UI",
      server_fun = "ggplot2_volcano_Server",
      example_data = "violent_df"
    ),
    list(
      id = "corr_matrix",
      title = "Correlation Matrix",
      parameter_ui = "ggplot2_parameters_corr_matrix_UI",
      server_fun = "ggplot2_corr_matrix_Server",
      example_data = "iris_df"
    )
  ),
  statistics = list(
    list(
      id = "stats_ttest",
      title = "t-test",
      parameter_ui = "stats_parameters_ttest_UI",
      server_fun = "stats_ttest_Server",
      example_data = "iris_df",
      layout = "stats"
    ),
    list(
      id = "stats_anova",
      title = "One-way ANOVA",
      parameter_ui = "stats_parameters_anova_UI",
      server_fun = "stats_anova_Server",
      example_data = "iris_df",
      layout = "stats"
    ),
    list(
      id = "stats_correlation",
      title = "Correlation",
      parameter_ui = "stats_parameters_correlation_UI",
      server_fun = "stats_correlation_Server",
      example_data = "iris_df",
      layout = "stats"
    )
  ),
  data_tools = list(
    list(
      id = "data_filter",
      title = "Filter Rows",
      parameter_ui = "data_tools_parameters_filter_UI",
      server_fun = "data_tools_filter_Server",
      example_data = "iris_df",
      layout = "data_tools"
    ),
    list(
      id = "data_select",
      title = "Select / Rename",
      parameter_ui = "data_tools_parameters_select_UI",
      server_fun = "data_tools_select_Server",
      example_data = "iris_df",
      layout = "data_tools"
    ),
    list(
      id = "data_summarize",
      title = "Summarize",
      parameter_ui = "data_tools_parameters_summarize_UI",
      server_fun = "data_tools_summarize_Server",
      example_data = "iris_df",
      layout = "data_tools"
    )
  )
)

bgc_group_menu_config <- list(
  core = list(label = "Core Plots", icon = "bar-chart"),
  advanced = list(label = "Advanced Plots", icon = "area-chart"),
  statistics = list(label = "Statistics", icon = "calculator"),
  data_tools = list(label = "Data Tools", icon = "table")
)

bgc_reserved_apps <- list(
  statistics = list(
    title = "CloudChart Statistics",
    subtitle = "Statistical tests, model summaries and comparative analysis modules will live here.",
    next_steps = c(
      "Add statistical module UI and server files under R/.",
      "Register those modules in R/app_specs.R under the statistics group.",
      "Keep heavy statistical dependencies inside this app only."
    )
  ),
  data_tools = list(
    title = "CloudChart Data Tools",
    subtitle = "Data cleaning, reshaping, filtering and export workflows will live here.",
    next_steps = c(
      "Add data utility module UI and server files under R/.",
      "Register those modules in R/app_specs.R under the data_tools group.",
      "Use this app for preprocessing before plotting or statistics."
    )
  )
)

bgc_module_files <- list(
  core = c(
    "R/modules/core/module_ggplot2_dotplot_parameters.R",
    "R/modules/core/module_ggplot2_dotplot.R",
    "R/modules/core/module_ggplot2_bubble_plot_parameters.R",
    "R/modules/core/module_ggplot2_bubble_plot.R",
    "R/modules/core/module_ggplot2_barplot_parameters.R",
    "R/modules/core/module_ggplot2_barplot.R",
    "R/modules/core/module_ggplot2_lineplot_parameters.R",
    "R/modules/core/module_ggplot2_lineplot.R",
    "R/modules/core/module_ggplot2_boxplot_parameters.R",
    "R/modules/core/module_ggplot2_boxplot.R",
    "R/modules/core/module_ggplot2_smooth_line_parameters.R",
    "R/modules/core/module_ggplot2_smooth_lineplot.R",
    "R/modules/core/module_ggplot2_violin_parameters.R",
    "R/modules/core/module_ggplot2_violin.R",
    "R/modules/core/module_ggplot2_pieplot_parameters.R",
    "R/modules/core/module_ggplot2_pieplot.R",
    "R/modules/core/module_ggplot2_dount_chart_parameters.R",
    "R/modules/core/module_ggplot2_dount_chart.R",
    "R/modules/core/module_ggplot2_density_plot_parameters.R",
    "R/modules/core/module_ggplot2_density_plot.R",
    "R/modules/core/module_ggplot2_density_plot_2_parameters.R",
    "R/modules/core/module_ggplot2_density_plot_2.R",
    "R/modules/core/module_ggplot2_histogram_plot_parameters.R",
    "R/modules/core/module_ggplot2_histogram_plot.R",
    "R/modules/core/module_ggplot2_rigeline_parameters.R",
    "R/modules/core/module_ggplot2_ridgeline_plot.R",
    "R/modules/core/module_ggplot2_lollipop_plot_parameters.R",
    "R/modules/core/module_ggplot2_lollipop_plot.R",
    "R/modules/core/module_ggplot2_radar_plot_parameters.R",
    "R/modules/core/module_ggplot2_radar_plot.R",
    "R/modules/core/module_ggplot2_heatmap_parameters.R",
    "R/modules/core/module_ggplot2_heatmap.R",
    "R/modules/core/module_ggplot2_stacked_area_parameters.R",
    "R/modules/core/module_ggplot2_stacked_area.R"
  ),
  advanced = c(
    "R/modules/advanced/module_ggplot2_pca_plot_parameters.R",
    "R/modules/advanced/module_ggplot2_pca_plot.R",
    "R/modules/advanced/module_ggplot2_pcoa_plot_parameters.R",
    "R/modules/advanced/module_ggplot2_pcoa_plot.R",
    "R/modules/advanced/module_ggplot2_tsne_plot_parameters.R",
    "R/modules/advanced/module_ggplot2_tsne_plot.R",
    "R/modules/advanced/module_ggplot2_umap_plot_parameters.R",
    "R/modules/advanced/module_ggplot2_umap_plot.R",
    "R/modules/advanced/module_ggplot2_rda_plot_parameters.R",
    "R/modules/advanced/module_ggplot2_rda_plot.R",
    "R/modules/advanced/module_ggplot2_volcano_parameters.R",
    "R/modules/advanced/module_ggplot2_volcano.R",
    "R/modules/advanced/module_ggplot2_corr_matrix_parameters.R",
    "R/modules/advanced/module_ggplot2_corr_matrix.R"
  ),
  statistics = c(
    "R/modules/statistics/module_stats_ttest_parameters.R",
    "R/modules/statistics/module_stats_ttest.R",
    "R/modules/statistics/module_stats_anova_parameters.R",
    "R/modules/statistics/module_stats_anova.R",
    "R/modules/statistics/module_stats_correlation_parameters.R",
    "R/modules/statistics/module_stats_correlation.R"
  ),
  data_tools = c(
    "R/modules/data_tools/module_data_filter_parameters.R",
    "R/modules/data_tools/module_data_filter.R",
    "R/modules/data_tools/module_data_select_parameters.R",
    "R/modules/data_tools/module_data_select.R",
    "R/modules/data_tools/module_data_summarize_parameters.R",
    "R/modules/data_tools/module_data_summarize.R"
  )
)
