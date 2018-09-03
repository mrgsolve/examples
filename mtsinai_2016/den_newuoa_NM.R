##' ---
##' output: github_document
##' ---

#+ message=FALSE
library(mrgsolve)
library(minqa)
library(methods)
library(magrittr) 
library(dplyr)
source("functions.R")

##' The model
#+ message=FALSE
mod<- mread("denpk", "model")
param(mod)
init(mod)
see(mod)

##' Function returning the objective function
ols <- function(par,d,n,pred=FALSE) {
  
  par <- setNames(lapply(par,exp),n)
  
  out<- 
    mod %>% 
    param(par) %>%
    data_set(d) %>% 
    Req(DENCP) %>% 
    drop.re %>%
    mrgsim(obsonly=TRUE) %>%
    filter(!is.na(DENCP) & time!=0)
  
  if(pred) return(out)
  
  d %<>% filter(time > 0 & evid==0)
  
  log.yhat <- log(out$DENCP)
  log.y    <- log(d$DENmMOL)
  
  return(sum((log.y - log.yhat)^2))
  
}

##' Simulate an abbreviated data set
set.seed(101)
d <- sim(1,mod) %>% filter(time <= 4032)
head(as.data.frame(d))
 

##' Initial estimates
theta <- log(c(DENCL=6, DENVC=3000, DENVMAX=1000, DENVP=3000))

##' Fit with `minqa::newuoa`
fit1 <- newuoa(par=theta, fn=ols, d=d, n=names(theta), control=list(iprint=5))

##' Fit with `stats:: optim`
contr <- list(trace=2, parscale=theta, maxit=1500)
fit2 <- optim(par=theta, fn=ols, d=d, n=names(theta), control=contr)

##' Results
exp(fit1$par)
exp(fit2$par)
as.numeric(param(mod))[names(theta)]







