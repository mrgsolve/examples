##' ---
##' output: 
##'   md_document:
##'     variant: markdown_github
##' ---
#+ message=FALSE

library(dplyr)
library(mrgsolve)
library(magrittr)
library(ggplot2)

#+ echo=FALSE
library(knitr)
opts_chunk$set(fig.path="img/auto_tad-",comment='.')


##' # Get time-after-dose in simulated output
##' 
##' - Argument to `mrgsim`: `tad = TRUE`
##' 
##' ## Some considerations
##' 
##' - We are keeping track of time of last dose (`TOLD`) as the simulation proceeds
##' - `TOLD` is not currently being made available to use in model code
##' - __QUESTION__ Would it be useful to pass `TOLD` back to the user (for example in `$MAIN` or `$TABLE`)?
##' 
##' 
##' 

##' ## Load a model 
##' 
##' - And we'll increase the volume to get some accumulation
#+
mod <- mread("pk1cmt", modlib(),quiet=TRUE) %>% param(VC = 50)
 
##' Simulate with `tad=TRUE`
#+
out <- 
  mod %>% 
  ev(amt=100,ii=24,addl=9) %>% 
  mrgsim(tad=TRUE,end=240, delta=0.5) 

#+
head(out)
#+
tail(out)
#+
unique(out$tad)

##' Mark the dose number
out %<>% mutate(dosen = 1+(time-tad)/24)

##' Plot
#+
ggplot(out, aes(tad,CP,col=factor(dosen))) + 
  geom_line(lwd=1)

