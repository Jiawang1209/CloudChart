ggplot2_parameters_volcano_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      
      # Set x Axis Variable
      column(width = 2, bgc_column_select(id, "x_axis", "Set x axis variable", selected = "log2FoldChange")),
      
      # Set y Axis Variable
      column(width = 2, bgc_column_select(id, "y_axis", "Set y axis variable", selected = "pvalue")),
      
      # Set fill Variable
      column(width = 2, bgc_column_select(id, "color_variable", "Set color variable", selected = "change")),
      
      # Set Size Variable
      column(width = 2, bgc_column_select(id, "size_variable", "Set size variable", selected = "pvalue")),
      
      # Set point alpha
      column(width = 2, sliderInput(NS(id, "point_alpha"), "Set point alpha", value = 0.75, min = 0, max = 1))
    ),
    tags$hr(),
    # set box plot
    fluidRow(
      align = "center",
      # Set fold change cut off
      column(width = 3, sliderInput(NS(id, "log2fold_change"), "log2(Fold Change) Cutoff", value = 1.5, min = 0, max = 10)),
      # Set pvalue cut off
      column(width = 3, sliderInput(NS(id, "pvalue"), "Pvalue/Qvalue Cutoff", value = 0.05, min = 0, max = 1)),
      # Set Up gene color
      column(width = 2, colourInput(NS(id, "up_color"), "Set Up gene color", value = "#FF733B")),
      # Set Normal gene color
      column(width = 2, colourInput(NS(id, "normal_color"), "Set Normal gene color", value = "#969696")),
      # Set Down gene color
      column(width = 2, colourInput(NS(id, "down_color"), "Set Down gene color", value = "#76C9FA"))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      # Set hline cut line type
      column(width = 2,
             pickerInput(NS(id, "hlinetype"),
                         label = "Bar Border Type",
                         choices = c("dashed","solid",
                                     "twodash", "dotdash",
                                     "longdash","dotted",
                                     "blank"),
                         options = list(style = "btn-primary"))),
      # Set hline cut line color
      column(width = 2,
             colourInput(NS(id, "hcolor"), label = "Set hline color", value = "#000000")),
      # Set vline cut line type
      column(width = 2,
             pickerInput(NS(id, "vlinetype"),
                         label = "Bar Border Type",
                         choices = c("dashed","solid",
                                     "twodash", "dotdash",
                                     "longdash","dotted",
                                     "blank"),
                         options = list(style = "btn-primary"))),
      # Set vline cut line color
      column(width = 2,
             colourInput(NS(id, "vcolor"), label = "Set vline color", value = "#000000")),
      # Set size range
      column(width = 2,
             sliderInput(NS(id, "sizechange"),
                         label = "Set size range",
                         value = c(5,10),
                         min = 0,
                         max = 20)),
      # Set plot label
      column(width = 2,
             sliderInput(NS(id, "label_size"),
                         label = "Set Label Size",
                         value = 20,
                         min = 5,
                         max = 50))
    ),
    bgc_advanced_options(
      fluidRow(
        align = "center",
        column(width = 2, textInput(NS(id, "plot_title"), "Set plot title",value = NULL)),
        column(width = 2, textInput(NS(id, "plot_subtitle"), "Set plot subtitle",value = NULL)),
        column(width = 2, textInput(NS(id, "x_axis_Title"), "Set x axis title",value = "log2(FoldChange)")),
        column(width = 2, textInput(NS(id, "y_axis_Title"), "Set y axis title", value = "-log10(pvalue)")),
        column(width = 2, numericRangeInput(NS(id, "x_limite"), "Set x axis limites", value = c(NA, NA))),
        column(width = 2, numericRangeInput(NS(id, "y_limite"), "Set y axis limites", value = c(NA, NA)))
      ),
      tags$hr(),
      prettyRadioButtons(inputId = NS(id, "theme_choose"),
                         label = "Theme Choose:",
                         choiceNames = c("default","theme:bw","theme:classic","theme:clean","theme:GraphPadPrism",
                                         "theme:excel", "theme:stata","theme:economist","theme:GoogleDocs","theme:WallStreetJournal"),
                         choiceValues = c("theme_grey", "theme_bw", "theme_classic","theme_clean", "theme_prism", "theme_excel_new",
                                          "theme_stata", "theme_economist_white","theme_gdocs", "theme_wsj"),
                         icon = icon("check"),
                         animation = "tada",
                         inline = TRUE
      )
    )
    # prettyRadioButtons(inputId = NS(id, "discrete_fill_choose"),
    #                    label = "Discrete fill Palettes:",
    #                    choiceNames = c("default","NPG","AAAS","NEJM","Lancet","JAMA","JCO","UCSCGB","D3","LocusZoom","IGV","UChicago"),
    #                    choiceValues = c("", "scale_fill_npg","scale_fill_aaas","scale_fill_nejm","scale_fill_lancet",
    #                                     "scale_fill_jama","scale_fill_jco","scale_fill_ucscgb","scale_fill_d3",
    #                                     "scale_fill_locuszoom","scale_fill_igv","scale_fill_uchicago"),
    #                    icon = icon("check"),
    #                    animation = "tada",
    #                    inline = TRUE
    # )
    # prettyRadioButtons(inputId = NS(id, "continuous_fill_choose"),
    #                    label = "Continuous fill Palettes:",
    #                    choiceNames = c("default","Red","Pink","Purple","Indigo","Blue","Cyan","Teal",
    #                                    "Green","Lime","Yellow","Amber","Orange","Brown","Grey"),
    #                    choiceValues = c("","red","pink","purple","indigo","blue","cyan","teal",
    #                                     "green","lime","yellow","amber","orange","brown","grey"),
    #                                     icon = icon("check"),
    #                    animation = "tada",
    #                    inline = TRUE)
  )
}
