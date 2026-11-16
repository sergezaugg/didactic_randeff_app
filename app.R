# ---------------------------
# Description : apps main entry point
# Author : Serge Zaugg
# ---------------------------

library(shiny)
library(tidyverse)
library(bslib)
library(lme4)
source("src/utils.R")

ui <- page_navbar(
  
  title = "Random Effects Playground",
  
  # CSS
  header = includeCSS("styles/styles.css"),
  
  # Page 1
  nav_panel(
    "Simulate",

  # get CSS styles 
  includeCSS("styles/styles.css"),
  
  layout_columns(
    col_widths = c(4, 3, 5),
    
    card(
      card_header("Simulation parameters"),
      layout_columns(
        col_widths = c(6, 6),
        # Column 1
        div(
          numericInput("mu_a", "Mean group A", 4),
          numericInput("mu_b", "Mean group B", 5),
          numericInput("sd_between", "Between-cluster SD", 0.1, min = 0),
          numericInput("sd_within", "Within-cluster SD", 0.5, min = 0)
        ),
        # Column 2
        div(
          numericInput("n_between_a", "Clusters A", 10, min = 1),
          numericInput("n_between_b", "Clusters B", 7, min = 1),
          numericInput("n_within", "Observations per cluster", 5, min = 1)
        )
      )
      
    ),
    
    
  
    card(
      card_header("LME estimates"),
      layout_columns(
        value_box(title = "Mean effect",value = textOutput("effect_mean"),height = "70px"),
        value_box(title = "SE effect",value = textOutput("effect_std"),height = "70px"),
        col_widths = c(6, 6)
      ),
      
      layout_columns(
        value_box(title = "SD between",value = textOutput("sd_between"),height = "70px"),
        value_box(title = "SD residuals",value = textOutput("sd_resid"),height = "70px"),
        col_widths = c(6, 6)
      ),
      
      layout_columns(
        value_box(title = "P-value effect",value = textOutput("effect_pval"),height = "70px"),
        col_widths = c(6, 6)
      )
      
      
      
    ),
    
    card(
      card_header("Panel 2"),
      plotOutput("plot2")
    )
    
    
  ),
  
  layout_columns(
    col_widths = c(4, 3, 5),
    
    card(
      card_header("Simulated data"),
      
      
      plotOutput("plot_data", height = "300px"),
      
      
    ),
    
    card(
      card_header("Panel 4"),
      plotOutput("plot4")
    ),
    
    card(
      card_header("Panel 2"),
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
)


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
    plot_hierarchical_data(dat = dat())
  })
  
  
  lme_summa <- reactive({
    list(
    sd_between   = lme_obj()$df_random |> filter(groups == 'cluster') |> pull('std_dev'),
    sd_resid     = lme_obj()$df_random |> filter(groups == 'Residual') |> pull('std_dev'),
    effect_mean  = lme_obj()$df_fixed |> filter(Term == 'groupB') |> pull('Estimate'),
    effect_std   = lme_obj()$df_fixed |> filter(Term == 'groupB') |> pull('Std. Error'),
    effect_ci_lo = lme_obj()$df_fixed |> filter(Term == 'groupB') |> pull('ci_lower'),
    effect_ci_up = lme_obj()$df_fixed |> filter(Term == 'groupB') |> pull('ci_upper'),
    effect_pval  = lme_obj()$p_value
  )
  })
  
  
  output$sd_between <- renderText({
    round(lme_summa()$sd_between, 2)
  })
  
  output$sd_resid <- renderText({
    round(lme_summa()$sd_resid, 2)
  })
  
  output$effect_mean <- renderText({
    round(lme_summa()$effect_mean, 2)
  })
  
  output$effect_std <- renderText({
    round(lme_summa()$effect_std, 2)
  })
  
  output$effect_pval <- renderText({
    round(lme_summa()$effect_pval, 2)
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
