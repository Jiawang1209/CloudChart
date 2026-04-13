stats_wilcox_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())

      sync_column_choices(
        session,
        df(),
        c("group_var", "value_var"),
        selected_map = list(
          group_var = bgc_pick_column(input$group_var, discrete_cols[1]),
          value_var = bgc_pick_column(input$value_var, numeric_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    wilcox_fit <- eventReactive(input$run_analysis, {
      req(nzchar(input$group_var), nzchar(input$value_var))
      validate_required_columns(df(), c(input$group_var, input$value_var))
      validate_numeric_columns(df(), input$value_var)

      group_values <- df()[[input$group_var]]
      value_values <- df()[[input$value_var]]

      keep <- !is.na(group_values) & !is.na(value_values)
      group_values <- group_values[keep]
      value_values <- value_values[keep]

      groups <- unique(group_values)
      validate(
        need(
          length(groups) == 2,
          paste0("Wilcoxon test requires exactly 2 groups, got ", length(groups), ".")
        )
      )

      x <- value_values[group_values == groups[1]]
      y <- value_values[group_values == groups[2]]
      paired <- identical(input$paired, "yes")

      if (paired) {
        validate(
          need(length(x) == length(y),
               "Paired Wilcoxon test requires equal-length groups.")
        )
      }

      result <- suppressWarnings(wilcox.test(
        x, y,
        alternative = input$alternative,
        paired = paired,
        conf.int = TRUE,
        conf.level = input$conf_level
      ))
      list(
        result = result,
        group_labels = as.character(groups),
        n1 = length(x),
        n2 = length(y),
        paired = paired
      )
    })

    print_fn <- function(){
      fit <- wilcox_fit()
      cat(sprintf(
        "Groups: %s (n=%d) vs %s (n=%d)%s\n\n",
        fit$group_labels[1], fit$n1,
        fit$group_labels[2], fit$n2,
        if (fit$paired) " [paired]" else ""
      ))
      print(fit$result)
    }

    table_fn <- function(){
      fit <- wilcox_fit()
      r <- fit$result
      ci_lower <- if (!is.null(r$conf.int)) r$conf.int[1] else NA_real_
      ci_upper <- if (!is.null(r$conf.int)) r$conf.int[2] else NA_real_
      estimate <- if (!is.null(r$estimate)) unname(r$estimate) else NA_real_

      data.frame(
        Statistic = c("W", "p.value", "estimate", "ci.lower", "ci.upper"),
        Value = c(
          unname(r$statistic),
          r$p.value,
          estimate,
          ci_lower,
          ci_upper
        ),
        stringsAsFactors = FALSE
      )
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "wilcoxon")
  })
}
