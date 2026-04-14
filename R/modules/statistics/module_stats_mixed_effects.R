stats_mixed_effects_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())

      sync_column_choices(
        session, df(),
        c("response_var","random_var"),
        selected_map = list(
          response_var = bgc_pick_column(input$response_var, numeric_cols[1]),
          random_var   = bgc_pick_column(input$random_var, discrete_cols[1])
        )
      )

      current_fixed <- input$fixed_vars
      if (is.null(current_fixed)) current_fixed <- character()
      sync_multi_column_choices(
        session, df(), "fixed_vars",
        selected = if (length(current_fixed) > 0) intersect(current_fixed, names(df())) else numeric_cols[2]
      )
    }, ignoreNULL = FALSE)

    fit <- eventReactive(input$run_analysis, {
      req(nzchar(input$response_var), nzchar(input$random_var))
      validate(need(length(input$fixed_vars) >= 1, "Pick at least one fixed effect."))
      validate_required_columns(df(), c(input$response_var, input$fixed_vars, input$random_var))
      validate_numeric_columns(df(), input$response_var)

      fixed_part <- paste(input$fixed_vars, collapse = " + ")
      random_part <- if (identical(input$include_intercept, "slope")) {
        sprintf("(%s | %s)", input$fixed_vars[1], input$random_var)
      } else {
        sprintf("(1 | %s)", input$random_var)
      }
      formula_str <- sprintf("%s ~ %s + %s", input$response_var, fixed_part, random_part)
      form <- stats::as.formula(formula_str)

      model <- tryCatch(
        lme4::lmer(form, data = df(), REML = identical(input$reml, "yes")),
        error = function(e) {
          validate(need(FALSE, paste("lmer failed:", conditionMessage(e))))
        }
      )

      list(model = model, formula = formula_str)
    })

    print_fn <- function(){
      f <- fit()
      cat("Formula:", f$formula, "\n\n")
      print(summary(f$model))
    }

    table_fn <- function(){
      f <- fit()
      coefs <- as.data.frame(summary(f$model)$coefficients)
      coefs$Term <- rownames(coefs)
      rownames(coefs) <- NULL
      coefs <- coefs[, c("Term", setdiff(names(coefs), "Term")), drop = FALSE]
      coefs
    }

    plot_fn <- function(){
      f <- fit()
      coefs <- summary(f$model)$coefficients
      terms <- rownames(coefs)
      est <- coefs[, "Estimate"]
      se <- coefs[, "Std. Error"]

      op <- par(mar = c(4.5, 9, 3, 1))
      on.exit(par(op), add = TRUE)
      ord <- order(est)
      plot(est[ord], seq_along(est),
           xlim = range(est - 2 * se, est + 2 * se),
           pch = 19, col = "#1f3b5b",
           yaxt = "n", ylab = "", xlab = "Estimate (±2 SE)",
           main = "Mixed-effects coefficients")
      axis(2, at = seq_along(est), labels = terms[ord], las = 1)
      arrows(est[ord] - 2 * se[ord], seq_along(est),
             est[ord] + 2 * se[ord], seq_along(est),
             code = 3, angle = 90, length = 0.05, col = "#1f3b5b")
      abline(v = 0, lty = 2, col = "#888")
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "mixed_effects", plot_fn)
  })
}
