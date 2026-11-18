# ---------------------------
# Description : re-usable functions
# Author : Serge Zaugg
# ---------------------------

generate_hierarchical_data <- function(par) {
  n <- (par$n_be_a + par$n_be_b) * par$n_wi
  n_clu <- (par$n_be_a + par$n_be_b)
  # group indicator
  group <- c(rep(c("A"), each = par$n_be_a * par$n_wi), rep(c("B"), each = par$n_be_b * par$n_wi))
  # per-group mean
  mu <- c(rep(par$mu_a, each = par$n_be_a * par$n_wi), rep(par$mu_b, each = par$n_be_b * par$n_wi))
  # cluster/patient id
  cluster <- rep(rep(seq_len(n_clu), each = par$n_wi), times = 1)
  # per-cluser 'random' mean
  error_between <- rep(rnorm(n_clu, 0, par$sd_be), each = par$n_wi)
  # measurement error
  error_within <- rnorm(n, 0, par$sd_wi)
  # put together
  data.frame(
    group,
    cluster,
    mu,
    error_between,
    error_within,
    y = mu + error_between + error_within
  )
}


fit_random_effects_model <- function(df) {
  mod <- lmer(y ~ group + (1 | cluster), data = df)
  mod_null <- lmer(y ~ 1 + (1 | cluster), data = df)

  ci <- confint(mod, parm = "beta_", method = "profile")

  df_random <- as.data.frame(VarCorr(mod)) |>
    select(groups = grp, std_dev = sdcor)

  df_fixed <- as.data.frame(coef(summary(mod))) |>
    rownames_to_column("Term") |>
    mutate(
      ci_lower = ci[Term, 1],
      ci_upper = ci[Term, 2]
    )

  df_lrt <- as.data.frame(anova(mod_null, mod))
  p_value <- df_lrt$`Pr(>Chisq)`[2]

  list(
    mod = mod,
    df_random = df_random,
    df_fixed = df_fixed,
    p_value = p_value,
    singular = isSingular(mod)
  )
}


fit_simple_linear_model <- function(df) {
  mod <- lm(y ~ group, data = df)

  ci <- confint(mod, method = "profile")

  df_random <- data.frame(
    groups = c("cluster", "Residual"),
    std_dev = c(NA, sigma(mod))
  )

  df_fixed <- as.data.frame(coef(summary(mod))) |>
    rownames_to_column("Term") |>
    mutate(
      ci_lower = ci[Term, 1],
      ci_upper = ci[Term, 2]
    )

  p_value <- df_fixed[2, "Pr(>|t|)"]

  list(
    mod = mod,
    df_random = df_random,
    df_fixed = df_fixed,
    p_value = p_value,
    singular = NA
  )
}


plot_hierarchical_data <- function(dat, dark_mode = FALSE) {
  dat <- dat |>
    dplyr::group_by(group) |>
    dplyr::mutate(x_pos = as.numeric(factor(cluster))) |>
    dplyr::ungroup()

  bg <- if (dark_mode) "#222222" else "white"
  fg <- if (dark_mode) "#E0E0E0" else "#222222"
  border <- if (dark_mode) "#777777" else "black"
  point_col <- if (dark_mode) "#E0E0E0" else "#404040"
  clust_col <- if (dark_mode) "cyan" else "blue"

  ggplot(dat, aes(x = factor(cluster), y = y)) +
    geom_jitter(width = 0.1, height = 0, colour = point_col) +
    geom_hline(
      aes(yintercept = mu),
      colour = "red",
      linewidth = 0.8,
      linetype = "dashed"
    ) +
    geom_segment(
      aes(
        x = x_pos - 0.2,
        xend = x_pos + 0.2,
        y = mu + error_between,
        yend = mu + error_between
      ),
      colour = clust_col,
      linewidth = 1
    ) +
    facet_wrap(~group, scales = "free_x") +
    labs(x = "Cluster", y = "Outcome", title = "") +
    theme_classic() +
    theme(
      text = element_text(colour = fg),
      axis.text = element_text(colour = fg),
      axis.title = element_text(colour = fg),
      strip.text = element_text(colour = fg),
      panel.background = element_rect(fill = bg),
      plot.background = element_rect(fill = bg),
      panel.border = element_rect(
        colour = border,
        fill = NA,
        linewidth = 0.8
      ),
      axis.line = element_line(colour = fg)
    ) +
    theme(
      strip.background = element_rect(
        fill = bg,
        colour = border
      ),
      strip.text = element_text(
        colour = fg,
        face = "bold"
      )
    )
}






make_forest_plot <- function(lm_obj, lme_obj, true_effect, dark_mode = FALSE){  
  
  plot_df <- bind_rows(
    lm_obj$df_fixed %>% mutate(Model = "1_LM"),
    lme_obj$df_fixed %>% mutate(Model = "0_LME")
  ) %>%
    filter(Term == "groupB")
  
  
  bg <- if (dark_mode) "#222222" else "white"
  fg <- if (dark_mode) "#E0E0E0" else "#222222"
  border <- if (dark_mode) "#777777" else "black"
  line_col <- if (dark_mode) "#3399ff" else "blue"
  clust_col <- if (dark_mode) "#3399ff" else "blue"
  

  ggplot(plot_df, aes(x = Model, y = Estimate)) +
    geom_hline(yintercept = 0.0, linetype = "dashed", color = line_col) +
    geom_errorbar(
      aes(ymin = ci_lower, ymax = ci_upper),
      width = 0.15,
      linewidth = 0.8,
      colour = line_col
    ) +
    geom_point(size = 3, colour = line_col) +
    labs(
      y = "Estimated effect (95% CI)",
      x = NULL,
      title = "Estimated group effect: LM vs LME"
    ) +
    # theme_minimal() +
    theme(legend.position = "none") +
    scale_x_discrete(
      labels = c(
        "0_LME" = "LME",
        "1_LM"  = "SLM"
      )
    ) +
    theme_classic() +
    theme(
      text = element_text(colour = fg),
      axis.text = element_text(colour = fg),
      axis.title = element_text(colour = fg),
      strip.text = element_text(colour = fg),
      panel.background = element_rect(fill = bg),
      plot.background = element_rect(fill = bg),
      panel.border = element_rect(
        colour = border,
        fill = NA,
        linewidth = 0.8
      ),
      axis.line = element_line(colour = fg)
    ) +
    theme(
      strip.background = element_rect(
        fill = bg,
        colour = border
      ),
    )
  
}












