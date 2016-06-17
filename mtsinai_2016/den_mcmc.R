##' ---
##' output: md_document
##' ---

#+ message=FALSE
library(mrgsolve)
library(magrittr) 
library(dplyr)
library(MCMCpack)
source("functions.R")

##' The model
#+ message=FALSE
mod <- mread("denpk", "model")
param(mod)
init(mod)

##' Log prior density without constants:
nprior <- function(theta,mu=0,tau2=1E-6) {
  -0.5*tau2*(theta-mu)^2
}
igprior <- function(theta,a=0.01,b=0.01) {
  -(a+1)*log(theta) - b/theta
}

##' Returns log prior + log likelihood
mcfun <- function(par,d,n,pred=FALSE) {
  
  par <- setNames(par,n)
  
  mod %<>% param(lapply(par[which_pk],exp))
  
  out<- 
    mod %>% 
    data_set(d) %>% 
    Req(DENCP) %>% 
    drop.re %>%
    mrgsim(obsonly=TRUE) %>%
    filter(!is.na(DENCP) & time!=0)
  
  if(pred) return(out)
  
  d %<>% filter(time > 0 & evid==0)
  
  log.yhat <- log(out$DENCP)
  log.y    <- log(d$DENmMOL)
  
  sig2 <- exp(par[which_sig])
  
  data.like <- dnorm(log.y, 
                     mean = log.yhat, 
                     sd   = sqrt(sig2), 
                     log  = TRUE)
  
  pri.pkpars <- nprior(par[which_pk])
  pri.sig2 <- igprior(sig2)
  jac.sig2 <- log(sig2)
  sum.prior <- sum(pri.pkpars,pri.sig2,jac.sig2)
  
  return(sum(data.like,sum.prior))
}

##' Simulate data
set.seed(101)
d <- sim(1,mod,template(mod)) %>% filter(time <= 4032)

head(as.data.frame(d))



##' Initial estimates
theta <- log(c(DENCL=6,DENVC=3000, DENVMAX=1000, DENVP=3000, sig2=0.1))
which_pk <- grep("DEN", names(theta))
which_sig <- grep("sig", names(theta))

##' Fit with `MCMCpack::MCMCmetrop1R`
contr <- list(fnscale = -1, trace = 0,  maxit = 1500, parscale = theta)

#+
fit <- MCMCmetrop1R(fun=mcfun,
                    theta.init = theta,
                    burnin=2000, mcmc=2000,
                    d=d,n=names(theta),
                    optim.method="Nelder",
                    verbose = 100, tune=2,
                    optim.control = contr)

##' Results
summary(exp(fit))

as.numeric(param(mod))[names(theta)]

