Use `$CAPTURE` not `table()`
============================

There was a recent change in the way that `$CAPTURE` works that provides a substantial improvement in efficiency.

Recall that the `$CAPTURE` block allows you to capture derived values into the simulation output. For example, consider this abbreviated model specification:

``` c
$MAIN
double CLi = TVCL*exp(ETA(1));

$CAPTURE CLi
```

Here, we derive `CLi` and want to see that value in the simulated output. So we `$CAPTURE` it. In previous version, `mrgsolve` took that variable and made a call to the `table()` macro; it would insert this code into your model

``` c
$TABLE
table(CLi) = CLi;
```

You might be used to using that `table()` macro in your code too. For example:

``` c

$TABLE
table(CP) = CENT/VC;
```

It is now more efficient to always use `$CAPTURE` rather than `table()`. For
----------------------------------------------------------------------------

example

``` c

$MAIN
double CLi = TVCL*exp(ETA(1));

$TABLE
double CP = CENT/VC;

$CAPTURE CLi CP
```

Note here that, regardless of the application, if we want a variable to show up in the simulated output, we assign it to a variable and then list it in `$CAPTURE`.

Check out the benchmark below to see the efficiency increase you might see. But **NOTE** that you will be unlikely to see this sort of speed up in short or simple simulations. You will be more likely to see in when the simulation gets big (lots of output times and lots of individuals).

### Why is `$CAPTURE` faster than `table()`?

`$CAPTURE` uses `std::vector<double>` to grab the values from `$TABLE` while `table()` uses `std::map<std::string, double>`. I have known for a while that using the `map` here was slowing things up, but only recently got a work around for it.

Benchmark
=========

**NOTE** this example is cooked up to how a big difference between `$CAPTURE` and `table()`. The speed differences may be more or less in your problem.

``` r
library(knitr)
opts_chunk$set(fig.path="img/capture-")

library(mrgsolve)
```

    ## mrgsolve: Community Edition

    ## www.github.com/metrumresearchgroup/mrgsolve

``` r
options(mrgsolve_mread_quiet=TRUE)

library(rbenchmark)
```

A PK model using `table()`
--------------------------

``` r
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
```

Same PK model using `$CAPTURE`
------------------------------

``` r
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
```

Benchmark
---------

``` r
sim <- function(m,...) m %>% ev(amt=1000,ii=24, addl=100000) %>% mrgsim(...)
```

### Identical output whether you use `table()` or `$CAPTURE`

``` r
sim(mtable)
```

    ## Model:  table.cpp 
    ## Dim:    602 x 10 
    ## Time:   0 to 2400 
    ## ID:     1 
    ##      ID time       GUT  CENT    CL    CP    CP2   CP3   CP4    CP5
    ## [1,]  1    0 0.000e+00   0.0 1.125  0.00  0.000 0.000 0.000 0.0000
    ## [2,]  1    0 1.000e+03   0.0 1.125  0.00  0.000 0.000 0.000 0.0000
    ## [3,]  1    4 8.230e+00 915.7 1.125 20.35 10.174 5.087 2.544 1.2718
    ## [4,]  1    8 6.773e-02 836.1 1.125 18.58  9.290 4.645 2.322 1.1612
    ## [5,]  1   12 5.574e-04 756.6 1.125 16.81  8.406 4.203 2.102 1.0508
    ## [6,]  1   16 4.587e-06 684.6 1.125 15.21  7.606 3.803 1.902 0.9508
    ## [7,]  1   20 3.775e-08 619.4 1.125 13.77  6.883 3.441 1.721 0.8603
    ## [8,]  1   24 1.000e+03 560.5 1.125 12.46  6.228 3.114 1.557 0.7785

``` r
sim(mcap)
```

    ## Model:  capture.cpp 
    ## Dim:    602 x 10 
    ## Time:   0 to 2400 
    ## ID:     1 
    ##      ID time       GUT  CENT    CL    CP    CP2   CP3   CP4    CP5
    ## [1,]  1    0 0.000e+00   0.0 1.125  0.00  0.000 0.000 0.000 0.0000
    ## [2,]  1    0 1.000e+03   0.0 1.125  0.00  0.000 0.000 0.000 0.0000
    ## [3,]  1    4 8.230e+00 915.7 1.125 20.35 10.174 5.087 2.544 1.2718
    ## [4,]  1    8 6.773e-02 836.1 1.125 18.58  9.290 4.645 2.322 1.1612
    ## [5,]  1   12 5.574e-04 756.6 1.125 16.81  8.406 4.203 2.102 1.0508
    ## [6,]  1   16 4.587e-06 684.6 1.125 15.21  7.606 3.803 1.902 0.9508
    ## [7,]  1   20 3.775e-08 619.4 1.125 13.77  6.883 3.441 1.721 0.8603
    ## [8,]  1   24 1.000e+03 560.5 1.125 12.46  6.228 3.114 1.557 0.7785

### Timing

``` r
benchmark(sim(mtable, nid=100), 
          sim(mcap,   nid=100),
          columns=c("test", "replications", "elapsed", "relative"))
```

    ##                     test replications elapsed relative
    ## 2   sim(mcap, nid = 100)          100   8.851    1.000
    ## 1 sim(mtable, nid = 100)          100  13.904    1.571
