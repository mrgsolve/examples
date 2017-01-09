``` r
library(dplyr)
library(mrgsolve)
library(magrittr)
library(ggplot2)
```

See `$ENV`
==========

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
f <- FLAG ~ runif(20,40)|GROUP

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
    .   ID GROUP       WT      AGE SEX    FLAG
    . 1  1     1 82.25019 51.97839   1 31.9009
    . 2  2     0 89.67315 42.39946   1 20.3127
    . 3  3     1 66.84383 45.56175   1 31.9009
    . 4  4     0 73.97432 66.77579   1 20.3127
    . 5  5     1 99.36337 28.43061   0 31.9009
    . 6  6     0 84.87603 75.51178   1 20.3127
