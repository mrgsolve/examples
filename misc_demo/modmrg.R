##' ---
##' output: 
##'   md_document:
##'     variant: markdown_github
##' ---

#+ echo=FALSE
library(knitr)
opts_chunk$set(comment='.',fig.path="img/modmrg-")


##' # Access models formerly in `modmrg`
library(mrgsolve)


##' ### PK model
mod <- mread("pk2cmt", modlib())

mod %>%
  ev(amt=100,rate=3,addl=4,ii=48,cmt=2) %>%
  mrgsim(end=320) %>% 
  plot(CP~.)

##' 
see(mod)
#+


##' ### Viral model
mod <- mread("viral1",modlib())

e <- 
  ev(amt=50, cmt="expos",time=2) + 
  ev(amt=0, cmt="expos", evid=8,time=11)

out <- 
  mod %>%
  ev(e) %>%
  update(end=28,delta=0.1) %>%
  knobs(delta=seq(0.2,0.8,0.1))


plot(out,logChange~time,groups=delta,auto.key=list(columns=4))


##' ### PK/PD model
mod <- mread("irm1", modlib())
#+
see(mod)
#+
mod %>% ev(amt=700,time=50) %>% param(n=1.5,KOUT=0.02) %>%
  mrgsim(end=480) %>% plot(CP+RESP~.)




