data_tools_parameters_sample_slice_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 12,
             prettyRadioButtons(NS(id, "operation"),
                                label = "Operation",
                                choiceNames = c("Random sample N",
                                                "Random fraction",
                                                "Slice by row range",
                                                "Head N",
                                                "Tail N"),
                                choiceValues = c("sample_n", "sample_frac",
                                                 "slice", "head", "tail"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 4, numericInput(NS(id, "n"), "N (rows)", value = 10, min = 1, step = 1)),
      column(width = 4, numericInput(NS(id, "frac"), "Fraction (0-1)",
                                     value = 0.5, min = 0.01, max = 1, step = 0.05)),
      column(width = 4,
             prettyRadioButtons(NS(id, "replace"),
                                label = "Sample with replacement",
                                choiceNames = c("Yes", "No"),
                                choiceValues = c("yes", "no"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 4, numericInput(NS(id, "row_from"), "Slice from", value = 1, min = 1, step = 1)),
      column(width = 4, numericInput(NS(id, "row_to"), "Slice to", value = 50, min = 1, step = 1)),
      column(width = 4, numericInput(NS(id, "seed"), "Random seed", value = 42, step = 1))
    )
  )
}
