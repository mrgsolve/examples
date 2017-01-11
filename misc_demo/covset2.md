``` r
library(dplyr)
library(mrgsolve)
library(magrittr)
library(ggplot2)
```

See `$COVSET` for covariate simulation from bounded parametric distributions
============================================================================

-   We specify covariates as random variables, potentially with lower and upper bounds
-   We can evaluate an expression in the data with a formula using `expr` function
-   All of these covariates get added to your `data_set` or `idata_set`
-   We create sets of covariates (`covset()`) with these different formulae
-   When we call `idata_set`, we can invoke a `covset` and those covariates get added
-   The `covset` stuff (with formula parsing) is located here:
    -   <https://github.com/kylebmetrum/dmutate>
-   In the `mrgsolve` implementation, we attach parameters to the evaluation environment, so we can use parameter names in the formulae.

``` r
code <- '
$PARAM TVCL = 1, TVV = 20, TVKA = 1
pfe = 0.7, tvwt = 80, tvage = 48
WT = 70, AGE = 50, SEX = 0, theta3 = 11

$PKMODEL cmt="GUT,CENT" , depot=TRUE
$SET req="", delta=0.25

$MAIN
double CL = TVCL*pow(WT/70,0.75);
double V  = TVV*(WT/70);
double KA = TVKA+0.002*(AGE-50);

if(SEX==0) V = V*0.7;
if(AGE > 65) V = V*0.8;

$CAPTURE SEX AGE WT

$COVSET @name cov1
STUDY ~ expr(sample(ID)%%2)
b ~ expr(11)
SEX ~ rbinomial(pfe)
AGE[18,90] ~ rnorm(tvage,20)
WT ~ expr(AGE*2-b)
FLAG ~ runif(20,40) | STUDY

$TABLE capture CP = CENT/V;
'
```

``` r
mod <- mcode("foo", code)
```

``` r
idata <- data_frame(ID=1:100)
```

When you call `idata_set`, name the covset you want to invoke

``` r
mod %>% 
  idata_set(idata, covset="cov1") %>% 
  ev(amt=100) %>% mrgsim(end=48) %>% plot
```

![](img/covset-unnamed-chunk-6-1.png)

Here's what is happening:

``` r
mod %>% idata_set(idata, covset="cov1") %>% simargs %>% lapply(head)
```

    . $idata
    .   ID STUDY  b SEX      AGE        WT     FLAG
    . 1  1     1 11   1 35.01608  59.03215 35.33668
    . 2  2     1 11   1 73.74770 136.49541 35.33668
    . 3  3     0 11   1 44.67265  78.34530 39.56706
    . 4  4     1 11   0 52.68216  94.36432 35.33668
    . 5  5     0 11   1 25.56362  40.12725 39.56706
    . 6  6     1 11   0 63.15400 115.30800 35.33668

Working with `covset`
---------------------

-   All of the code and workflow that happens "inside" mrgsolve `$ENV` can be implemented in plain old `R`

An "environment" where to find symbols on rhs

``` r
e <- as.list(param(mod))
```

Columns to add to the data set

``` r
a <- SEX ~ rbinomial(pfe);
b <- WT[50,100] ~ rnorm(tvwt,40)
d <- AGE[18,80] ~ rnorm(tvage,20)
s <- STUDY ~ expr(sample(ID)%%2)
f <- FLAG ~ runif(20,40) | STUDY
```

Create the set of covariates that you want to add

``` r
cov2 <- covset(d,s,f,b,a)
```

``` r
cov2
```

    . $d
    . [1] "AGE[18, 80] ~ rnorm(tvage, 20)"
    . 
    . $s
    . [1] "STUDY ~ expr(sample(ID)%%2)"
    . 
    . $f
    . [1] "FLAG ~ runif(20, 40) | STUDY"
    . 
    . $b
    . [1] "WT[50, 100] ~ rnorm(tvwt, 40)"
    . 
    . $a
    . [1] "SEX ~ rbinomial(pfe)"
    . 
    . attr(,"class")
    . [1] "covset"

Add covariates to the data

``` r
idata %>% mrgsolve:::mutate_random(cov2,envir=e)
```

    . # A tibble: 100 × 6
    .       ID      AGE STUDY     FLAG       WT   SEX
    .    <int>    <dbl> <dbl>    <dbl>    <dbl> <dbl>
    . 1      1 42.57292     0 25.82872 96.09889     0
    . 2      2 36.01879     0 25.82872 75.18640     1
    . 3      3 66.03805     1 29.04194 95.47189     1
    . 4      4 50.59217     1 29.04194 81.14880     0
    . 5      5 46.65063     1 29.04194 74.43486     0
    . 6      6 64.31989     0 25.82872 51.80531     1
    . 7      7 50.22581     0 25.82872 84.33909     0
    . 8      8 36.79871     0 25.82872 82.68266     0
    . 9      9 58.29132     0 25.82872 50.10891     1
    . 10    10 26.72953     1 29.04194 93.35832     1
    . # ... with 90 more rows

Other ways to use `$ENV`
========================

-   Store `data.frame`
-   Store `event` objects
-   Store (and call) `function`

``` r
code <- '
$PARAM CL = 1, TVV = 20, KA = 1, WT = 70

$PKMODEL cmt="GUT,CENT", depot=TRUE
$SET req=""

$MAIN double V = TVV*(WT/70);

$COVSET @name wt
WT ~ runif(40,140)

$ENV
d <- expand.ev(ID=1:10, amt=c(100,300))

e <- ev(amt=100, ii=24, addl=3)

skele <- function(n,...) data_frame(ID=1:n)


$TABLE
capture CP = CENT/V;
'
```

``` r
mod <- mcode("env", code)
```

Invoke an event stored in `$ENV`

``` r
mod %>% ev(object="e") %>% mrgsim(end=120) %>% plot
```

![](img/covset-unnamed-chunk-15-1.png)

Build idata set with covariates from a function in `$ENV`

``` r
mod %>% 
  ev(amt=100) %>% 
  idata_set(object="skele", covset="wt", n=100) %>% 
  mrgsim(end=48,delta=0.1) %>% plot
```

![](img/covset-unnamed-chunk-16-1.png)
