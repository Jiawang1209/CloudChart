# Legacy upload prototype.
# Active upload module: R/module_file_upload.R

load_file <- function(name, path){
  ext <- tools::file_ext(name)
  switch (ext,
    csv = vroom::vroom(path, delim = ","),
    tsv = vroom::vroom(path, delim = "\t"),
    excel = readxl::read_xlsx(path, sheet = 1),
    validate("Invalid file; Please upload a .csv or .tsv or .xlsx file")
  )
}


file_upload <- function(){
  tabItem(
    tabName = "usage_guide",
    fluidRow(
      column(
        width = 12,
        align = "center",
        h2("test input file module"),
        file_upload_UI("test_input"),
        file_upload_show_UI("test_input")
      ),
      tags$hr()
    )
  )
}

