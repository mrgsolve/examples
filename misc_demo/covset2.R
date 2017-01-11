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


##' # See `$ENV` for covariate simulation from bounded parametric distributions
##' 
##' - `a`, `d`, `f` are special formulae that work with `mutate_random` package
##' - Create a formula like `z` or `b` using the mutate function to change columns using `dplyr::mutate`
##' - We create sets of covariates (`covset()`) with these different formulae
##' - When we call `idata_set`, we can invoke a `covset` and those covariates get added
##' - The `covset` stuff (with formula parsing) is located here:
##'     - https://github.com/kylebmetrum/dmutate
##' - In the `mrgsolve` implementation, we attach parameters to the evaluation environment, so 
##' we can use parameter names in the formulae.
##' 
##' 

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
b ~ expr(11)
SEX ~ rbinomial(pfe)
AGE[18,90] ~ rnorm(tvage,20)
WT ~ expr(AGE*2-b)
FLAG ~ runif(20,40) | STUDY

$TABLE capture CP = CENT/V;
'

#+
mod <- mcode("foo", code)


#+
idata <- data_frame(ID=1:100,STUDY=ID%%2)

##' When you call `idata_set`, name the covset you want to invoke

#+
mod %>% 
  idata_set(idata, covset="cov1") %>% 
  ev(amt=100) %>% mrgsim(end=48) %>% plot



##' 
##' ## Working with `covset`
##' 
##' - All of the code and workflow that happens "inside" mrgsolve `$ENV` can be implemented in plain old `R`
##' 
##' 
##' 

##' An "environment" where to find symbols on rhs
e <- as.list(param(mod))

##' Columns to add to the data set
a <- SEX ~ rbinomial(pfe);
b <- WT[50,100] ~ rnorm(tvwt,40)
d <- AGE[18,80] ~ rnorm(tvage,20)
f <- FLAG ~ runif(20,40) | STUDY

##' Create the set of covariates that you want to add
#+
cov2 <- covset(d,f,b,a)

#+
cov2

##' Add covariates to the data
#+
idata %>% mrgsolve:::mutate_random(cov2,envir=e)



##' # Other ways to use `$ENV`
##' 
##' - Store `data.frame`
##' - Store `event` objects
##' - Store (and call) `function`
##' 
##' 



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

#+
mod <- mcode("env", code)

##' Invoke an event stored in `$ENV`
#+
mod %>% ev(object="e") %>% mrgsim(end=120) %>% plot


##' Build idata set with covariates from a function in `$ENV`
#+
mod %>% 
  ev(amt=100) %>% 
  idata_set(object="skele", covset="wt", n=100) %>% 
  mrgsim(end=48,delta=0.1) %>% plot




