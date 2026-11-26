# ---------------------------
# Description : page
# Author : Serge Zaugg
# ---------------------------


ui_module_sim_param_usr_input <- function(id, icon, title = "") {
  ns <- NS(id)
  card(
    card_header(
      div(icon, span(title), style = "display: flex; align-items: center; gap: 10px;"),
      class = "d-flex justify-content-between align-items-center",
      # refresh button
      actionButton(
        inputId = ns("btn_rerun"),
        "Re-run",
        icon = icon("rotate"),
        class = "btn-primary"
      )
    ),
    layout_columns(
      col_widths = c(4, 4, 4),
      # Column 1
      div(
        sliderInput(
          inputId = ns("mu_a"),
          "Mean A", min = 0, max = 5, value = 3, step = 0.2, ticks = FALSE
        ),
        numericInput(
          inputId = ns("n_between_a"),
          "N Clusters A", 5, min = 1
        ),
        br(),
        br(),
        div(
          span("True effect"),
          textOutput(ns("true_effect"), inline = TRUE)
        )
      ),

      # Column 2
      div(
        sliderInput(
          inputId = ns("mu_b"),
          "Mean B", min = 0, max = 5, value = 3, step = 0.2, ticks = FALSE
        ),
        numericInput(
          inputId = ns("n_between_b"),
          "N Clusters B", 5, min = 1
        )
      ),
      # Column 3
      div(
        numericInput(
          inputId = ns("sd_between"),
          "SD clusters", 0.5, min = 0.1, max = 2, step = 0.1
        ),
        numericInput(
          inputId = ns("sd_within"),
          "SD residual", 0.2, min = 0.1, max = 2, step = 0.1
        ),
        numericInput(
          inputId = ns("n_within"),
          "N per cluster", 10, min = 2, max = 20
        )
      )
    )
  )
}


ui_module_lme_estimates <- function(id, icon = "", title = "") {
  ns <- NS(id)

  card(
    card_header(
      div(icon, span(title), style = "display: flex; align-items: center; gap: 10px;"),
    ),
    layout_columns(
      value_box(
        title = "Mean effect",
        value = uiOutput(outputId = ns("effect_mean")),
        height = "60px", 
        theme = "secondary",
        class = "custom-value-box"
      ),
      value_box(
        title = "SD between",
        value = uiOutput(outputId = ns("sd_between")),
        height = "60px", theme = "primary", class = "custom-value-box"
      ),
      col_widths = c(6, 6)
    ),
    layout_columns(
      value_box(
        title = "95% CI",
        value = uiOutput(outputId = ns("effect_std")),
        height = "60px", theme = "primary", class = "custom-value-box"
      ),
      value_box(
        title = "SD residuals",
        value = uiOutput(outputId = ns("sd_resid")),
        height = "60px", theme = "primary", class = "custom-value-box"
      ),
      col_widths = c(6, 6)
    ),
    layout_columns(
      value_box(
        title = "P-value effect",
        value = uiOutput(outputId = ns("effect_pval")),
        height = "60px", theme = "primary", class = "custom-value-box"
      ),
      col_widths = c(6, 6)
    )
  )
}


ui_module_show_plot_sim_data <- function(id, icon = "", title = "") {
  ns <- NS(id)
  card(
    card_header(
      div(icon, span(title), style = "display: flex; align-items: center; gap: 10px;"),
    ),
    card_body(
      plotOutput(
        outputId = ns("plot_data"),
        height = "200px"
      ),
      padding = 0
    )
  )
}


ui_module_show_forest_plot <- function(id, icon = "", title = "") {
  ns <- NS(id)
  card(
    card_header(
      div(icon, span(title), style = "display: flex; align-items: center; gap: 10px;"),
    ),
    card_body(
      plotOutput(
        outputId = ns("forest_plot"),
        height = "200px"
      ),
      padding = 0
    )
  )
}
