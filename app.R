# ---------------------------
# Description : apps main entry point
# Author : Serge Zaugg
# ---------------------------

library(shiny)
library(tidyverse)
library(bslib)
library(lme4)
source("src/utils.R")
source("src/utils_styles.R")

ui <- page_navbar(
  title = "Random Effects Playground",
  padding = c(25, 5, 50, 5),
  header = includeCSS("styles/styles.css"),
  app_custom_footer(text = "v0.0.0-β - © 2026 Serge Zaugg"),
  theme = bs_theme(version = 5, bootswatch = "cosmo"),
  # "flatly"
  # "zephyr"
  # "cosmo"
  # "litera"
  # "minty"

  # Page 1
  nav_panel(
    "Simulate",

    layout_columns(
      col_widths = c(4, 4, 4),

      card(
        card_header("Simulation parameters"),
        
        layout_columns(
          col_widths = c(4, 4, 4),
          # Column 1
          div(
            # numericInput("mu_a", "Mean A", 4),
            sliderInput("mu_a","Mean A",min = 0,max = 10,value = 4,step = 0.1),
            numericInput("n_between_a", "N Clusters A", 5, min = 1),
          ),
          # Column 2
          div(
            # numericInput("mu_b", "Mean B", 5),
            sliderInput("mu_b","Mean B",min = 0,max = 10,value = 4.5,step = 0.1),
            numericInput("n_between_b", "N Clusters B", 5, min = 1),
          ),
          # Column 3
          div(
            numericInput("sd_between", "SD clusters", 0.3, min = 0.1, max = 2, step = 0.1),
            numericInput("sd_within", "SD residual", 0.3, min = 0.1,  max = 2, step = 0.1),
            numericInput("n_within", "N per cluster", 5, min = 1)
          )
        )
      ),
      card( 
        card_header("LME estimates (accounts for clusters)"),
        layout_columns(
          value_box(title = "Mean effect", value = uiOutput("effect_mean"), height = "60px", theme = "primary", class = "center-value" ),
          value_box(title = "SD between", value = uiOutput("sd_between"), height = "60px", theme = "primary", class = "center-value"),
          col_widths = c(6, 6)
        ),
        layout_columns(
          value_box(title = "95% CI",      value = uiOutput("effect_std"),  height = "60px", theme = "primary", class = "center-value"),
          value_box(title = "SD residuals", value = uiOutput("sd_resid"), height = "60px", theme = "primary", class = "center-value"),
          col_widths = c(6, 6)
        ),
        layout_columns(
          value_box(title = "P-value effect", value = uiOutput("effect_pval"), height = "60px", theme = "primary", class = "center-value"),
          col_widths = c(6, 6)
        )
      ),
      card(
        card_header("Panel xx"),
        plotOutput("plot2")
      )
    ),
    layout_columns(
      heights = "200px",
      col_widths = c(4, 4, 4),
      card(
        card_header("Simulated data"),
        plotOutput("plot_data", height = "300px"),
      ),
      card(
        card_header("LM estimates (ignores clusters)"),
        plotOutput("plot4")
      ),
      card(
        card_header("Panel yy"),
        plotOutput("plot2")
      )
    )
  ),


  # Page 3
  nav_panel(
    "About",
    page_fluid(
      # About content
    )
  ),
  
  
  # elements right of navbar
  nav_spacer(),
  nav_item(app_custom_theme_title("Theme")),
  nav_item(input_dark_mode(id = "dark_mode")), 

  
)


server <- function(input, output, session) {
  #----------------------
  # Generate data and fit models
  #----------------------

  dat <- reactive({
    par <- list(
      mu_a = input$mu_a,
      mu_b = input$mu_b,
      n_be_a = input$n_between_a,
      n_be_b = input$n_between_b,
      n_wi = input$n_within,
      sd_be = input$sd_between,
      sd_wi = input$sd_within
    )

    generate_hierarchical_data(par)
  })


  lme_obj <- reactive({
    fit_random_effects_model(df = dat())
  })

  plot_resu <- reactive({
    plot_hierarchical_data(dat = dat(), dark_mode = identical(input$dark_mode, "dark"))
  })

  
  
  
  
  
  
  lme_summa <- reactive({
    list(
      sd_between   = lme_obj()$df_random |> filter(groups == "cluster") |> pull("std_dev"),
      sd_resid     = lme_obj()$df_random |> filter(groups == "Residual") |> pull("std_dev"),
      effect_mean  = lme_obj()$df_fixed |> filter(Term == "groupB") |> pull("Estimate"),
      effect_std   = lme_obj()$df_fixed |> filter(Term == "groupB") |> pull("Std. Error"),
      effect_ci_lo = lme_obj()$df_fixed |> filter(Term == "groupB") |> pull("ci_lower"),
      effect_ci_up = lme_obj()$df_fixed |> filter(Term == "groupB") |> pull("ci_upper"),
      effect_pval  = lme_obj()$p_value
    )
  })


  output$sd_between <- renderUI({
    tags$span(
      sprintf("%.2f", lme_summa()$sd_between),
    )
  })

  output$sd_resid <- renderUI({
    tags$span(
      sprintf("%.2f", lme_summa()$sd_resid),
    )
  })

  output$effect_mean <- renderUI({
    tags$span(
      sprintf("%.2f", lme_summa()$effect_mean),
    )
  })

  output$effect_std <- renderUI({
    tags$span(
      sprintf("(%.2f to %.2f)",
        lme_summa()$effect_ci_lo,
        lme_summa()$effect_ci_up),
    )
  })
  
  output$effect_pval <- renderUI({
    tags$span(
      sprintf("%.2f", lme_summa()$effect_pval),
    )
  })

  #----------------------
  # Display results
  #----------------------

  output$plot_data <- renderPlot({
    plot_resu()
  })
}


# Run the application
shinyApp(ui = ui, server = server)
