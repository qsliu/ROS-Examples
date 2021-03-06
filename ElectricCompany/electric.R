#' ---
#' title: "Regression and Other Stories: Electric Company"
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

#' Analysis of "Electric company" data. See Chapters 1, 16, 19 and 20
#' in Regression and Other Stories.
#' 
#' -------------
#' 

#+ setup, include=FALSE
knitr::opts_chunk$set(message=FALSE, error=FALSE, warning=FALSE, comment=NA)
# switch this to TRUE to save figures in separate files
savefigs <- FALSE

#' #### Load packages
library("rprojroot")
root<-has_dirname("ROS-Examples")$make_fix_file()
library("rstanarm")
invlogit <- plogis

#' #### Load data
electric_wide <- read.table(root("ElectricCompany/data","electric_wide.txt"), header=TRUE)
head(electric_wide)

#' #### Plot of raw data
#+ eval=FALSE, include=FALSE
if (savefigs) postscript(root("ElectricCompany/figs","electricdata.ps"), horizontal=FALSE, height=7, width=6)
#+
onlytext <- function (string){
  plot(0:1, 0:1, bty='n', type='n', xaxt='n', yaxt='n', xlab='', ylab='')
  text(0.5, 0.5, string, cex=1.2, font=2)
}
nf<- layout(matrix(c(0,1:14), 5, 3, byrow=TRUE), c(5, 10, 10), c(1, 5, 5, 5, 5), TRUE)
par(mar=c(.2, .2, .2, .2))
onlytext('Test scores in control classes')
onlytext('Test scores in treated classes')
par(mar=c(1, 1, 1, 1), lwd=0.7)
attach(electric_wide)
for (j in 1:4){
  onlytext(paste('Grade', j))
  hist(control_posttest[grade==j], breaks=seq(0,125,5), xaxt='n', yaxt='n', main=NULL, col="gray", ylim=c(0,10))
  axis(side=1, seq(0,125,50), line=-.25, cex.axis=1, mgp=c(1,.2,0), tck=0)
  text(2, 6.5, paste("mean =", round(mean(control_posttest[grade==j]))), adj=0)
  text(2, 5, paste("  sd =", round(sd(control_posttest[grade==j]))), adj=0)
  hist(treated_posttest[grade==j], breaks=seq(0,125,5), xaxt='n', yaxt='n', main=NULL, col="gray", ylim=c(0,10))
  axis(side=1, seq(0,125,50), line=-.25, cex.axis=1, mgp=c(1,.2,0), tck=0)
  text(2, 6.5, paste("mean =", round(mean(treated_posttest[grade==j]))), adj=0)
  text(2, 5, paste("  sd =", round(sd(treated_posttest[grade==j]))), adj=0)
}
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#' #### Plot the data the other way
#+ eval=FALSE, include=FALSE
if (savefigs) postscript(root("ElectricCompany/figs","electricdata.horizontal.ps"), horizontal=F, height=6, width=7)
#+
onlytext<-function(string){
  plot(0:1, 0:1, bty='n', type='n', xaxt='n', yaxt='n', xlab='', ylab='')
  text(0.5, 0.5, string, cex=1.2, font=2)
}
nf<-layout(matrix(c(0,1:14), 3, 5, byrow=FALSE), c(5, 10, 10, 10, 10), c(1, 5, 5), TRUE)
par(mar=c(.2, .2, .2, .2))
onlytext('Control\nclasses')
onlytext('Treated\nclasses')
par(mar=c(.2,.4,.2,.4), lwd=.5)
for (j in 1:4){
  onlytext(paste('Grade', j))
  hist(control_posttest[grade==j], breaks=seq(40,125,5), xaxt='n', yaxt='n', main=NULL, col="gray", ylim=c(0,14))
  axis(side=1, seq(50,100,25), line=-.25, cex.axis=1, mgp=c(1,.2,0), tck=0, lty="blank")
  lines(rep(mean(control_posttest[grade==j]),2), c(0,11), lwd=2)
  hist(treated_posttest[grade==j], breaks=seq(40,125,5), xaxt='n', yaxt='n', main=NULL, col="gray", ylim=c(0,14))
  axis(side=1, seq(50,100,25), line=-.25, cex.axis=1, mgp=c(1,.2,0), tck=0, lty="blank")
  lines(rep(mean(treated_posttest[grade==j]),2), c(0,11), lwd=2)
}
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#' #### Another plot
#+ eval=FALSE, include=FALSE
if (savefigs) postscript(root("ElectricCompany/figs","electricscatter1a.ps"), horizontal=TRUE, height=4)
#+
par(mfrow=c(1,4), pty="s")
x.range <- cbind(c(5,40,40,40), c(25,125,125,125))
for (j in 1:4){
  ok <- grade==j
  x <- c(treated_pretest[ok], control_pretest[ok])
  y <- c(treated_posttest[ok], control_posttest[ok])
  t <- rep(c(1,0), rep(sum(ok),2))
  plot(c(0,125), c(0,125), type="n", main=paste("Grade",j), xaxs="i", yaxs="i",
        xlab=expression(paste("pre-test, ",x[i])),
        ylab=expression(paste("post-test, ",y[i])),
        cex.axis=1.5, cex.lab=1.5, cex.main=1.8, mgp=c(2.5,.7,0))
  fit_1 <- stan_glm(y ~ x + t, data = electric_wide, refresh = 0, 
                    save_warmup = FALSE, open_progress = FALSE, cores = 1)
  abline(coef(fit_1)[1], coef(fit_1)[2], lwd=.5, lty=2)
  abline(coef(fit_1)[1]+coef(fit_1)[3], coef(fit_1)[2], lwd=.5)
  points(control_pretest[ok], control_posttest[ok], pch=20, cex=1.2)
  points(treated_pretest[ok], treated_posttest[ok], pch=21, cex=1.2)
}
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#' #### Yet another plot
#+ eval=FALSE, include=FALSE
if (savefigs) postscript(root("ElectricCompany/figs","electricscatter1b.ps"), horizontal=TRUE, height=4)
#+
par(mfrow=c(1,4), pty="s")
for (j in 1:4){
  ok <- grade==j
  x <- c(treated_pretest[ok], control_pretest[ok])
  y <- c(treated_posttest[ok], control_posttest[ok])
  t <- rep(c(1,0), rep(sum(ok),2))
    plot(c(0,125),c(0,125), type="n", main=paste("Grade",j),
        xlab=expression(paste("pre-test, ",x[i])),
        ylab=expression(paste("post-test, ",y[i])),
        cex.axis=1.5, cex.lab=1.5, cex.main=1.8, mgp=c(2.5,.7,0))
  fit_1 <- stan_glm(y ~ x + t, data = electric_wide, refresh = 0, 
                    save_warmup = FALSE, open_progress = FALSE, cores = 1)
  abline(coef(fit_1)[1], coef(fit_1)[2], lwd=.5, lty=2)
  abline(coef(fit_1)[1]+coef(fit_1)[3], coef(fit_1)[2], lwd=.5)
  points(control_pretest[ok], control_posttest[ok], pch=20, cex=1.2)
  points(treated_pretest[ok], treated_posttest[ok], pch=21, cex=1.2)
}
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#' #### Plot more
#+ eval=FALSE, include=FALSE
if (savefigs) postscript(root("ElectricCompany/figs","electricscatter2.ps"), horizontal=TRUE, height=4)
#+
par(mfrow=c(1,4), pty="s")
for (j in 1:4){
  ok <- grade==j
  x <- c(treated_pretest[ok], control_pretest[ok])
  y <- c(treated_posttest[ok], control_posttest[ok])
  t <- rep(c(1,0), rep(sum(ok),2))
  plot(c(0,125),c(0,125), type="n", main=paste("Grade",j), xaxs="i", yaxs="i",
        xlab=expression(paste("pre-test, ",x[i])),
        ylab=expression(paste("post-test, ",y[i])),
        cex.axis=1.5, cex.lab=1.5, cex.main=1.8, mgp=c(2.5,.7,0))
  fit_1 <- stan_glm(y ~ x + t + x:t, data = electric_wide, refresh = 0, 
                    save_warmup = FALSE, open_progress = FALSE, cores = 1)
  abline(coef(fit_1)[1], coef(fit_1)[2], lwd=.5, lty=2)
  abline(coef(fit_1)[1]+coef(fit_1)[3], coef(fit_1)[2]+coef(fit_1)[4], lwd=.5)
  ## lm.1 <- lm(y ~ x + t + x*t)
  points(control_pretest[ok], control_posttest[ok], pch=20, cex=1.2)
  points(treated_pretest[ok], treated_posttest[ok], pch=21, cex=1.2)
}
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#' #### Linear model
post_test <- c(treated_posttest, control_posttest)
pre_test <- c(treated_pretest, control_pretest)
grade <- rep(electric_wide$grade, 2)
treatment <- rep(c(1,0), rep(length(treated_posttest),2))
supp <- rep(NA, length(treatment))
n_pairs <- nrow(electric_wide)
pair_id <- rep(1:n_pairs, 2)
supp[treatment==1] <- ifelse(supplement=="Supplement", 1, 0)
n <- length(post_test)
electric <- data.frame(post_test, pre_test, grade, treatment, supp, pair_id)
#write.csv(electric, root("ElectricCompany/data","electric.csv"))
#electric <- read.csv(root("ElectricCompany/data","electric.csv"))

fit_3 <- stan_glm(post_test ~ treatment + pre_test + treatment:pre_test, subset=(grade==4), data=electric, refresh = 0)
print(fit_3)

#' #### Another linear model
fit_4 <- stan_glm(post_test ~ treatment + pre_test + treatment * pre_test,
                  subset = (grade==4), data=electric, refresh = 0)
sim_4 <- as.matrix(fit_4)

#' #### Plot linear model
#+ eval=FALSE, include=FALSE
if (savefigs) postscript(root("ElectricCompany/figs","grade4.interactions.ps"), horizontal=TRUE, height=3.8, width=5)
#+
plot(0, 0, xlim=range(pre_test[grade==4]), ylim=c(-5,10),
       xlab="pre-test", ylab="treatment effect", main="treatment effect in grade 4")
abline(0, 0, lwd=.5, lty=2)
for (i in 1:20)
  curve(sim_4[i,2] + sim_4[i,4]*x, lwd=.5, col="gray", add=TRUE)
curve(coef(fit_4)[2] + coef(fit_4)[4]*x, lwd=.5, add=TRUE)
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#' #### Mean effect
n_sims <- 1000
effect <- array(NA, c(n_sims, sum(grade==4)))
for (i in 1:n_sims)
  effect[i,] <- sim_4[i,2] + sim_4[i,4]*pre_test[grade==4]
mean_effect <- rowMeans(effect)

#' #### Plot repeated regression results
est1 <- rep(NA,4)
est2 <- rep(NA,4)
se1 <- rep(NA,4)
se2 <- rep(NA,4)
for (k in 1:4) {
    fit_1 <- stan_glm(post_test ~ treatment, subset=(grade==k), data = electric,
                      refresh = 0, save_warmup = FALSE, 
                      open_progress = FALSE, cores = 1)
    fit_2 <- stan_glm(post_test ~ treatment + pre_test, subset=(grade==k),
                      data = electric, refresh = 0, save_warmup = FALSE, 
                      open_progress = FALSE, cores = 1)
    est1[k] <- coef(fit_1)[2]
    est2[k] <- coef(fit_2)[2]
    se1[k] <- se(fit_1)[2]
    se2[k] <- se(fit_2)[2]
}
regression.2tables <- function (name, est1, est2, se1, se2, label1, label2, file, bottom=FALSE){
  J <- length(name)
  name.range <- .6
  x.range <- range (est1+2*se1, est1-2*se1, est2+2*se2, est1-2*se2)
  A <- -x.range[1]/(x.range[2]-x.range[1])
  B <- 1/(x.range[2]-x.range[1])
  height <- .6*J
  width <- 8*(name.range+1)
  gap <- .4

  if (!is.na(file)) postscript(file, horizontal=F, height=height, width=width)
  par (mar=c(0,0,0,0))
  plot (c(-name.range,2+gap), c(3,-J-2), bty="n", xlab="", ylab="",
        xaxt="n", yaxt="n", xaxs="i", yaxs="i", type="n")
  text (-name.range, 2, "Subpopulation", adj=0, cex=1)
  text (.5, 2, label1, adj=.5, cex=1)
  text (1+gap+.5, 2, label2, adj=.5, cex=1)
  lines (c(0,1), c(0,0))
  lines (1+gap+c(0,1), c(0,0))
  lines (c(A,A), c(0,-J-1), lty=2, lwd=.5)
  lines (1+gap+c(A,A), c(0,-J-1), lty=2, lwd=.5)
  ax <- pretty (x.range)
  ax <- ax[(A+B*ax)>0 & (A+B*ax)<1]
  segments (A + B*ax, -.1, A + B*ax, .1, lwd=.5)
  segments (1+gap+A + B*ax, -.1, 1+gap+A + B*ax, .1, lwd=.5)
  text (A + B*ax, .7, ax, cex=1)
  text (1+gap+A + B*ax, .7, ax, cex=1)
  text (-name.range, -(1:J), name, adj=0, cex=1)
  points (A + B*est1, -(1:J), pch=20, cex=1)
  points (1+gap+A + B*est2, -(1:J), pch=20, cex=1)
  segments (A + B*(est1-se1), -(1:J), A + B*(est1+se1), -(1:J), lwd=3)
  segments (1+gap+A + B*(est2-se2), -(1:J), 1+gap+A + B*(est2+se2), -(1:J), lwd=3)
  segments (A + B*(est1-2*se1), -(1:J), A + B*(est1+2*se1), -(1:J), lwd=.5)
  segments (1+gap+A + B*(est2-2*se2), -(1:J), 1+gap+A + B*(est2+2*se2), -(1:J), lwd=.5)
  if (bottom){
    lines (c(0,1), c(-J-1,-J-1))
    lines (1+gap+c(0,1), c(-J-1,-J-1))
    segments (A + B*ax, -J-1-.1, A + B*ax, -J-1+.1, lwd=.5)
    segments (1+gap+A + B*ax, -J-1-.1, 1+gap+A + B*ax, -J-1+.1, lwd=.5)
    text (A + B*ax, -J-1-.7, ax, cex=1)
    text (1+gap+A + B*ax, -J-1-.7, ax, cex=1)
  } 
  if (!is.na(file)) graphics.off()
}
#+ eval=FALSE, include=FALSE
# plot to file
regression.2tables(paste("Grade", 1:4), est1, est2, se1, se2, "Regression on treatment indicator", "Regression on treatment indicator,\ncontrolling for pre-test", root("ElectricCompany/figs","electric.ests.ps"))
#+
regression.2tables(paste("Grade", 1:4), est1, est2, se1, se2, "Regression on treatment indicator", "Regression on treatment indicator,\ncontrolling for pre-test", NA)

#' #### Plot replace/supplement
#+ eval=FALSE, include=FALSE
if (savefigs) postscript(root("ElectricCompany/figs","electricsupp1.ps"), horizontal=TRUE, height=2.6)
#+
jitter.binary <- function (a, jitt=.05){
  a + (1-2*a)*runif(length(a), 0, jitt)
}
par(mfrow=c(1,4))
for (k in 1:4){
  cat(paste("Grade",k,":\n"))
  ok <- (grade==k)&(!is.na(supp))
  glm_supp <- stan_glm(supp ~ pre_test, family=binomial(link="logit"),
                       subset=ok, data=electric, refresh = 0, 
                       save_warmup = FALSE, open_progress = FALSE, cores = 1)
  print(glm_supp)
  sims.glm.supp <- as.matrix(glm_supp)
  plot(range(pre_test[ok]), c(0,1), type="n", xlab="Pre-test score",
        ylab="", main=paste("Grade", k),
        cex.axis=1.5, cex.lab=1.5, cex.main=1.8, mgp=c(2.5,.7,0), yaxt="n")
  axis(2, c(0,1), c("     Replace","Supp    "), cex.axis=1.5, mgp=c(2.5,.7,0))
  for (l in 1:20)
      curve(invlogit(sims.glm.supp[l,1] + sims.glm.supp[l,2]*x), lwd=.5, col="gray", add=TRUE)
  points(pre_test[supp==1&ok], jitter.binary(supp[supp==1&ok]), pch=21) #  supp:  open circle
  points(pre_test[supp==0&ok], jitter.binary(supp[supp==0&ok]), pch=20)# replace:  dot
  curve(invlogit(coef(glm_supp)[1] + coef(glm_supp)[2]*x), lwd=.5, add=TRUE)
  glm_supp <- stan_glm(post_test ~ supp + pre_test,
                       subset=((grade==k)&!is.na(supp)), data=electric, refresh = 0, 
                       save_warmup = FALSE, open_progress = FALSE, cores = 1)
  print(glm_supp)
  est1[k] <- coef(glm_supp)[2]
  se1[k] <- se(glm_supp)[2]
}
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()
#+
regression.2tablesA <- function (name, est1, se1, label1, file, bottom=FALSE){
  J <- length(name)
  name.range <- .6
  x.range <- range (est1+2*se1, est1-2*se1)
  A <- -x.range[1]/(x.range[2]-x.range[1])
  B <- 1/(x.range[2]-x.range[1])
  height <- .6*J
  width <- 8*(name.range+1)
  gap <- .4
  
  if (!is.na(file)) postscript(file, horizontal=F, height=height, width=width)
  par (mar=c(0,0,0,0))
  plot (c(-name.range,2+gap), c(3,-J-2), bty="n", xlab="", ylab="",
        xaxt="n", yaxt="n", xaxs="i", yaxs="i", type="n")
  text (-name.range, 2, "Subpopulation", adj=0, cex=1)
  text (.5, 2, label1, adj=.5, cex=1)
  lines (c(0,1), c(0,0))
  lines (c(A,A), c(0,-J-1), lty=2, lwd=.5)
  ax <- pretty (x.range)
  ax <- ax[(A+B*ax)>0 & (A+B*ax)<1]
  segments (A + B*ax, -.1, A + B*ax, .1, lwd=.5)
  text (A + B*ax, .7, ax, cex=1)
  text (-name.range, -(1:J), name, adj=0, cex=1)
  points (A + B*est1, -(1:J), pch=20, cex=1)
  segments (A + B*(est1-se1), -(1:J), A + B*(est1+se1), -(1:J), lwd=3)
  segments (A + B*(est1-2*se1), -(1:J), A + B*(est1+2*se1), -(1:J), lwd=.5)
  if (bottom){
    lines (c(0,1), c(-J-1,-J-1))
    segments (A + B*ax, -J-1-.1, A + B*ax, -J-1+.1, lwd=.5)
    text (A + B*ax, -J-1-.7, ax, cex=1)
  } 
  if (!is.na(file)) graphics.off()
}
#+ eval=FALSE, include=FALSE
# plot to file
regression.2tablesA(paste("Grade", 1:4), est1, se1, "Estimated effect of supplement,\ncompared to replacement", root("ElectricCompany/figs","electricsupp2.ps"))
#+
regression.2tablesA(paste("Grade", 1:4), est1, se1, "Estimated effect of supplement,\ncompared to replacement", NA)
