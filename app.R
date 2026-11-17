# ---------------------------
# Description : apps main entry point
# Author : Serge Zaugg
# "flatly" "zephyr" "cosmo" "litera" "minty" "sandstone"
# ---------------------------

library(shiny)
library(tidyverse)
library(bslib)
library(lme4)
source("src/utils.R")
source("src/utils_styles.R")
source("src/ui_modules.R")
source("src/server_modules.R")

ui <- page_navbar(
  title = "Random Effects Playground",
  padding = c(25, 5, 50, 5),
  header = includeCSS("styles/styles.css"),
  app_custom_footer(text = "v0.9.0-β - © 2026 Serge Zaugg"),
  theme = bs_theme(version = 5, bootswatch = "sandstone",  bg = "#F5F1E9", fg = "#000000"),
 
  # Page 1
  nav_panel(
    "Simulate",
    layout_columns(
      col_widths = c(4, 4, 4),
      ui_module_sim_param_usr_input(id = "pg01", title = "Simulation parameters"),
      ui_module_lme_estimates(id = "pg01", title = "LME estimates (accounts for clusters)"),
      card(card_header("Panel xx"),plotOutput("plot2"))
    ),
    layout_columns(
      col_widths = c(4, 4, 4),
      ui_module_show_plot_sim_data(id = "drk", title = "Simulated data"),
      card(card_header("LM estimates (ignores clusters)"),plotOutput("plot4")),
      card(card_header("Panel yy"),plotOutput("plot2")
      )
    )
  ),

  # Page 2
  nav_panel(
    "About",
    page_fluid( )
  ),
  
  # elements right of navbar
  nav_spacer(),
  nav_item(app_custom_theme_title("Theme")),
  nav_item(input_dark_mode(id = NS("drk")("dark_mode")))
  # nav_item(input_dark_mode(id = "dark_mode")),
  
  
)


server <- function(input, output, session) {
  dat <- server_module_gen_data(id = "pg01")
  server_module_render_sim_data_plot(id = "drk", df = dat)
  lme_obj <- server_module_fit_re_mod(df = dat) # not using input or output
  server_module_prepare_lme_outputs(id = "pg01", lme_obj = lme_obj)

}


# Run the application
shinyApp(ui = ui, server = server)
