#' ---
#' title: "Regression and Other Stories: Different software options"
#' author: "Andrew Gelman, Aki Vehtari"
#' date: "`r format(Sys.Date())`"
#' output:
#'   html_document:
#'     theme: readable
#'     toc: true
#'     toc_depth: 2
#'     toc_float: true
#'     code_download: true
#' ---
#' 

#' Linear regression using different software options. See Appendix B in
#' Regression and Other Stories.
#' 
#' -------------
#' 

#+ setup, include=FALSE
knitr::opts_chunk$set(message=FALSE, error=FALSE, warning=FALSE, comment=NA)

#' #### Load packages
library("arm")
library("rstanarm")
library("brms")

#' ## Create fake data
N <- 100
b <- 1:3
x1 <- rnorm(N)
x2 <- rnorm(N)
X <- cbind(rep(1,N), x1, x2)
sigma <- 2
y <- X %*% b + rnorm(N, 0, sigma)
dat <- data.frame(y, x1, x2)

#' ## Fit and display using lm, listing predictors one at a time
fit1 <- lm(y ~ x1 + x2, data = dat)
display(fit1)

#' #### Extract estimates and uncertainties
b_hat <- coef(fit1)
b_se <- se.coef(fit1)
print(cbind(b_hat, b_se), digits=3)

#' ## Fit and display using lm, using matrix of predictors
fit2 <- lm(y ~ X)
display(fit2)

#' ## Fit and display using stan_glm
fit3 <- stan_glm(y ~ x1 + x2, data = dat, refresh = 0)
print(fit3, digits=2)
#' #### Run again just to see some simulation variability
fit3 <- stan_glm(y ~ x1 + x2, data = dat, refresh = 0)
print(fit3, digits=2)

#' #### Extract estimates and uncertainties
b_hat <- coef(fit3)
b_se <- se(fit3)
print(cbind(b_hat, b_se), digits=3)

#' ## Fit and display using brms<br>
#' This will take longer as the model is not pre-compiled as in stan_glm.
fit4 <- brm(y ~ x1 + x2, data = dat, refresh = 0)
print(fit4, digits=2)
#' Stan code generated by brms can be used to learn Stan or get a
#' starting point for a model which is not yet implemented in rstanarm
#' or brms
stancode(fit4)
