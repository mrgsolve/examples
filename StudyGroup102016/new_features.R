
library(mrgsolve)

##' This is now an error

error <- '
$PARAM CL = 1, V = 20
$CMT CENT
$PKMODEL ncmt=1

$TABLE
table(CP) = CENT/V;
'

mod <- mcode("error", error)


##' Do this instead

works <- '
$PARAM CL = 1, V = 20
$CMT CENT
$PKMODEL ncmt=1

$TABLE
double CP = CENT/V;

$CAPTURE CP
'

mod <- mcode("works", works)
mod %>% ev(amt=100) %>% mrgsim %>% plot


##' Or use typedef capture

capture <- '
$PARAM CL = 1, V = 20
$CMT CENT
$PKMODEL ncmt=1

$MAIN
capture b = 3;

$TABLE
double c = 4;
capture CP = CENT/V;
capture a = 2/c;

'

mod <- mcode("capture", capture)

mod %>% ev(amt=100) %>% mrgsim


##' Access internal library
##' 
##' - The `modmrg` package is deprecated
##' - All of those models are now available
##' internally in mrgsolve as source models
##' 
##' 


modlib()
?modlib
modlib(list=TRUE)

mod <- mread("irm2", modlib())

mod <- mread("effect", modlib())

writeLines(mrgsolve:::code(mod),"foo.cpp")


##' EXPERIMENTAL: load a batch of models
mod <- mrgsolve:::modlist(modlib())


param(mod$irm2)
see(mod$irm2)

mod$irm2 %>% 
  ev(amt=300, ii=48,addl=10) %>% 
  mrgsim(end=480) %>% 
  plot(RESP~.)










