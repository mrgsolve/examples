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
opts_chunk$set(fig.path="img/cama-",comment='.')


##' # `cama` (sah-mah)
##' 
##' - Russian for "herself" (or female "myself")
##' - It is what my daughter says when she wants doesn't want any help
##' 

#+
code <- '
$PARAM CL = 1, V = 20, KA = 1.2
$CMT GUT CENT
$PKMODEL ncmt=1, depot=TRUE
$ENV
cama <- function(.mod,...) {
  .mod %>% 
    ev(amt=100, ii=24, addl=3) %>%
    mrgsim(end=144, delta=0.1)
}
'

#+
mod <- mcode("cama", code)

#+
cama(mod)


#+
cama(mod) %>% plot


