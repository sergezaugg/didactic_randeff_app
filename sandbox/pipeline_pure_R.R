# ---------------------------
# Description : sandbox to draft code pieces
# Author : Serge Zaugg
# ---------------------------

library(tidyverse)
library(lme4)
source("src/utils.R")

#----------------------
# user input 
mu_a <- 4
mu_b <- 5
n_between_a <- 10
n_between_b <- 7
n_within <- 5
sd_between <- 0.5
sd_within <- 0.5

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

dat <- generate_hierarchical_data(par)
lme_obj <- fit_random_effects_model(df = dat)
plot_resu <- plot_hierarchical_data(dat = dat)

estim_sd_between   <- lme_obj$df_random |> filter(groups == 'cluster') |> pull('std_dev')
estim_sd_resid     <- lme_obj$df_random |> filter(groups == 'Residual') |> pull('std_dev')
estim_effect_mean  <- lme_obj$df_fixed |> filter(Term == 'groupB') |> pull('Estimate')
estim_effect_std   <- lme_obj$df_fixed |> filter(Term == 'groupB') |> pull('Std. Error')
estim_effect_ci_lo <- lme_obj$df_fixed |> filter(Term == 'groupB') |> pull('ci_lower')
estim_effect_ci_up <- lme_obj$df_fixed |> filter(Term == 'groupB') |> pull('ci_upper')
estim_effect_pval  <- lme_obj$p_value



dat <- generate_hierarchical_data(par)

lme_obj <- fit_random_effects_model(df = dat)
lm_obj  <- fit_simple_linear_model(df = dat)

lme_obj$df_random
lm_obj$df_random

lme_obj$df_random
lm_obj$df_random
















