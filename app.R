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
source("src/ui_static_pages.R")
source("contents/text_for_pages.R")

ui <- page_navbar(
  title = "Random Effects Playground",
  padding = c(25, 5, 50, 5),
  header = includeCSS("styles/styles.css"),
  app_custom_footer(text = "v0.9.3-β - © 2026 Serge Zaugg"),
  theme = bs_theme(version = 5, bootswatch = "sandstone", bg = "#F5F1E9", fg = "#000000"),

  # Page 1
  nav_panel(
    "Simulate",
    layout_columns(
      col_widths = c(4, 4, 4),
      ui_module_sim_param_usr_input(id = "pg01", icon = "❶", title = "Simulation parameters"),
      ui_module_lme_estimates(id = "pg01a", icon = "❷", title = "LME estimates (accounts for clusters)"),
      ui_module_lme_estimates(id = "pg01b", icon = "❸", title = "SLM estimates (! wrong because ignores clusters !)"),
    ),
    layout_columns(
      col_widths = c(4, 4, 4),
      ui_quick_guide(icon = "❹", title = "Quick guide"),
      ui_module_show_plot_sim_data(id = "drk", icon = "❺", title = "Simulated data"),
      ui_module_show_forest_plot(id = "drk", icon = "❻", title = "Compare CIs to H0: effect = 0"),
    )
  ),
  # Page 2
  nav_panel(
    "About",
    ui_about_page()
  ),
  # elements right of navbar
  nav_spacer(),
  nav_item(app_custom_theme_title("Theme")),
  nav_item(input_dark_mode(id = NS("drk")("dark_mode")))
)


server <- function(input, output, session) {
  true_effect <- server_module_get_true_effect(id = "pg01")
  dat <- server_module_gen_data(id = "pg01")
  server_module_render_sim_data_plot(id = "drk", df = dat)
  # fit lme model
  lme_obj <- server_module_fit_re_mod(df = dat) # not using input or output
  server_module_prepare_lme_outputs(id = "pg01a", lme_obj = lme_obj)
  # fit simple lm
  slm_obj <- server_module_fit_lm_mod(df = dat) # not using input or output
  server_module_prepare_lme_outputs(id = "pg01b", lme_obj = slm_obj)
  # make_forest_plot
  true_effect_num <- server_module_get_true_effect_num(id = "pg01")
  server_module_make_forest_plot(id = "drk", lm_obj = slm_obj, lme_obj = lme_obj)
}


# Run the application
shinyApp(ui = ui, server = server)
