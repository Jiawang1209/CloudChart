ggplot2_parameters_dendrogram_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 12, bgc_multi_column_select(id, "metadata_columns", "Metadata / label columns (excluded from clustering)"))
    ),
    fluidRow(
      align = "center",
      column(width = 3, bgc_column_select(id, "label_column", "Label column (optional, used as leaf labels)"))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 3,
             prettyRadioButtons(NS(id, "cluster_on"),
                                label = "Cluster On",
                                choiceNames = c("Rows","Columns"),
                                choiceValues = c("rows","columns"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 3,
             pickerInput(NS(id, "dist_method"),
                         label = "Distance Method",
                         choices = c("euclidean","manhattan","maximum","canberra","binary","minkowski"),
                         selected = "euclidean",
                         options = list(style = "btn-primary"))),
      column(width = 3,
             pickerInput(NS(id, "hclust_method"),
                         label = "Linkage Method",
                         choices = c("complete","ward.D","ward.D2","single","average","mcquitty","median","centroid"),
                         selected = "complete",
                         options = list(style = "btn-primary"))),
      column(width = 3,
             prettyRadioButtons(NS(id, "orientation"),
                                label = "Orientation",
                                choiceNames = c("Top","Right","Bottom","Left"),
                                choiceValues = c("top","right","bottom","left"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 2,
             prettyRadioButtons(NS(id, "scale_data"),
                                label = "Scale Features",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("No","Yes"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 2, sliderInput(NS(id, "k_groups"), "Highlight k Groups", value = 0, min = 0, max = 12, step = 1)),
      column(width = 2, colourInput(NS(id, "branch_color"), "Branch Color", value = "#2C3E50")),
      column(width = 2, sliderInput(NS(id, "branch_width"), "Branch Width", value = 0.6, min = 0, max = 3, step = 0.1)),
      column(width = 2, sliderInput(NS(id, "label_size"), "Label Size", value = 14, min = 5, max = 40)),
      column(width = 2, colourInput(NS(id, "label_color"), "Label Color", value = "#000000"))
    ),
    bgc_advanced_options(
      fluidRow(
        align = "center",
        column(width = 3, textInput(NS(id, "plot_title"), "Set plot title", value = NULL)),
        column(width = 3, textInput(NS(id, "plot_subtitle"), "Set plot subtitle", value = NULL)),
        column(width = 3, textInput(NS(id, "x_axis_Title"), "Set x axis title", value = NULL)),
        column(width = 3, textInput(NS(id, "y_axis_Title"), "Set y axis title", value = NULL))
      ),
      tags$hr(),
      prettyRadioButtons(inputId = NS(id, "discrete_color_choose"),
                         label = "Group Highlight Palette:",
                         choiceNames = c("default","NPG","AAAS","NEJM","Lancet","JAMA","JCO","UCSCGB","D3","LocusZoom","IGV","UChicago"),
                         choiceValues = c("", "scale_color_npg","scale_color_aaas","scale_color_nejm","scale_color_lancet",
                                          "scale_color_jama","scale_color_jco","scale_color_ucscgb","scale_color_d3",
                                          "scale_color_locuszoom","scale_color_igv","scale_color_uchicago"),
                         icon = icon("check"),
                         animation = "tada",
                         inline = TRUE),
      prettyRadioButtons(inputId = NS(id, "theme_choose"),
                         label = "Theme Choose:",
                         choiceNames = c("default","theme:bw","theme:classic","theme:clean","theme:GraphPadPrism",
                                         "theme:excel","theme:stata","theme:economist","theme:GoogleDocs","theme:WallStreetJournal"),
                         choiceValues = c("theme_grey","theme_bw","theme_classic","theme_clean","theme_prism","theme_excel_new",
                                          "theme_stata","theme_economist_white","theme_gdocs","theme_wsj"),
                         icon = icon("check"),
                         animation = "tada",
                         inline = TRUE)
    )
  )
}
