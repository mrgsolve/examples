``` r
library(dplyr)
library(mrgsolve)
library(magrittr)
library(ggplot2)
```

About
=====

-   This model doesn't really accomplish anything useful. I coded this up to show how we can get `vector`, `matrix` data as well as `R` functions into your simulation.

Not sure what's going on?
=========================

-   Scroll down to the bottom for some context and discussion.

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

What problem does this solve?
=============================

So you might be asking, why do you need to do all of this? The general goal is to allow you to get a variety of data structures into your model code.

So far, you've been able to get scalar values via the `$PARAM` list. This allows you to say what the `TVCL` is or the `KA` or the patient `WT` etc. When you specifiy parameters with those names, those symbols take (scalar) values and we can use them in the code and we can update those values in a couple of different ways. Note that you also can input matrices in `$OMEGA` and `$SIGMA`, but you don't get direct access to those matrices ... only the variates that were drawn using those matrices.

We've hit the point where getting scalar data into the problem isn't enough. Now, we are working on models that require `vector` data or specification of `matrix` data. Usually we are requiring those data structures in `numeric` format. We would also like to call `R` functions using that data to do calculations necessary for the model simulation to proceed.

The models we are talking about are complex and still fairly unusual. I expect 95% of users to never need stuff like this. But I think it's important for those who do need this extra functionality to be able to access it. Otherwise, the modeling hits a roadblock.

The general mechanism for specifying non-scalar data to get into the problem is through `$ENV`. This block is just regular old `R` code that gets parsed and evaluated into a new `environment`. That environment stays with the model object and we access the objects in that environment or modify them (similar to the way we work with a `$PARAM` list).

Because many different data types could possibly be in the mix now, we need to take an extra step or two to access those objects. This means an extra step to go into the `$ENV` environment, and `get` an object. This usually only needs to be done **ONCE** ... at the start of the problem. We go get the required objects and have them ready to use as the simulation proceeds. This is essentially what the `$PREAMBLE` block is for: it is a C++ function (like `$MAIN`) that gets called once and lets you set up the C++ environment as you please ... including extracting objects from your `$ENV` (or potentially from `.GlobalEnv`) or from other `R` packages.

You will see illustrated below several functions in the `mrgx` plugin that help you do this. Remember also that since we are importing `R` objects that are `vectors`, `matrices`, and `functions`, we also need to invoke the `Rcpp` plugin.

Note that we are getting and calling an `R` function in this problem. This is fine if no other alternative is available / possible. But be aware that there will be **some** performance ding for this. It would be much more efficient to code an `Rcpp` version of `approx`. We have that function and it does speed things up. Hopefully another vignette coming that illustrates how to set up that function.
