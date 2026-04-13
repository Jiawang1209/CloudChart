data_tools_parameters_select_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 12, bgc_multi_column_select(id, "keep_columns", "Columns to keep (in order)"))
    ),
    fluidRow(
      align = "center",
      column(
        width = 12,
        textAreaInput(
          inputId = NS(id, "rename_pairs"),
          label = "Rename (one old=new per line, optional)",
          value = "",
          rows = 4,
          placeholder = "Sepal.Length=length\nSpecies=group"
        )
      )
    )
  )
}
