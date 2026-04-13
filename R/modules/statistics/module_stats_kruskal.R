stats_kruskal_Server <- function(id){
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

    kruskal_fit <- eventReactive(input$run_analysis, {
      req(nzchar(input$group_var), nzchar(input$value_var))
      validate_required_columns(df(), c(input$group_var, input$value_var))
      validate_numeric_columns(df(), input$value_var)

      data_subset <- data.frame(
        value = df()[[input$value_var]],
        group = factor(df()[[input$group_var]])
      )
      data_subset <- data_subset[complete.cases(data_subset), , drop = FALSE]

      validate(
        need(nlevels(droplevels(data_subset$group)) >= 2,
             "Kruskal-Wallis requires at least 2 groups."),
        need(nrow(data_subset) >= 3,
             "Not enough observations after removing NAs.")
      )

      result <- kruskal.test(value ~ group, data = data_subset)
      pairwise <- if (identical(input$post_hoc, "pairwise")) {
        suppressWarnings(pairwise.wilcox.test(
          data_subset$value,
          data_subset$group,
          p.adjust.method = "BH"
        ))
      } else NULL

      list(result = result, pairwise = pairwise, data = data_subset)
    })

    print_fn <- function(){
      fit <- kruskal_fit()
      cat("=== Kruskal-Wallis Rank Sum Test ===\n")
      print(fit$result)
      if (!is.null(fit$pairwise)) {
        cat("\n=== Pairwise Wilcoxon (BH-adjusted) ===\n")
        print(fit$pairwise)
      }
    }

    table_fn <- function(){
      fit <- kruskal_fit()
      if (!is.null(fit$pairwise)) {
        pv <- fit$pairwise$p.value
        rows <- list()
        for (r in rownames(pv)) {
          for (c in colnames(pv)) {
            if (!is.na(pv[r, c])) {
              rows[[length(rows) + 1]] <- data.frame(
                Comparison = paste0(r, " vs ", c),
                p.adj = pv[r, c],
                stringsAsFactors = FALSE
              )
            }
          }
        }
        do.call(rbind, rows)
      } else {
        r <- fit$result
        data.frame(
          Statistic = c("chi-squared", "df", "p.value"),
          Value = c(
            unname(r$statistic),
            unname(r$parameter),
            r$p.value
          ),
          stringsAsFactors = FALSE
        )
      }
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "kruskal_wallis")
  })
}
