stats_logreg_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      discrete_cols <- bgc_discrete_columns(df())
      current_predictors <- input$predictor_vars
      if (is.null(current_predictors)) current_predictors <- character()

      sync_column_choices(
        session,
        df(),
        "response_var",
        selected_map = list(
          response_var = bgc_pick_column(input$response_var, discrete_cols[1])
        )
      )
      sync_multi_column_choices(
        session,
        df(),
        "predictor_vars",
        selected = intersect(current_predictors, names(df()))
      )
    }, ignoreNULL = FALSE)

    logreg_fit <- eventReactive(input$run_analysis, {
      req(nzchar(input$response_var))
      predictors <- input$predictor_vars
      validate(need(length(predictors) >= 1, "Select at least one predictor variable."))
      validate(need(!(input$response_var %in% predictors),
                    "Response variable cannot also be a predictor."))
      validate_required_columns(df(), c(input$response_var, predictors))

      data_subset <- df()[, c(input$response_var, predictors), drop = FALSE]
      data_subset <- data_subset[complete.cases(data_subset), , drop = FALSE]

      raw_response <- data_subset[[input$response_var]]
      response_factor <- factor(raw_response)
      validate(
        need(nlevels(response_factor) == 2,
             paste0("Response variable must have exactly 2 levels, got ",
                    nlevels(response_factor), "."))
      )

      positive_level <- levels(response_factor)[2]
      data_subset[[input$response_var]] <- as.integer(response_factor == positive_level)

      intercept_term <- if (identical(input$intercept, "no")) " - 1" else ""
      formula_str <- paste0(
        "`", input$response_var, "` ~ ",
        paste0("`", predictors, "`", collapse = " + "),
        intercept_term
      )
      model_formula <- as.formula(formula_str)

      validate(
        need(nrow(data_subset) > length(predictors) + 1,
             "Not enough observations after removing NAs.")
      )

      fit <- suppressWarnings(glm(model_formula, data = data_subset, family = binomial()))

      list(
        fit = fit,
        formula_str = formula_str,
        n = nrow(data_subset),
        positive_level = positive_level,
        reference_level = levels(response_factor)[1]
      )
    })

    print_fn <- function(){
      result <- logreg_fit()
      cat(sprintf("Formula: %s\n", result$formula_str))
      cat(sprintf("Positive class: %s (reference: %s)\n",
                  result$positive_level, result$reference_level))
      cat(sprintf("Observations used: %d\n\n", result$n))
      print(summary(result$fit))

      dev_null <- result$fit$null.deviance
      dev_res  <- result$fit$deviance
      if (!is.null(dev_null) && dev_null > 0) {
        mcfadden <- 1 - dev_res / dev_null
        cat(sprintf("\nMcFadden pseudo R^2: %.4f\n", mcfadden))
      }
    }

    table_fn <- function(){
      result <- logreg_fit()
      smry <- summary(result$fit)
      coefs <- as.data.frame(smry$coefficients)
      conf_ints <- tryCatch(
        suppressMessages(confint.default(result$fit, level = input$conf_level)),
        error = function(e) NULL
      )

      estimate <- coefs[, "Estimate"]
      out <- data.frame(
        Term       = rownames(coefs),
        Estimate   = estimate,
        Std.Error  = coefs[, "Std. Error"],
        z.value    = coefs[, "z value"],
        p.value    = coefs[, "Pr(>|z|)"],
        Odds.Ratio = exp(estimate),
        stringsAsFactors = FALSE,
        row.names = NULL
      )
      if (!is.null(conf_ints)) {
        out$OR.ci.lower <- exp(conf_ints[, 1])
        out$OR.ci.upper <- exp(conf_ints[, 2])
      }
      out
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "logistic_regression")
  })
}
