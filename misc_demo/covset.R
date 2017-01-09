##' ---
##' output: 
##'   md_document:
##'     variant: markdown_github
##' ---
#+ message=FALSE

library(dplyr)
library(mrgsolve)
library(magrittr)
library(ggplot2)

#+ echo=FALSE
library(knitr)
opts_chunk$set(fig.path="img/covset-",comment='.')


##' # See `$ENV`
##' 
##' - `a`, `b`, `d`, `f` are special formulae that work with `mutate_random` package
##' - We create sets of covariates (`covset()`) with these different formulae
##' - When we call `idata_set`, we can invoke a `covset` and those covariates get added
##' 
##' 
##' 

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

#+
mod <- mcode("foo", code)

#+
idata <- data_frame(ID=1:100,GROUP=ID%%2)


#+
mod %>% 
  idata_set(idata, covset="cov2") %>% 
  ev(amt=100) %>% mrgsim(end=48) %>% plot

#+
mod %>% 
  idata_set(idata, covset="cov2") %>% 
  simargs %>% lapply(.,head)


