##' ---
##' output: 
##'   md_document:
##'     variant: markdown_github
##' ---

library(knitr)
opts_chunk$set(fig.path="img/evid4-")

library(mrgsolve)
options(mrgsolve_mread_quiet=TRUE)


##' # Proposed change for analytical PK models
##' 
##' The idea is this: specify `ADVAN` and `TRANS` in `$SUBROUTINES`.  Depending on
##' what you pick for `TRANS`, `mrgsolve` will automatically 
##' capture the "fundamental" PK parameters for that ADVAN/TRANS.
##' 
##' 
##' For `trans 2`, the fundamental parameters are `CL`, `V`, and `KA`.  We
##' can utilize items in `$PARAM` here.
##' 

code <- '
$PARAM CL = 1, V = 10, KA = 1
$CMT GUT
$SUBROUTINES advan=1, trans=2
'

#+
mod <- mcode("advan2", code)

#+
mod %>% ev(amt=1000, rate=1000/60,cmt=1) %>% mrgsim(end=120) %>% plot

code <- '
$PARAM CL = 1, V2 = 45,  Q=12, V3 = 100, KA = 1
$CMT CENT PERIPH
$SUBROUTINES advan=3, trans=4
'

#+
mod <- mcode("advan3", code)

#+
mod %>% ev(amt=1000, rate=1000/20,cmt=1) %>% mrgsim(end=120) %>% plot



##' 
##' Another `trans` (11) puts a lower case `i` at the end.  We could draw 
##' from `$PARAM` again, but in this example, we use a derived variable.
##'  
code <- '
$PARAM CL = 1, V = 35, KA = 1
$CMT GUT CENT
$SUBROUTINES advan=2, trans=11

$MAIN 
double CLi = CL*exp(ETA(1));
double Vi =  V*exp(ETA(2));
double KAi = KA;

$OMEGA 1 1
labels=s(ECL,EV)
$CAPTURE ECL EV
'

#+
mod <- mcode("advan2b", code)

#+
set.seed(110102)
mod %>% ev(amt=1000, rate=25,cmt=2) %>% mrgsim(end=120)


##' 
##' A similar deal for `ADVAN 4`
##'  
code <- '
$PARAM CL = 1, V2 = 35, V3 = 200, Q = 12, KA = 1
$CMT GUT CENT PERIPH
$SUBROUTINES advan=4, trans=4
'

#+
mod <- mcode("advan2c", code)

#+
set.seed(110102)
mod %>% ev(amt=1000, rate=25,cmt=2) %>% mrgsim(end=120)


##' Just leave me alone
##' 
code <- '
$PARAM a = 1, b = 35, c = 12, d = 200, e = 1
$CMT GUT CENT PERIPH
$SUBROUTINES advan=4, trans=1
$MAIN
pred_CL = a;
pred_V2 = b;
pred_Q = c;
pred_V3 = d;
pred_KA = e;

'

#+
mod <- mcode("advan2d", code)

#+
set.seed(110102)
mod %>% ev(amt=1000, rate=25,cmt=2) %>% mrgsim(end=120) %>% plot


##' 
##' # What's included?
##' 
##' 1. `ADVAN` 1 through 4 (as defined by NONMEM)
##' 1. `TRANS` 
##'     * 1 = nothing
##'     * 2 = CL/V/KA or CL/V2/Q/V3/KA
##'     * 11 = CLi/Vi/KAi or CLi/V2i/Qi/V3i/KAi
##' 1. You can still interact directly with `pred_CL`, `pred_V3` etc ... the `TRANS` 
##' stuff is just convenience to save you typing.  
##' 1. I'm not planning a ton of error checking to make sure you have valid 
##' symbols defined given your selection for `TRANS`.  But if you don't, the compiler 
##' will give a pretty clear error that `Vi` (for example) wasn't found.
##' 1. I'd like to eventually deprecate `$ADVAN2` and `$ADVAN4`.  For now, they should work 
##' as they always have.
##' 
##' 
##' 
