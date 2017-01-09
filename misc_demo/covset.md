``` r
library(dplyr)
library(mrgsolve)
library(magrittr)
library(ggplot2)
```

See `$ENV` for covariate simulation from bounded parametric distributions
=========================================================================

-   `a`, `b`, `d`, `f` are special formulae that work with `mutate_random` package
-   We create sets of covariates (`covset()`) with these different formulae
-   When we call `idata_set`, we can invoke a `covset` and those covariates get added
-   The `covset` stuff (with formula parsing) is located here:
    -   <https://github.com/kylebmetrum/dmutate>

``` r
code <- '
$PARAM TVCL = 1, TVV = 20, TVKA = 1
pfe = 0.7, tvwt = 80, tvage = 48
WT = 70, AGE = 50, SEX = 0

$CMT GUT CENT
$PKMODEL ncmt=1, depot=TRUE
$SET req=""

$MAIN
double CL = TVCL*pow(WT/70,0.75);
double V  = TVV*(WT/70);
double KA = TVKA+0.002*(AGE-50);

if(SEX==0) V = V*0.7;
if(AGE > 65) V = V*0.8;

$CAPTURE SEX AGE WT

$ENV
a <- SEX ~ rbinomial(pfe);
b <- WT[50,100] ~ rnorm(tvwt,40)
d <- AGE[18,80] ~ rnorm(tvage,20)
f <- FLAG ~ runif(20,40) | GROUP

cov1 <- covset(a,b)
cov2 <- covset(b,d,a,f)

$TABLE
capture CP = CENT/V;
'
```

``` r
mod <- mcode("foo", code)
```

    . Compiling foo ...

    . done.

``` r
idata <- data_frame(ID=1:100,GROUP=ID%%2)
```

When you call `idata_set`, name the covset you want to invoke

``` r
mod %>% 
  idata_set(idata, covset="cov2") %>% 
  ev(amt=100) %>% mrgsim(end=48) %>% plot
```

![](img/covset-unnamed-chunk-6-1.png)

``` r
mod %>% 
  idata_set(idata, covset="cov2") %>% 
  simargs %>% lapply(.,head)
```

    . $idata
    .   ID GROUP       WT      AGE SEX     FLAG
    . 1  1     1 97.06778 38.22576   1 28.24057
    . 2  2     0 93.41336 34.92769   1 33.62317
    . 3  3     1 59.34391 54.96774   1 28.24057
    . 4  4     0 76.94537 38.46215   1 33.62317
    . 5  5     1 88.71913 61.58669   0 28.24057
    . 6  6     0 50.48138 43.57346   0 33.62317

Working with `covset`
---------------------

``` r
e <- as.list(param(mod))
a <- SEX ~ rbinomial(pfe);
b <- WT[50,100] ~ rnorm(tvwt,40)
d <- AGE[18,80] ~ rnorm(tvage,20)
f <- FLAG ~ runif(20,40) | GROUP
```

``` r
cov2 <- covset(d,f,b,a)
```

``` r
cov2
```

    . $d
    . [1] "AGE[18, 80] ~ rnorm(tvage, 20)"
    . 
    . $f
    . [1] "FLAG ~ runif(20, 40) | GROUP"
    . 
    . $b
    . [1] "WT[50, 100] ~ rnorm(tvwt, 40)"
    . 
    . $a
    . [1] "SEX ~ rbinomial(pfe)"

``` r
idata %>% mrgsolve:::mutate_random(cov2,envir=e)
```

    . # A tibble: 100 × 6
    .       ID GROUP      AGE     FLAG       WT   SEX
    .    <int> <dbl>    <dbl>    <dbl>    <dbl> <dbl>
    . 1      1     1 56.89700 35.08263 90.49052     1
    . 2      2     0 20.52915 36.18199 85.44064     0
    . 3      3     1 20.39806 35.08263 51.62502     0
    . 4      4     0 23.01154 36.18199 83.46135     0
    . 5      5     1 34.20830 35.08263 61.99369     1
    . 6      6     0 67.34234 36.18199 57.98716     1
    . 7      7     1 29.96251 35.08263 88.32505     0
    . 8      8     0 25.26993 36.18199 50.81628     1
    . 9      9     1 66.45105 35.08263 64.45956     0
    . 10    10     0 62.28655 36.18199 59.65328     1
    . # ... with 90 more rows

Other ways to use `$ENV`
========================

-   Store `data.frame`
-   Store `event` objects
-   Store (and call) `function`

``` r
code <- '
$PARAM CL = 1, TVV = 20, KA = 1, WT = 70

$CMT GUT CENT
$PKMODEL ncmt=1, depot=TRUE
$SET req=""

$MAIN double V = TVV*(WT/70);

$ENV
d <- expand.ev(ID=1:10, amt=c(100,300))

e <- ev(amt=100, ii=24, addl=3)

sk <- function(n,...) data_frame(ID=1:n)

wt <- covset(list(WT ~ runif(40,140)))

$TABLE
capture CP = CENT/V;
'
```

``` r
mod <- mcode("env", code)
```

    . Compiling env ...

    . done.

Invoke an event stored in `$ENV`

``` r
mod %>% ev(object="e") %>% mrgsim(end=120) %>% plot
```

![](img/covset-unnamed-chunk-14-1.png)

Build idata set with covariates from a function in `$ENV`

``` r
mod %>% 
  ev(amt=100) %>% 
  idata_set(object="sk", covset="wt", n=100) %>% 
  mrgsim(end=48,delta=0.1) %>% plot
```

![](img/covset-unnamed-chunk-15-1.png)
