stats_pairwise_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())
      sync_column_choices(
        session, df(),
        c("group_var","value_var"),
        selected_map = list(
          group_var = bgc_pick_column(input$group_var, discrete_cols[1]),
          value_var = bgc_pick_column(input$value_var, numeric_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    fit <- eventReactive(input$run_analysis, {
      req(nzchar(input$group_var), nzchar(input$value_var))
      validate_required_columns(df(), c(input$group_var, input$value_var))
      validate_numeric_columns(df(), input$value_var)

      g <- as.factor(df()[[input$group_var]])
      x <- as.numeric(df()[[input$value_var]])
      keep <- !is.na(g) & !is.na(x)
      g <- droplevels(g[keep])
      x <- x[keep]

      validate(need(length(levels(g)) >= 2, "Need at least 2 groups."))

      result <- if (identical(input$test_kind, "t")) {
        suppressWarnings(stats::pairwise.t.test(
          x, g,
          p.adjust.method = input$p_adjust,
          pool.sd = identical(input$pool_sd, "yes")
        ))
      } else {
        suppressWarnings(stats::pairwise.wilcox.test(
          x, g,
          p.adjust.method = input$p_adjust
        ))
      }

      list(
        result = result,
        groups = levels(g),
        x = x, g = g
      )
    })

    pmatrix <- reactive({
      r <- fit()$result
      mat <- r$p.value
      full <- matrix(NA_real_,
                     nrow = length(fit()$groups),
                     ncol = length(fit()$groups),
                     dimnames = list(fit()$groups, fit()$groups))
      for (i in rownames(mat)) {
        for (j in colnames(mat)) {
          if (!is.na(mat[i, j])) {
            full[i, j] <- mat[i, j]
            full[j, i] <- mat[i, j]
          }
        }
      }
      diag(full) <- 1
      full
    })

    print_fn <- function(){
      r <- fit()$result
      cat("Pairwise comparison\n")
      cat("  Test:", r$method, "\n")
      cat("  Adjustment:", r$p.adjust.method, "\n\n")
      print(r)
    }

    table_fn <- function(){
      mat <- pmatrix()
      pairs <- combn(rownames(mat), 2, simplify = FALSE)
      do.call(rbind, lapply(pairs, function(pr) {
        data.frame(
          group1 = pr[1],
          group2 = pr[2],
          p.value = mat[pr[1], pr[2]],
          significant = mat[pr[1], pr[2]] < 0.05,
          stringsAsFactors = FALSE
        )
      }))
    }

    plot_fn <- function(){
      mat <- pmatrix()
      n <- nrow(mat)
      logp <- -log10(pmax(mat, 1e-16))

      op <- par(mar = c(5, 5, 3, 2))
      on.exit(par(op), add = TRUE)
      image(1:n, 1:n, logp,
            axes = FALSE, xlab = "", ylab = "",
            col = grDevices::hcl.colors(20, "YlOrRd", rev = TRUE),
            main = "Pairwise -log10(p) matrix")
      axis(1, at = 1:n, labels = rownames(mat), las = 2)
      axis(2, at = 1:n, labels = rownames(mat), las = 2)
      for (i in 1:n) {
        for (j in 1:n) {
          if (!is.na(mat[i, j])) {
            text(i, j, sprintf("%.3g", mat[i, j]), cex = 0.7,
                 col = if (logp[i, j] > max(logp, na.rm = TRUE) / 2) "white" else "black")
          }
        }
      }
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "pairwise_comparison", plot_fn)
  })
}
