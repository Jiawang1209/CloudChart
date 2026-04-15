# Static dependency hints for rsconnect / shinyapps.io.
# Runtime packages are attached dynamically via bgc_bootstrap(), so the
# rsconnect static scanner never sees explicit library() calls for them.
# This file is never sourced; the `if (FALSE)` block exists solely so
# renv::dependencies (used by rsconnect) picks up every package declared
# in bgc_group_packages.
if (FALSE) {
  library(bs4Dash)
  library(colourpicker)
  library(dplyr)
  library(DT)
  library(FactoMineR)
  library(ggalluvial)
  library(ggdendro)
  library(ggplot2)
  library(ggprism)
  library(ggsci)
  library(ggthemes)
  library(hrbrthemes)
  library(lme4)
  library(plotly)
  library(readxl)
  library(rlang)
  library(Rtsne)
  library(shiny)
  library(shinyWidgets)
  library(stringr)
  library(survival)
  library(treemapify)
  library(umap)
  library(vegan)
  library(waiter)
  library(yaml)
}
