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
##' 

#+
mod <- mread("pk1cmt", modlib(),quiet=TRUE) %>% param(VC = 50)
 
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

##+
out %<>% mutate(dosen = 1+(time-tad)/24)

#+
ggplot(out, aes(tad,CP,col=factor(dosen))) + 
  geom_line(lwd=1)

