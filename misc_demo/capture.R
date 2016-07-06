##' ---
##' output: 
##'   md_document:
##'     variant: markdown_github
##' ---


##' 
##' # Use `$CAPTURE` not `table()` 
##'
##' There was a recent change in the way that `$CAPTURE` works that provides a
##' substantial improvement in efficiency.  
##' 
##' Recall that the `$CAPTURE` block allows you to capture derived 
##' values into the simulation output.  For example, consider this 
##' abbreviated model specification:
##' 

#+ engine="c", eval=FALSE
$MAIN
double CLi = TVCL*exp(ETA(1));

$CAPTURE CLi

##' Here, we derive `CLi` and want to see that value in the simulated
##' output.  So we `$CAPTURE` it.  In previous version, `mrgsolve`
##' took that variable and made a call to the `table()` macro; it would 
##' insert this code into your model

#+ engine="c", eval=FALSE
$TABLE
table(CLi) = CLi;

##' You might be used to using that `table()` macro in your code too.  For example:
##'
#+ engine="c", eval=FALSE

$TABLE
table(CP) = CENT/VC;

##' ## It is now more efficient to always use `$CAPTURE` rather than `table()`.  For
##' example
##' 
#+ engine="c", eval=FALSE

$MAIN
double CLi = TVCL*exp(ETA(1));

$TABLE
double CP = CENT/VC;

$CAPTURE CLi CP

##' Note here that, regardless of the application, if we want a variable
##' to show up in the simulated output, we assign it to a variable
##' and then list it in `$CAPTURE`.  
##' 
##' Check out the benchmark below to see the efficiency increase you might see.  But
##' __NOTE__ that you will be unlikely to see this sort of 
##' speed up in short or simple simulations.  You will 
##' be more likely to see in when the simulation gets big (lots of 
##' output times and lots of individuals).
##' 
##' 
##' ### Why is `$CAPTURE` faster than `table()`?
##' 
##' `$CAPTURE` uses `std::vector<double>` to grab the values from
##' `$TABLE` while `table()` uses `std::map<std::string, double>`.  I have
##' known for a while that using the `map` here was slowing things up, but 
##' only recently got a work around for it.
##' 
##' 

##' # Benchmark
##' 
##' __NOTE__ this example is cooked up to how a big difference between
##' `$CAPTURE` and `table()`.  The speed differences may be more or less in 
##' your problem.
##' 
library(knitr)
opts_chunk$set(fig.path="img/capture-")

library(mrgsolve)
options(mrgsolve_mread_quiet=TRUE)

library(rbenchmark)

##' 
##' ## A PK model using `table()`
##' 
table <- '
$SET end=2400, delta=4
$PARAM CL=1.125, V=45, KA=1.2
$PKMODEL ncmt=1, depot=TRUE
$CMT GUT CENT

$TABLE
table(CL) = CL;
table(CP)  = CENT/V;
table(CP2) = CENT/V/2;
table(CP3) = CENT/V/4;
table(CP4) = CENT/V/8;
table(CP5) = CENT/V/16;

'
mtable <- mcode("table", table)


##' 
##' ## Same PK model using `$CAPTURE`
##' 
capture <- '
$SET end=2400, delta=4
$PARAM CL=1.125, V=45, KA=1.2
$PKMODEL ncmt=1, depot=TRUE
$CMT GUT CENT

$TABLE
double CP = CENT/V;
double CP2 = CP/2;
double CP3 = CP2/2;
double CP4 = CP3/2;
double CP5 = CP4/2;

$CAPTURE CL CP CP2 CP3 CP4 CP5
'
mcap <-   mcode("capture", capture)



##' ## Benchmark
sim <- function(m,...) m %>% ev(amt=1000,ii=24, addl=100000) %>% mrgsim(...)

##' ### Identical output whether you use `table()` or `$CAPTURE`
sim(mtable)
sim(mcap)


##' ### Timing
benchmark(sim(mtable, nid=100), 
          sim(mcap,   nid=100),
          columns=c("test", "replications", "elapsed", "relative"))



