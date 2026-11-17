# ---------------------------
# Description : server modules 
# Author : Serge Zaugg
# ---------------------------


server_module_gen_data <- function(id) {
  moduleServer(id, function(input, output, session) {
    reactive({
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
  })
}


server_module_render_sim_data_plot <- function(id, df) {
  moduleServer(id, function(input, output, session) {
    plot_resu <- reactive({
      plot_hierarchical_data(dat = df(), dark_mode = identical(input$dark_mode, "dark"))
    })
    output$plot_data <- renderPlot({
      plot_resu()
    })
  })  
}


server_module_fit_re_mod <- function(df) {
  reactive({ fit_random_effects_model(df = df()) })
}


server_module_fit_lm_mod <- function(df) {
  reactive({ fit_simple_linear_model(df = df()) })
}



server_module_prepare_lme_outputs <- function(id, lme_obj) {
  moduleServer(id, function(input, output, session) {
  
    lme_summa <- reactive({
      
      obj <- lme_obj()
      
      list(
        sd_between   = obj$df_random |> filter(groups == "cluster") |> pull("std_dev"),
        sd_resid     = obj$df_random |> filter(groups == "Residual") |> pull("std_dev"),
        effect_mean  = obj$df_fixed |> filter(Term == "groupB") |> pull("Estimate"),
        effect_std   = obj$df_fixed |> filter(Term == "groupB") |> pull("Std. Error"),
        effect_ci_lo = obj$df_fixed |> filter(Term == "groupB") |> pull("ci_lower"),
        effect_ci_up = obj$df_fixed |> filter(Term == "groupB") |> pull("ci_upper"),
        effect_pval  = obj$p_value
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
  })
}



