#' ---
#' title: "Regression and Other Stories: AgePeriodCohort"
#' author: "Andrew Gelman, Jennifer Hill, Aki Vehtari"
#' date: "`r format(Sys.Date())`"
#' output:
#'   html_document:
#'     theme: readable
#'     toc: true
#'     toc_depth: 2
#'     toc_float: true
#' ---

#' Age-Period-Cohort - Demonstration of age adjustment to estimate
#' trends in mortality rates. See Chapter 3 in Regression and Other
#' Stories.
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

#' #### Load data
births <- read.table(root("AgePeriodCohort/data","births.txt"), header=TRUE)
mean_age_45_54 <- function(yr){
  ages <- 45:54
  ok <- births$year %in% (yr - ages)
  return(sum(births$births[ok]*rev(ages))/sum(births$births[ok]))
}
for (yr in 1989:2015) print(mean_age_45_54(yr), digits=3)

#' #### Calculation
print((.5/10)* (.006423 - .003064)/.003064, digits=3)

#' #### From life table
deathpr_by_age <- c(.003064, .003322, .003589, .003863, .004148, .004458, .004800, .005165, .005554, .005971)
deathpr_male <- c(.003244, .003571, .003926, .004309, .004719, .005156, .005622, .006121, .006656, .007222)
deathpr_female <- c(.002069, .002270, .002486, .002716, .002960, .003226, .003505, .003779, .004040, .004301)
                    
#' #### Sum it up
pop <- read.csv(root("AgePeriodCohort/data","US-EST00INT-ALLDATA.csv"))
years <- 1989:2013
deathpr_1 <- rep(NA, length(years))
deathpr_2 <- rep(NA, length(years))
for (i in 1:length(years)){
  ages_in_2000 <- (2000 - years[i]) + (45:54)
  ok <- pop[,"AGE"] %in% ages_in_2000 & pop[,"MONTH"]==4 & pop[,"YEAR"]==2000
  pop_male <- pop[ok,"NHWA_MALE"]
  pop_female <- pop[ok,"NHWA_FEMALE"]
  print(c(weighted.mean(45:54, pop_male), weighted.mean(45:54, pop_female)),
        digits=3)
  deathpr_1[i] <- weighted.mean(deathpr_by_age, pop_male + pop_female)
  deathpr_2[i] <- sum(deathpr_male* pop_male + deathpr_female*pop_female)/sum(pop_male + pop_female)
}

#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","births.pdf"), height=5.5, width=7)
#+
par(mar=c(4,4,3,0), mgp=c(2.2,.5,0), tck=-.01)
plot(years, deathpr_2/deathpr_2[1], type="l", bty="l", xlab="Year", ylab="Death rate (compared to rate in 1989) ", main="Approx increase in death rate among 45-54-year-old whites,\n expected just from the changing age composition of this group", col="red", lwd=2, cex.axis=1.1, cex.lab=1.1)
grid(col="gray")
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#'
deaton <- read.table(root("AgePeriodCohort/data","deaton.txt"), header=TRUE)
ages_all <- 35:64
ages_decade <- list(35:44, 45:54, 55:64)
years_1 <- 1999:2013
mort_data <- as.list(rep(NA,3))
group_names <- c("Non-Hispanic white", "Hispanic white", "African American")
mort_data[[1]] <- read.table(root("AgePeriodCohort/data","white_nonhisp_death_rates_from_1999_to_2013_by_sex.txt"), header=TRUE)
mort_data[[2]] <- read.table(root("AgePeriodCohort/data","white_hisp_death_rates_from_1999_to_2013_by_sex.txt"), header=TRUE)
mort_data[[3]] <- read.table(root("AgePeriodCohort/data","black_death_rates_from_1999_to_2013_by_sex.txt"), header=TRUE)
#'
raw_death_rate <- array(NA, c(length(years_1), 3, 3))
male_raw_death_rate <- array(NA, c(length(years_1), 3, 3))
female_raw_death_rate <- array(NA, c(length(years_1), 3, 3))
avg_death_rate <- array(NA, c(length(years_1), 3, 3))
male_avg_death_rate <- array(NA, c(length(years_1), 3, 3))
female_avg_death_rate <- array(NA, c(length(years_1), 3, 3))
for (k in 1:3){
  data <- mort_data[[k]]
  male <- data[,"Male"]==1
  for (j in 1:3){
    for (i in 1:length(years_1)){
      ok <- data[,"Year"]==years_1[i] & data[,"Age"] %in% ages_decade[[j]]
      raw_death_rate[i,j,k] <- 1e5*sum(data[ok,"Deaths"])/sum(data[ok,"Population"])
      male_raw_death_rate[i,j,k] <- 1e5*sum(data[ok&male,"Deaths"])/sum(data[ok&male,"Population"])
      female_raw_death_rate[i,j,k] <- 1e5*sum(data[ok&!male,"Deaths"])/sum(data[ok&!male,"Population"])
      avg_death_rate[i,j,k] <- mean(data[ok,"Rate"])
      male_avg_death_rate[i,j,k] <- mean(data[ok&male,"Rate"])
      female_avg_death_rate[i,j,k] <- mean(data[ok&!male,"Rate"])
    }
  }
}

for (k in 1:3) {
  data <- mort_data[[k]]
  if (savefigs) pdf(root("AgePeriodCohort/figs",
                       paste("death_rates_by_age_and_eth_", k, ".pdf", sep="")),
                  height=11, width=8)
  par(mfrow=c(7,5), mar=c(2.5, 2.5, 2, .2),
      mgp=c(1.5,.3,0), tck=-.01, oma=c(0,0,3,0))
  years_1 <- 1999:2013
  for (i in 1:length(ages_all)){
    ok <- data[,"Age"]==ages_all[i]
    male <- data["Male"]==1
    male_deaths <- data[ok&male,"Deaths"]
    female_deaths <- data[ok&!male,"Deaths"]
    male_population <- data[ok&male,"Population"]
    female_population <- data[ok&!male,"Population"]
    male_mort <- male_deaths/male_population
    female_mort <- female_deaths/female_population
    total_mort <- (male_deaths + female_deaths)/(male_population + female_population)
    plot(years_1, total_mort/total_mort[1], xaxt="n", yaxt="n",
         ylim=range(.65,1.25), type="n", bty="n", xaxs="i", yaxs="i",
         xlab="", ylab=if (i%%5==1) "Relative death rate" else "",
         main=paste("age", ages_all[i]))
    lines(years_1, male_mort/male_mort[1], col="blue")
    lines(years_1, female_mort/female_mort[1], col="red")
    axis(1, seq(1990,2020,5))
    axis(2, seq(.6,1.2,.2))
    abline(h=1)
    grid(col="gray")
  }
  for (j in 1:3){
      plot(years_1, avg_death_rate[,j,k]/avg_death_rate[1,j,k],
           xaxt="n", yaxt="n", ylim=range(.65,1.25), type="n", bty="n",
           xaxs="i", yaxs="i", xlab="",
           ylab=if (j==1) "Relative death rate" else "",
           main=paste("Age-adj, ", min(ages_decade[[j]]), "-", max(ages_decade[[j]]), sep=""))
    lines(years_1, male_avg_death_rate[,j,k]/male_avg_death_rate[1,j,k], col="blue")
    lines(years_1, female_avg_death_rate[,j,k]/female_avg_death_rate[1,j,k], col="red")
    axis(1, seq(1990,2020,5))
    axis(2, seq(.6,1.2,.2))
    abline(h=1, col="gray")
  }
  mtext(paste(group_names[k], "women and men: trends in death rates since 1999"), side=3, outer=TRUE, line=1)
  par(mar=c(0,0,0,0))
  plot(c(-1,1), c(-1,1), xaxt="n", xlab="", yaxt="n", ylab="",
       bty="n", type="n")
  plot(c(-1,1), c(-1,1), xaxt="n", xlab="", yaxt="n", ylab="",
       bty="n", type="n")
  text(0, .5, paste("Red lines show\ntrends for women."), col="red")
  text(0, -.2, paste("Blue lines show\ntrends for men."), col="blue")
  if (savefigs) dev.off()
}

#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","effect_of_age_adj.pdf"), height=6, width=7)
#+
par(mfrow=c(3,3), mar=c(2.5, 2.5, 2, .2), mgp=c(1.5,.3,0), tck=-.01,
    oma=c(0,0,4,0))
text_pos <- array(NA, c(2,2,3,3))
text_pos[1,1,,] <- cbind(c(2008, 2003, 2010), c(2005, 2011, 2005), c(2005, 2007, 2005))
text_pos[2,1,,] <- cbind(c(2005, 2004, 2007), c(2004, 2008, 2006), c(2004, 2006, 2006))
text_pos[1,2,,] <- cbind(c(1.04, 1.06, .88), c(.91, .85, .88), c(.90, .90, .84))
text_pos[2,2,,] <- cbind(c(1.02, 1.03, .86), c(.86, .85, .93), c(.82, .80, .90))
for (k in 1:3){
  for (j in 1:3){
    rng <- range(avg_death_rate[,j,k]/avg_death_rate[1,j,k], raw_death_rate[,j,k]/raw_death_rate[1,j,k])
    plot(years_1, avg_death_rate[,j,k]/avg_death_rate[1,j,k], ylim=rng,
         xaxt="n", type="l", bty="l", xaxs="i",
         xlab="", ylab=if (j==1) "Death rate relative to 1999" else "",
         main=paste(group_names[k], " age ", min(ages_decade[[j]]), "-", max(ages_decade[[j]]), sep=""))
    lines(years_1, raw_death_rate[,j,k]/raw_death_rate[1,j,k], lty=2)
    abline(h=1, col="gray")
    axis(1, seq(1990,2020,5))
    text(text_pos[1,1,j,k], text_pos[1,2,j,k], "Raw", cex=.9)
    text(text_pos[2,1,j,k], text_pos[2,2,j,k], "Adjusted", cex=.9)
  }
}
mtext("Effects of age adjustment on trends in death rates by decade of age\n(Note:  these graphs are on different scales)", side=3, line=1, outer=TRUE)
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()


#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","decades.pdf"), height=6, width=7)
#+
par(mfrow=c(3,3), mar=c(2.5, 2.5, 2, .2), mgp=c(1.5,.3,0), tck=-.01, oma=c(0,0,4,0))
for (k in 1:3){
  for (j in 1:3){
    plot(years_1, avg_death_rate[,j,k]/avg_death_rate[1,j,k], xaxt="n", yaxt="n", ylim=range(.7, 1.1), type="n", bty="n", xaxs="i", yaxs="i", xlab="", ylab=if (j==1) "Relative death rate" else "", main=paste(group_names[k], ", ", min(ages_decade[[j]]), "-", max(ages_decade[[j]]), sep=""))
    lines(years_1, male_avg_death_rate[,j,k]/male_avg_death_rate[1,j,k], col="blue")
    lines(years_1, female_avg_death_rate[,j,k]/female_avg_death_rate[1,j,k], col="red")
    axis(1, seq(1990,2020,5))
    axis(2, seq(.7, 1.2, .1))
    abline(h=1, col="gray")
  }
}
mtext("Age-adjusted trends in death rate for 10-year bins", side=3, line=1, outer=TRUE)
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","focus_group.pdf"), height=7, width=7)
#+
par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
plot(years_1, avg_death_rate[,2,1],  ylim=c(382, 416), xaxt="n", yaxt="n", type="l", bty="l", xaxs="i", xlab="", ylab="Death rate per 100,000", main="AGE-ADJUSTED death rates for non-Hispanic whites aged 45-54")
axis(1, seq(1990,2020,5))
axis(2, seq(390, 420, 10))
grid(col="gray")
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()


#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","focus_group_2.pdf"), height=6, width=7)
#+
par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
plot(years_1, raw_death_rate[,2,1],  ylim=c(382,  416), xaxt="n", yaxt="n", type="l", bty="l", xaxs="i", xlab="", ylab="Death rate per 100,000", main="RAW death rates for non-Hispanic whites aged 45-54")
axis(1, seq(1990,2020,5))
axis(2, seq(390, 420, 10))
grid(col="gray")
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()


#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","focus_group_3.pdf"), height=6, width=7)
#+
par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
plot(range(years_1), c(1, 1.1), xaxt="n", yaxt="n", type="n", bty="l", xaxs="i", xlab="", ylab="Death rate relative to 1999", main="Age-adjusted death rates for non-Hispanic whites aged 45-54:\nTrends for women and men")
lines(years_1, male_avg_death_rate[,2,1]/male_avg_death_rate[1,2,1], col="blue")
lines(years_1, female_avg_death_rate[,2,1]/female_avg_death_rate[1,2,1], col="red")
axis(1, seq(1990,2020,5))
axis(2, seq(1, 1.1, .05))
text(2011.5, 1.075, "Women", col="red")
text(2010.5, 1.02, "Men", col="blue")
grid(col="gray")
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()


#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","focus_group_4.pdf"), height=6, width=7)
#+
par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
plot(range(years_1), c(1, 1.15), xaxt="n", yaxt="n", type="n", bty="l", xaxs="i", xlab="", ylab="Death rate relative to 1999", main="RAW death rates for non-Hispanic whites aged 45-54:\nTrends for women and men")
lines(years_1, male_raw_death_rate[,2,1]/male_raw_death_rate[1,2,1], col="blue")
lines(years_1, female_raw_death_rate[,2,1]/female_raw_death_rate[1,2,1], col="red")
axis(1, seq(1990,2020,5))
axis(2, seq(1, 1.2, .05))
text(2011.5, 1.11, "Women", col="red")
text(2010.5, 1.045, "Men", col="blue")
grid(col="gray")
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#' Simple graph of totals
number_of_deaths <- rep(NA, length(years_1))
number_of_people <- rep(NA, length(years_1))
avg_age <- rep(NA, length(years_1))
avg_age_census <- rep(NA, length(years_1))
data <- mort_data[[1]]
death_rate_extrap_1999 <- rep(NA, length(years_1))
death_rate_extrap_2013 <- rep(NA, length(years_1))
male <- data[,"Male"]==1
ok_1999 <- data[,"Year"]==1999 & data[,"Age"] %in% ages_decade[[2]] 
death_rate_1999 <- (data[ok_1999 & male, "Deaths"] + data[ok_1999 & !male, "Deaths"])/(data[ok_1999 & male, "Population"] + data[ok_1999 & !male, "Population"])
ok_2013<- data[,"Year"]==2013 & data[,"Age"] %in% ages_decade[[2]] 
death_rate_2013 <- (data[ok_2013 & male, "Deaths"] + data[ok_2013 & !male, "Deaths"])/(data[ok_2013 & male, "Population"] + data[ok_2013 & !male, "Population"])
age_adj_rate_flat <- rep(NA, length(years_1))
age_adj_rate_1999 <- rep(NA, length(years_1))
age_adj_rate_2013 <- rep(NA, length(years_1))
  ok <- data[,"Age"] %in% ages_decade[[2]]
  pop1999 <- data[ok & data[,"Year"]==1999 & male,"Population"] + data[ok & data[,"Year"]==1999 & !male,"Population"]
  pop2013 <- data[ok & data[,"Year"]==2013 & male,"Population"] + data[ok & data[,"Year"]==2013 & !male,"Population"]
for (i in 1:length(years_1)){
  ok <- data[,"Year"]==years_1[i] & data[,"Age"] %in% ages_decade[[2]]
  number_of_deaths[i] <- sum(data[ok,"Deaths"])
  number_of_people[i] <- sum(data[ok,"Population"])
  avg_age[i] <- weighted.mean(ages_decade[[2]], data[ok & male,"Population"] + data[ok & !male,"Population"])
  avg_age_census[i] <- mean_age_45_54(years_1[i])
  rates <- (data[ok&male,"Deaths"] + data[ok&!male,"Deaths"])/(data[ok&male,"Population"] + data[ok&!male,"Population"])
  age_adj_rate_flat[i] <- weighted.mean(rates, rep(1,10))
  age_adj_rate_1999[i] <- weighted.mean(rates, pop1999)
  age_adj_rate_2013[i] <- weighted.mean(rates, pop2013)
}
for (i in 1:length(years_1)){
  ok <- data[,"Year"]==years_1[i] & data[,"Age"] %in% ages_decade[[2]]
  death_rate_extrap_1999[i] <- weighted.mean(death_rate_1999, data[ok & male,"Population"] + data[ok & !male,"Population"])
  death_rate_extrap_2013[i] <- weighted.mean(death_rate_2013, data[ok & male,"Population"] + data[ok & !male,"Population"])
}


#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","first_order_bias_a.pdf"), height=4, width=5)
#+
par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
plot(years_1,  number_of_deaths, xaxt="n", type="l", bty="l", xaxs="i", xlab="", ylab="Number of deaths", main="Raw data show a stunning rise and fall\nin mortality among non-Hispanic whites aged 45-54", cex.main=.9)
axis(1, seq(1990,2020,5))
grid(col="gray")
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","first_order_bias_b.pdf"), height=4, width=5)
#+
par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
plot(years_1,  number_of_people, xaxt="n", type="l", bty="l", xaxs="i", xlab="", ylab="Number of non-Hispanic whites aged 45-54", main="But the denominator is changing in the same way!", cex.main=.9)
axis(1, seq(1990,2020,5))
grid(col="gray")
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","second_order_bias_a.pdf"), height=4, width=5)
#+
par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
plot(years_1,  number_of_deaths/number_of_people, xaxt="n", type="l", bty="l", xaxs="i", xlab="", ylab="Mortality rate among non-Hisp whites 45-54", main="So take the ratio!", cex.main=.9)
axis(1, seq(1990,2020,5))
grid(col="gray")
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()


#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","second_order_bias_b.pdf"), height=4, width=5)
#+
par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
plot(years_1, avg_age, xaxt="n", type="l", bty="l", xaxs="i", xlab="", ylab="Avg age among non-Hisp whites 45-54", main="But the average age in this group is going up!", cex.main=.9)
axis(1, seq(1990,2020,5))
grid(col="gray")
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()


#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","second_order_bias_c.pdf"), height=4, width=5)
#+
par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
plot(years_1, avg_age, xaxt="n", type="l", bty="l", xaxs="i", xlab="", ylab="Avg age among non-Hisp whites 45-54", main="Let's check the average age using a different dataset", cex.main=.9)
axis(1, seq(1990,2020,5))
lines(years_1, avg_age_census, col="orange")
text(2011.7, 49.6, "From\nCDC data", cex=.8)
text(2007.5, 49.55, "Extrapolation from\n2001 Census", col="orange", cex=.8)
grid(col="gray")
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()



#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","second_order_bias_d.pdf"), height=4, width=5)
#+
par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
plot(years_1, death_rate_extrap_1999, xaxt="n", type="n", bty="l", xaxs="i", xlab="", ylab="Reconstructed death rate", main="Increase in death rate among 45-54-year-old non-Hisp whites,\n expected just from the changing age composition of this group", cex.main=.8)
lines(years_1, death_rate_extrap_1999, col="green4")
axis(1, seq(1990,2020,5))
grid(col="gray")
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()



#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","second_order_bias_e.pdf"), height=4, width=5)
#+
par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
plot(years_1, number_of_deaths/number_of_people, xaxt="n", type="l", bty="l", xaxs="i", xlab="", ylab="Death rate for 45-54 non-Hisp whites", main="Increase in death rate among 45-54-year-old non-Hisp whites,\n expected just from the changing age composition of this group", cex.main=.8)
lines(years_1, death_rate_extrap_1999, col="green4")
axis(1, seq(1990,2020,5))
text(2002.5, .00404, "Raw death rate", cex=.8)
text(2009, .00394, "Expected just from\nage shift", col="green4", cex=.8)
grid(col="gray")
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()


#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","second_order_bias_f.pdf"), height=4, width=5)
#+
par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
plot(years_1, number_of_deaths/number_of_people, xaxt="n", type="l", bty="l", xaxs="i", xlab="", ylab="Death rate for 45-54 non-Hisp whites", main="Projecting backward from 2013 makes it clear that\nall the underlying change happened between 1999 and 2005", cex.main=.8)
lines(years_1, death_rate_extrap_2013, col="green4")
axis(1, seq(1990,2020,5))
text(2003, .00395, "Raw death rate", cex=.8)
text(2001.5, .004075, "Expected just from\nage shift", col="green4", cex=.8)
grid(col="gray")
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()

#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","third_order_bias_a.pdf"), height=4, width=5)
#+
par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
plot(years_1, age_adj_rate_flat/age_adj_rate_flat[1], xaxt="n", type="l", bty="l", xaxs="i", xlab="", ylab="Age-adj death rate, relative to 1999", main="Trend in age-adjusted death rate\nfor 45-54-year-old non-Hisp whites", cex.main=.8)
axis(1, seq(1990,2020,5))
grid(col="gray")
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()


#+ eval=FALSE, include=FALSE
if (savefigs) pdf(root("AgePeriodCohort/figs","third_order_bias_b.pdf"), height=4, width=5)
#+
par(mar=c(2.5, 3, 3, .2), mgp=c(2,.5,0), tck=-.01)
rng <- range(age_adj_rate_flat/age_adj_rate_flat[1], age_adj_rate_1999/age_adj_rate_1999[1], age_adj_rate_2013/age_adj_rate_2013[1])
plot(years_1, age_adj_rate_flat/age_adj_rate_flat[1], ylim=rng, xaxt="n", type="l", bty="l", xaxs="i", xlab="", ylab="Age-adj death rate, relative to 1999", main="It doesn't matter too much what age adjustment\nyou use for 45-54-year-old non-Hisp whites", cex.main=.8)
lines(years_1, age_adj_rate_1999/age_adj_rate_1999[1], lty=2)
lines(years_1, age_adj_rate_2013/age_adj_rate_2013[1], lty=3)
text(2003, 1.053, "Using 1999\nage dist", cex=.8)
text(2004, 1.032, "Using 2013\nage dist", cex=.8)
axis(1, seq(1990,2020,5))
grid(col="gray")
#+ eval=FALSE, include=FALSE
if (savefigs) dev.off()
