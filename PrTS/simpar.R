##' --- 
##' output: md_document
##' ---


##' # `simpar` and inverse Chi-square distribution


#+ message=FALSE
if(!require(metrumrg)) stop("Install metrumrg package first.")

library(mrgsolve)
library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(parallel)
library(magrittr)
source("src/functions.R")
knitr::opts_chunk$set(comment='.')

#+ echo=FALSE
nsimpar <- 2500
nwish <- 300
mc.cores <- ifelse(.Platform$OS.type=="windows", 1,32)
options(mc.cores=mc.cores)

##'
##' Take iteration `-1E9` to get the "estimate"
##'
est <- read.csv("nonmem/1001/1001.ext", header=TRUE, skip=1, sep="") %>%
  filter(ITERATION == -1E9)

##' Go into the `run.cov` file to get the covariance matrix
.cov <- read.csv("nonmem/1001/1001.cov", header=TRUE, skip=1, sep="")
.cov$NAME <- NULL

##' We only want the covariance matrix for `THETAs`; we'll handle `OMEGA` and `SIGMA` separately
take <- grep("THETA",names(.cov))
cov <- .cov[take,take]

##' `THETA`
theta <- est[grepl("THETA",names(est))]
##' `OMEGA`
omega <- as_bmat(est,"OMEGA")[[1]]

##' `SIGMA`
##' 
##' We'll change `SIGMA` around a bit; make it a single porportional error 
##' variance
##' 
sigma <- matrix(0.028)


##'
##'
simpost <- metrumrg::simpar(n=1500,
                            theta=unlist(theta),
                            cov=cov,
                            omega=omega,
                            sigma=sigma) %>% data.frame

##' Some really big values for SG1.1
summary(simpost[,"SG1.1"])


##' When `SIGMA` is 1x1 matrix, we use inverse chi-square (`?rinvchisq`) distribution
##' to simulate.  When `SIGMA` is 2x2 (or more, we use inverse Wishart)
##' 
##' Check `metrumrg::simblock`, which simulates random effect variances
##' 
metrumrg::simblock
#+
metrumrg::rinvchisq

##' By default, `simpar` uses degrees of freedom equal to the length of `SIGMA`
length(sigma)

##' In this case, it is 1 ... so simulated values can be all over the place.

##' Quick sensitivity analysis with `simblock` / `rinvchisq`
#+
df <- c(1,3,10,30,100,300)
n <- 10000

#+
sim <- lapply(df,rinvchisq, n=n,cov=sigma)

#+
sims <- lapply(sim,function(x) {
    data_frame(min=min(x), median=median(x), mean=mean(x), max=max(x),sd=sd(x))
})

#+
sims <- bind_rows(sims) %>% mutate(df=df)

#+
sims



