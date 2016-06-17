##' ---
##' output: md_document
##' ---

#+ messages=FALSE
library(mrgsolve)
library(DEoptim)
library(magrittr) 
library(dplyr)
source("functions.R")

#+
mod <- mread("denpk", "model")
param(mod)
init(mod)

#+
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

#+
set.seed(101)
d <- sim(1,mod,template(mod)) %>% filter(time <= 4032)

#+
theta <- log(c(DENCL=6, DENVC=3000, DENVMAX=1000, DENVP=3000))
upper<-log(c(30,10000,10000,10000))
lower<-log(c(0.001, 0.001, 0.1, 0.1))

##' DEoptim fit
fit <- DEoptim(ols,d=d,n = names(theta),
               upper=upper, lower=lower,
               control=list(itermax=300))

#+
exp(fit$optim$bestmem)

as.numeric(param(mod))[names(theta)]
