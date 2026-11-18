# ---------------------------
# Description : pages with static contents
# Author : Serge Zaugg
# ---------------------------

ui_quick_guide <- function(icon, title) {
  card(
    card_header(
      div(icon, span(title), style = "display: flex; align-items: center; gap: 20px;")
    ),
    div(
      lapply(1:4, function(i) {
        div(
          ptext[[paste0("quick_guide_tx_", i)]],
          style = "margin-bottom: 5px; line-height: 1.3;"
        )
      })
    ),
    tags$hr(style = "margin-top: 2px; margin-bottom: 2px;"),
    p(ptext$quick_guide_tx_5)
  )
}


ui_about_page <- function() {
  tabPanel(
    "About",
    fluidRow(
      column(
        width = 6,
        wellPanel(
          style = "height: 660px;",
          h5("Motivation"),
          ptext$about_tx_1,
          tags$hr(style = "margin-top: 30px; margin-bottom: 25px;"),
          h5("Methods"),
          ptext$about_tx_2,
          tags$hr(style = "margin-top: 30px; margin-bottom: 25px;"),
          div(
            h5("Author"),
            tags$p(
              "Web-app concept, analytics and implementation by",
              "Serge Zaugg (",
              tags$a("LinkedIn",
                href = "https://www.linkedin.com/in/dkifh34rtn345eb5fhrthdbgf45/",
                target = "_blank"
              ),
              ", ",
              tags$a("GitHub",
                href = "https://github.com/sergezaugg",
                target = "_blank"
              ),
              ")"
            )
          )
        )
      )
    )
  )
}
