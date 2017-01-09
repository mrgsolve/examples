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
    . 1  1     1 56.47623 54.82734   1 37.32024
    . 2  2     0 62.08936 56.88345   1 29.29350
    . 3  3     1 89.37275 61.02407   0 37.32024
    . 4  4     0 81.34116 54.96600   0 29.29350
    . 5  5     1 78.42925 76.58212   1 37.32024
    . 6  6     0 96.62674 50.70584   1 29.29350

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
    . 1      1     1 59.17934 37.40704 58.84396     1
    . 2      2     0 55.64413 30.08119 90.45238     0
    . 3      3     1 41.18411 37.40704 53.64815     1
    . 4      4     0 59.37677 30.08119 83.37265     1
    . 5      5     1 53.52646 37.40704 98.46003     1
    . 6      6     0 53.32454 30.08119 89.80928     1
    . 7      7     1 31.04367 37.40704 81.78208     1
    . 8      8     0 31.35138 30.08119 83.97577     0
    . 9      9     1 75.54843 37.40704 59.49527     1
    . 10    10     0 32.53747 30.08119 85.11012     0
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
