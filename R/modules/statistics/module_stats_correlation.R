stats_correlation_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      current <- input$numeric_columns
      if (is.null(current)) current <- character()

      sync_multi_column_choices(
        session,
        df(),
        "numeric_columns",
        selected = intersect(current, numeric_cols)
      )

      if (length(current) == 0 && length(numeric_cols) >= 2) {
        updateSelectizeInput(
          session = session,
          inputId = "numeric_columns",
          choices = names(df()),
          selected = numeric_cols,
          server = TRUE
        )
      }
    }, ignoreNULL = FALSE)

    pairs_result <- eventReactive(input$run_analysis, {
      cols <- input$numeric_columns
      validate(need(length(cols) >= 2, "Select at least two numeric columns."))
      validate_required_columns(df(), cols)
      validate_numeric_columns(df(), cols)

      data_subset <- df()[, cols, drop = FALSE]
      combos <- utils::combn(cols, 2, simplify = FALSE)
      rows <- lapply(combos, function(pair) {
        x <- data_subset[[pair[1]]]
        y <- data_subset[[pair[2]]]
        ct <- suppressWarnings(cor.test(x, y, method = input$cor_method))
        data.frame(
          Var1 = pair[1],
          Var2 = pair[2],
          r = unname(ct$estimate),
          p.value = ct$p.value,
          n = sum(complete.cases(x, y)),
          stringsAsFactors = FALSE
        )
      })
      tab <- do.call(rbind, rows)
      if (!identical(input$adjust_method, "none")) {
        tab$p.adj <- p.adjust(tab$p.value, method = input$adjust_method)
      }
      attr(tab, "data") <- data_subset
      tab
    })

    print_fn <- function(){
      tab <- pairs_result()
      cat(sprintf("Correlation method: %s\n", input$cor_method))
      cat(sprintf("Pairs computed: %d\n", nrow(tab)))
      if ("p.adj" %in% names(tab)) {
        cat(sprintf("p-value adjust method: %s\n", input$adjust_method))
      }
      cat("\n")
      print(tab, row.names = FALSE)
    }

    table_fn <- function(){
      pairs_result()
    }

    plot_fn <- function(){
      tab <- pairs_result()
      data_subset <- attr(tab, "data")
      if (is.null(data_subset)) {
        plot.new(); title(main = "No data available.")
        return(invisible(NULL))
      }
      cols <- names(data_subset)
      if (length(cols) == 2) {
        op <- par(mar = c(4.5, 4.5, 3, 1))
        on.exit(par(op), add = TRUE)
        x <- data_subset[[cols[1]]]
        y <- data_subset[[cols[2]]]
        plot(
          x, y,
          pch = 19, col = "#1f3b5b",
          xlab = cols[1], ylab = cols[2],
          main = sprintf(
            "%s vs %s (r = %.3f, p = %.4g)",
            cols[1], cols[2], tab$r[1], tab$p.value[1]
          )
        )
        keep <- complete.cases(x, y)
        if (sum(keep) >= 2) {
          abline(lm(y[keep] ~ x[keep]), col = "#d62828", lwd = 2)
        }
      } else {
        panel_cor <- function(x, y, ...) {
          usr <- par("usr"); on.exit(par(usr = usr), add = TRUE)
          par(usr = c(0, 1, 0, 1))
          r <- suppressWarnings(cor(x, y, use = "pairwise.complete.obs",
                                    method = input$cor_method))
          txt <- sprintf("%.2f", r)
          text(0.5, 0.5, txt, cex = 1.2 + abs(r))
        }
        panel_pts <- function(x, y, ...) {
          points(x, y, pch = 19, col = "#1f3b5b", cex = 0.6)
        }
        pairs(
          data_subset,
          lower.panel = panel_pts,
          upper.panel = panel_cor,
          main = paste0("Correlation (", input$cor_method, ")")
        )
      }
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "correlation", plot_fn)
  })
}
