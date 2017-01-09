``` r
library(dplyr)
library(mrgsolve)
library(magrittr)
library(ggplot2)
```

About the code
==============

-   Use `$PLUGIN`
    -   `Rcpp`
    -   `mrgx`
-   We declare some variables in `$GLOBAL` so we can use them in any part of the model
    -   `appx` is an `R` function; assign it to `mrgx::mt_fun()` to hold the place
    -   `x` will be the `x` argument to `stats::approx`
    -   `y` will be the `y` argument to `stats::approx`
-   `xout` enters as a parameter (we can change it); that also gets passed to `stats::approx`
-   `$PREAMBLE` gets called **ONCE** we set thing up there
    -   First, `mrgx::get` the `approx` function from the `stats` namespace
    -   Note that the call is `mrgx::get<Rcpp::Function>`; `mrgx::get` is a templated function, so we need to say what type we are working with.
    -   We also `mrgx::get` some `Rcpp::NumericVector`s (`x` and `y`) from the model `$ENV`
-   Now, in `$MAIN` we can call the `appx` function and pass in `x`, `y`, and `xout`.
    -   `appx` returns the result as a `Rcpp::List`. We're interested in the `y` element in that list, so we need to get specific about what type (`double`) that needs to be.

More info
=========

-   <http://mrgsolve.github.io/user_guide/model-specification.html#block-plugin>

``` r
code <- '
$PARAM xout = 13

$PLUGIN Rcpp mrgx

$GLOBAL 
Rcpp::Function appx = mrgx::mt_fun(); 
Rcpp::NumericVector x;
Rcpp::NumericVector y;

$PREAMBLE
appx = mrgx::get<Rcpp::Function>("stats", "approx");
x = mrgx::get<Rcpp::NumericVector>("x", self);
y = mrgx::get<Rcpp::NumericVector>("y", self);

$MAIN
Rcpp::List out = appx(x,y,xout);
double yout = Rcpp::as<double>(out["y"]);

$ENV
set.seed(11122)
n <- 10
x <- sort(runif(n,10,20))
y <- sort(rnorm(n))

$CAPTURE xout yout
'
```

``` r
mod <- mcode("approx", code)
```

    . Compiling approx ...

    . done.

``` r
e <- get_env(mod)
```

``` r
approx(e$x,e$y, xout=13)
```

    . $x
    . [1] 13
    . 
    . $y
    . [1] 0.2543653

``` r
mrgsim(mod, end=-1) %>% as.data.frame
```

    .   ID time xout      yout
    . 1  1    0   13 0.2543653
