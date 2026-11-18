# ---------------------------
# Description : style-related elements and functions
# Author : Serge Zaugg
# ---------------------------

app_custom_footer <- function(text) {
  tags$div(
    text,
    class = "app-footer"
  )
}

app_custom_title <- function(text) {
  tags$span(
    style = "display: inline-flex; align-items: center; gap: 10px;",
    tags$img(src = "contents/z_logo_blue.png", height = "30px"),
    tags$span(text)
  )
}

app_custom_theme_title <- function(text) {
  tags$span(
    style = "display: inline-flex; align-items: center; gap: 10px;",
    tags$span(text)
  )
}
