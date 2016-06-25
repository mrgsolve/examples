##' ---
##' output: md_document
##' ---

#+ message=FALSE
library(mrgsolve)
library(DEoptim)
library(magrittr) 
library(dplyr)
source("functions.R")

##' The model
#+ message=FALSE
mod <- mread("denpk", "model")
param(mod)
init(mod)

##' Returns the value of objective function
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
  
  obj <- sum((log.y - log.yhat)^2, na.rm=TRUE)
  
  return(obj)
}

##' Simulate a data set
set.seed(101)
d <- sim(1,mod,template(mod)) %>% filter(time <= 4032)

head(as.data.frame(d))

##' Initial estimates
##' `DEoptim` uses `lower` and `upper`
theta <- log(c(DENCL=6, DENVC=3000, DENVMAX=1000, DENVP=3000))
upper<-log(c(30,10000,10000,10000))
lower<-log(c(0.001, 0.001, 0.1, 0.1))

##' Fit with `DEoptim::DEoptim`
fit <- DEoptim(ols,d=d,n = names(theta),
               upper=upper, lower=lower,
               control=list(itermax=300))

##' Results
exp(fit$optim$bestmem)

as.numeric(param(mod))[names(theta)]
