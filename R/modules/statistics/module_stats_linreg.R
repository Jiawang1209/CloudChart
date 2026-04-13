stats_linreg_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      current_predictors <- input$predictor_vars
      if (is.null(current_predictors)) current_predictors <- character()

      sync_column_choices(
        session,
        df(),
        "response_var",
        selected_map = list(
          response_var = bgc_pick_column(input$response_var, numeric_cols[1])
        )
      )

      sync_multi_column_choices(
        session,
        df(),
        "predictor_vars",
        selected = intersect(current_predictors, numeric_cols)
      )

      if (length(current_predictors) == 0 && length(numeric_cols) >= 2) {
        default_predictors <- setdiff(numeric_cols, input$response_var)
        if (length(default_predictors) > 0) {
          updateSelectizeInput(
            session = session,
            inputId = "predictor_vars",
            choices = names(df()),
            selected = default_predictors[1],
            server = TRUE
          )
        }
      }
    }, ignoreNULL = FALSE)

    lm_fit <- eventReactive(input$run_analysis, {
      req(nzchar(input$response_var))
      predictors <- input$predictor_vars
      validate(need(length(predictors) >= 1, "Select at least one predictor variable."))
      validate_required_columns(df(), c(input$response_var, predictors))
      validate_numeric_columns(df(), c(input$response_var, predictors))

      intercept_term <- if (identical(input$intercept, "no")) " - 1" else ""
      formula_str <- paste0(
        "`", input$response_var, "` ~ ",
        paste0("`", predictors, "`", collapse = " + "),
        intercept_term
      )
      model_formula <- as.formula(formula_str)

      data_subset <- df()[, c(input$response_var, predictors), drop = FALSE]
      data_subset <- data_subset[complete.cases(data_subset), , drop = FALSE]

      validate(
        need(nrow(data_subset) > length(predictors) + 1,
             "Not enough observations after removing NAs.")
      )

      list(
        fit = lm(model_formula, data = data_subset),
        formula_str = formula_str,
        n = nrow(data_subset)
      )
    })

    print_fn <- function(){
      result <- lm_fit()
      cat(sprintf("Formula: %s\n", result$formula_str))
      cat(sprintf("Observations used: %d\n\n", result$n))
      print(summary(result$fit))
    }

    table_fn <- function(){
      result <- lm_fit()
      smry <- summary(result$fit)
      coefs <- as.data.frame(smry$coefficients)
      conf_ints <- tryCatch(
        confint(result$fit, level = input$conf_level),
        error = function(e) NULL
      )

      out <- data.frame(
        Term = rownames(coefs),
        Estimate = coefs[, "Estimate"],
        Std.Error = coefs[, "Std. Error"],
        t.value = coefs[, "t value"],
        p.value = coefs[, "Pr(>|t|)"],
        stringsAsFactors = FALSE,
        row.names = NULL
      )
      if (!is.null(conf_ints)) {
        out$ci.lower <- conf_ints[, 1]
        out$ci.upper <- conf_ints[, 2]
      }
      out
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "linear_regression")
  })
}
