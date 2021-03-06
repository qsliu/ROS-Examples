#' ---
#' title: "Regression and Other Stories: Earnings"
#' author: "Andrew Gelman, Jennifer Hill, Aki Vehtari"
#' date: "`r format(Sys.Date())`"
#' output:
#'   html_document:
#'     theme: readable
#'     toc: true
#'     toc_depth: 2
#'     toc_float: true
#'     code_download: true
#' ---

#' Predict respondents' yearly earnings using survey data from
#' 1990. See Chapter 15 in Regression and Other Stories.
#' 
#' -------------
#' 

#+ setup, include=FALSE
knitr::opts_chunk$set(message=FALSE, error=FALSE, warning=FALSE, comment=NA)

#' #### Load packages
library("rprojroot")
root<-has_dirname("ROS-Examples")$make_fix_file()
library("rstanarm")
library("ggplot2")
library("bayesplot")
theme_set(bayesplot::theme_default(base_family = "sans"))

#' #### Load data
earnings <- read.csv(root("Earnings/data","earnings.csv"))
head(earnings)

#' ## Compound discrete-continuos model

#' #### Logistic regression on non-zero earnings
fit_2a <- stan_glm((earn>0) ~ height + male,
                   family = binomial(link = "logit"),
                   data = earnings, refresh = 0)
sims_2a <- as.matrix(fit_2a)
print(fit_2a, digits=2)

#' #### Linear regression on log scale
fit_2b <- stan_glm(log(earn) ~ height + male,
                   data = earnings, subset = earn>0,
                   refresh = 0)
sims_2b <- as.matrix(fit_2b)
print(fit_2b, digits=2)

#' #### Predictions for a new person
new <- data.frame(height = 68, male = 0, earnings$earn>0)
pred_2a <- posterior_predict(fit_2a, newdata=new)
pred_2b <- posterior_predict(fit_2b, newdata=new)
pred <- ifelse(pred_2a == 1, exp(pred_2b), 0)
