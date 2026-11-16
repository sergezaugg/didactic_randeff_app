# ---------------------------
# Description : sandbox to draft code pieces
# Author : Serge Zaugg
# ---------------------------

library(tidyverse)
library(lme4)

generate_hierarchical_data <- function(par) {
  n <- (par$n_be_a + par$n_be_b) * par$n_wi
  n_clu <- (par$n_be_a + par$n_be_b)
  # group indicator 
  group <- c(rep(c("A"), each = par$n_be_a * par$n_wi), rep(c("B"), each = par$n_be_b * par$n_wi))
  # per-group mean
  mu <- c(rep(par$mu_a, each = par$n_be_a * par$n_wi), rep(par$mu_b, each = par$n_be_b * par$n_wi))
  # cluster/patient id
  cluster <- rep(rep(seq_len(n_clu), each = par$n_wi),times = 1)
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


plot_hierarchical_data <- function(dat) {
  
  
  dat <- dat |>
    dplyr::group_by(group) |>
    dplyr::mutate(x_pos = as.numeric(factor(cluster))) |>
    dplyr::ungroup()
  
  ggplot(dat,aes(x = factor(cluster), y = y)) +
    geom_jitter(width = 0.1, height = 0.0) +
    
    geom_hline(
      data = dat,
      aes(yintercept = mu),
      colour = "red",
      linewidth = 0.8,
      linetype = "dashed"
    ) +
    
    geom_segment(
      data = dat,
      aes(
        x = x_pos - 0.2,
        xend = x_pos + 0.2,
        y = mu + error_between,
        yend = mu + error_between
      ),
      colour = "blue",
      linewidth = 1
    ) + 
    
    
    facet_wrap(~group, scales = "free_x") +
    labs(x = "Cluster",y = "Outcome", title = "") +
    theme_classic() + 
    theme(
      panel.border = ggplot2::element_rect(
        colour = "black",
        fill = NA,
        linewidth = 0.8
      )
    )
}



#----------------------
# user input 
mu_a <- 5
mu_b <- 5
n_between_a <- 10
n_between_b <- 7
n_within <- 5
sd_between <- 1.3
sd_within <- 0.1

#----------------------
# server 
par <- list(
  mu_a = mu_a,
  mu_b = mu_b,
  n_be_a = n_between_a,
  n_be_b = n_between_b,
  n_wi = n_within,
  sd_be = sd_between,
  sd_wi = sd_within
)

df <- generate_hierarchical_data(par)


mod <- lmer(y ~ group + (1 | cluster), data = df)
mod_null <- lmer(y ~ 1 + (1 | cluster), data = df)
summary(mod)


df_random <- as.data.frame(VarCorr(mod)) |>
  select(groups = grp, std_dev = sdcor)

df_fixed <- as.data.frame(coef(summary(mod))) |> 
  rownames_to_column("Term")

df_lrt <- as.data.frame(anova(mod_null, mod))
p_value <- df_lrt$`Pr(>Chisq)`[2]


#----------------------
# display result  
plot_hierarchical_data(df)

estim_sd_between  <- df_random |> filter(groups == 'cluster') |> pull('std_dev')
estim_sd_resid    <- df_random |> filter(groups == 'Residual') |> pull('std_dev')
estim_effect_mean <- df_fixed |> filter(Term == 'groupB') |> pull('Estimate')
estim_effect_std  <- df_fixed |> filter(Term == 'groupB') |> pull('Std. Error')
estim_effect_pval <- df_lrt$`Pr(>Chisq)`[2]


# check 
summary(mod)
anova(mod_null, mod)









