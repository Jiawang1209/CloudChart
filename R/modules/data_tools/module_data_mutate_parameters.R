data_tools_parameters_mutate_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 4, bgc_column_select(id, "source_column", "Source column")),
      column(
        width = 4,
        selectInput(
          NS(id, "operation"),
          "Operation",
          choices = list(
            "Type cast" = c(
              "as.numeric"   = "as_numeric",
              "as.character" = "as_character",
              "as.factor"    = "as_factor",
              "as.logical"   = "as_logical",
              "as.integer"   = "as_integer"
            ),
            "Numeric transform" = c(
              "log"    = "log",
              "log2"   = "log2",
              "log10"  = "log10",
              "sqrt"   = "sqrt",
              "exp"    = "exp",
              "abs"    = "abs",
              "round"  = "round",
              "rank"   = "rank",
              "scale (z-score)" = "scale"
            ),
            "String transform" = c(
              "toupper" = "toupper",
              "tolower" = "tolower",
              "trimws"  = "trimws"
            )
          ),
          selected = "as_numeric"
        )
      ),
      column(
        width = 4,
        textInput(
          NS(id, "new_column"),
          "New column name (leave blank to replace source)",
          value = ""
        )
      )
    ),
    fluidRow(
      align = "center",
      column(
        width = 6,
        prettyRadioButtons(
          NS(id, "on_error"),
          label = "On Error",
          choiceNames  = c("Produce NA", "Stop with message"),
          choiceValues = c("na", "stop"),
          icon = icon("check"),
          animation = "tada",
          inline = TRUE
        )
      )
    )
  )
}
