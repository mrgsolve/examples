``` r
library(dplyr)
library(mrgsolve)
library(magrittr)
library(ggplot2)
```

See `$ENV`
==========

-   `a`, `b`, `d`, `f` are special formulae that work with `mutate_random` package
-   We create sets of covariates (`covset()`) with these different formulale
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
  ev(amt=100) %>% mrgsim(end=120) %>% plot
```

![](img/covset-unnamed-chunk-6-1.png)

``` r
mod %>% 
  idata_set(idata, covset="cov2") %>% 
  simargs %>% lapply(.,head)
```

    . $idata
    .   ID GROUP       WT      AGE SEX     FLAG
    . 1  1     1 53.04120 48.69764   1 39.75256
    . 2  2     0 77.80304 53.30236   0 38.72127
    . 3  3     1 86.99440 43.40655   0 39.75256
    . 4  4     0 75.36060 35.72132   1 38.72127
    . 5  5     1 52.59413 34.09294   1 39.75256
    . 6  6     0 83.40036 25.33765   1 38.72127
