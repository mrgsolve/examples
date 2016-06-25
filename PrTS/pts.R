##' ---
##' title: ""
##' author: ""
##' date: ""
##' output:
##'   pdf_document:
##'     number_sections: true
##' ---
##'
##'
##'



##'
##'
##' \head
##'


##' # Probability of technical success
##'
##' - $\Delta_i = f\big(\Theta,\Omega,\Sigma\big)$ a the measure of treatment effect of interest
##'     - $\Theta$ = fixed effects (population parameters)
##'     - $\Omega$ = covariance matrix of subject-level random effects
##'     - $\Sigma$ = covariance matrix for within-subject random effects
##' - $\Delta_i$ could be
##'     - mean response
##'     - mean change from baseline
##'     - fraction of patients achieving some goal
##'     - median time to some event
##'     - relative measure comparing test and reference treatment
##' - PTS  = $\mathrm{P}\big(\Delta \ge \mathrm{TV}\big)$
##'     - TV = a target value; the actual goal that you want to meet
##'     - Does not depend on the sample size, trial design, etc
##'     - Calculation based on information about $\Theta, ~\Omega, ~\Sigma$ (e.g. from fitting model to data)
##'
##'
##' ## References
##'
##' - Chuang-Stein, C.,  Kirby, S., French, J.,  Kowalski, K.,  Marshall, S.,  Smith, M.K., Bycott, P.,  Beltangady, M.  *A Quantitative Approach for
##' Making Go/No-Go Decisions in Drug Development*.  Drug Information Journal, Vol 45. pp 187-202. 2011.
##' - Kowalski, K.G., French, J.L., Smith, M.K., Hutmacher, M.M. “A model-based framework for quantitative decision making in drug
##' development”. ACOP, Tuscon, AZ. 2008. http://tucson2008.go-acop.org/pdfs/8-Kowalski_FINAL.pdf
##' - Smith, M.K., French, J., Kowalski, K., Ewy, W.  *Enhanced Quantitative Decision Making - Reducing the
##' likelihood of incorrect decisions.* PAGE Pre-Meeting Presentation, St. Petersburg, Russia.  2009.
##' - Smith MK, French JL, Kowalski KG, Hutmacher MM, and Ewy W. (2011) *Decision-Making in Drug Development:
##' Application of a Model Based Framework for Assessing Trial Performance.*
##' In Clinical Trial Simulations, Holly H. C. Kimko and Carl C. Peck (eds). Springer.
##'
##'



##'
##' \newpage
##'
##' # Setup

#.libPaths("lib")
library(mrgsolve)
library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(parallel)
library(magrittr)
source("src/functions.R")
library(rmarkdown)
library(knitr)

RNGkind("L'Ecuyer-CMRG")
options(mc.cores=32)
mc.reset.stream()

theme_update(legend.position="top")
opts_chunk$set(comment='.',fig.align="center")

#+ echo=FALSE
n.mc.sim <- 320
if(FALSE) {
  rmarkdown::render("pts.R")
}

options(mrgsolve_mread_quiet=TRUE)

##'
##' # Read in (simulated) NHANES data set
##'
##' We took an NHANES data set and simulated a new, larger data set based on:
##'
##' S. J. Tannenbaum, N. H. Holford, H. Lee, C. C. Peck, and D. R. Mould.
##' *Simulation of correlated continuous and categorical variables using
##' a single multivariate distribution*. J Pharmacokinet.Pharmacodyn., 2006.
##'

##' - Filter out people with more than mild renal dysfunction
ids <- readRDS(file="data/nhanes_large.RDS") %>% filter(RFST <= 2)
##' - Keep only people with `BMI [20,35]`
ids %<>% filter(BMI >=20 & BMI <= 35)
##' - Create a marker for people with `BMI >= 25`
ids %<>% mutate(BMIG = as.integer(BMI >= 25))

##' The data set
head(ids) %>% as.data.frame
ids %>% count(RFSTAGE,BMIG)


##'
##' ## Function to automate some of the data assembly
##' - Select only `BMI`, `EGFR`, `SEX`, `RFST`, and `BMIG`
##' - Randomly sample `n` patients and add columns for `BID` dosing `x20`
##' - Create a grid of `ID`, `amt` and join to the covariates
##' - Derive `dose` column for summarizing later
##'
gen_data <- function(ids,n,amt) {

  BIG_N <- n*length(amt)

  ids %<>%
    dplyr::select(BMI,EGFR,SEX,RFST,BMIG) %>%
    sample_n(BIG_N) %>%
    mutate(ID = 1:n())

  doses <- expand.ev(ID=1:n,amt=amt,ii=12,addl=19)

  df <- left_join(doses,ids,by="ID") %>% mutate(dose=amt)

  return(as.data.frame(df))
}

##'
##' ### One population from which to simulate
##' - All takers
##' - `set = 1`
##'
data <- ids %>% gen_data(1000,500)  %>% mutate(set=1)
##'
##' ### Another population
##' - Only patients with `BMI >= 25`
##' - `set = 2`
##'
data2 <- ids %>% filter(BMI >= 25) %>% gen_data(1000,500) %>% mutate(set=2)

##'
##' ### Summarise
##'
data <- bind_rows(data,data2)
data %>% count(set,RFST,BMIG,dose)


##'
##' # The mrgsolve model
##'
mod <- mread("popmodel", "models") %>% update(delta=12, end=240)

mod
see(mod)
param(mod)

##'
##' __Mention__
##'
##' - `$THETA`
##' - `$MAIN`
##' - `$TABLE`
##'


##'
##' # The NONMEM model
##'
##' - Read in the posterior
##' - Take only post-burnin iterations
##'
post <- read_table("nonmem/1001/1001.ext", skip=1) %>% filter(ITERATION >0)

##' Sample `1000` draws from the posterior
set.seed(101)
post %<>% sample_n(1000)
om <- as_bmat(post, "OMEGA")
sg <- as_bmat(post, "SIGMA")


##'
##' ## The 3 data items we need to run the simulation
##'
##' - `post` posterior samples for `THETAn`
##' - `om` list of `OMEGA` matrices
##' - `sg` list of `SIGMA` matrices
##'

post
om[[10]]
sg[[100]]

##'
##'
##' # A function to simulate responses
##'
##'   * `i` current simulation replicate
##'   * `post` data frame holding posterior
##'   * `indata` a template data set (`data.frame`)
##'   * For each replicate (`i`), take a new draw from the posterior distribution for fixed effect estimates
##'   * Before returning, only take the day 10 value and label
##'
sim <- function(i,post,indata,pop=FALSE) {

 if(pop) mod <- mod %>% omat(om[[i]]) %>% smat(sg[[i]])

  mod %>%
    data_set(indata) %>%
    param(slice(post,i)) %>%
    Req(deff) %>%
    carry.out(RFST,BMIG,dose,set) %>%
    mrgsim(end=-1,add=240) %>%
    filter(time==240) %>%
    mutate(irep=i)
}

##' Function for `qapply`


##' Test the function
set.seed(2201)
system.time(test <- sim(11,post,data,TRUE))



##' # Run the simulation
##'
##' ## Parallel with `mclapply`
##'
##' The sequence:
##' - Draw one set of $\Theta$, $\Omega$, and $\Sigma$ from posterior / bootstrap estimates
##'     - This is `i` or `irep` or `iter`
##' - Simulate 1000 patients
##' - Filter to day-10 effect (change from baseline)
##' - Repeat for `320` iterations
##'
##'

##' If running this on windows, try doParallel code below
if(.Platform$OS.type=="windows") options(mc.cores=1)
set.seed(11002)
system.time(out <- mclapply(1:320, sim, post=post, indata=data, pop=TRUE) %>% bind_rows)

#+
out

##' ## Parallel with `qapply`
##'
##' - Requires grid engine
##'
if(FALSE) {

  stopifnot(require(qapply))

  mod <- mread("popmodel", "models", soloc="so") %>% update(delta=12, end=240)

  out <- qapply(1:32,
                parSeed=c(1,3,2,4,2,1),
                tag="q1",
                FUN=function(i,...) {loadso(mod); sim(i,...)},
                commonData=list(mod=mod, om=om,sg=sg,sim=sim),
                fargs=list(post=post,indata=data,pop=TRUE)) %>% bind_rows
}

##'
##' ## Parallel with `doParallel`
##'
##' - This should work on Windows
##'

if(FALSE) {

  stopifnot(require(doParallel))

  cl <- makeCluster(32); registerDoParallel(cl)

  clusterCall(cl, function() {
    .libPaths("lib"); library(mrgsolve); library(dplyr)
  })

  clusterExport(cl,c("sim", "mod", "om", "sg", "data", "post"))

  system.time({
    out. <- foreach(i=1:320) %dopar% {
      loadso(mod)
      sim(i,post=post,indata=data,pop=TRUE)
    } %>% bind_rows
  })
  stopCluster(cl)

}


##'
##' # Summarize simulations to get `PTS`
##'
##' ## Summary: fraction of patients reaching a target value
##'
sum <- lapply(c(-25,-22), function(tv) {
  out %>%
    group_by(irep,dose,set) %>%
    summarise(frac=mean(deff < tv)) %>%
    mutate(tv=tv)
}) %>% bind_rows %>% mutate(tvf=factor(tv))

#+
d <- sum %>% group_by(dose,tvf,tv,set) %>% do(.density(.$frac))

target.frac <- 0.65

##' The shaded area is `PTS`
ggplot(data=d, aes(x=x,y=y)) +
  geom_line() + facet_grid(set~tvf) + xlab("Fraction with response > TV") +
  geom_ribbon_density(d, "x >= 0.65",fill="tvf") + .fillSet1() +
  geom_vline(xintercept=target.frac,lty=2) + xlim(0,1)


##'
##' Calculate the tail area for each cut
##'
sum %>%
  group_by(set,tvf,dose) %>%
  summarise(PTS = mean(frac > target.frac))
#+
sum %>%
  group_by(tvf,tv,dose,set) %>%
  summarise(PTS = mean(frac > target.frac))


##'
##' ## Summary: mean response > target value
##'
sum <-
  out %>%
  group_by(irep,dose,set) %>%
  summarise(mean = mean(deff))

sum <- lapply(c(-28,-26), function(tv) sum %>% mutate(tv = tv)) %>%
  bind_rows %>% mutate(tvf=factor(tv))

#+
d <- sum %>% group_by(dose,tvf,tv,set) %>% do(.density(.$mean))

##' The shaded area is `PTS`
ggplot(data=d, aes(x,y)) +
  geom_line() +
  facet_grid(set~tv) + .fillSet1() +
  geom_ribbon_density(d,"x <= tv",fill="tvf")

sum %>%
  group_by(dose,tv,set) %>%
  summarise(PTS = mean(mean < tv))




##'
##' # Simulate model parameters from covariance matrix (of the estimate)
##'

nsimpar <- 2500
nwish <- 300
mc.cores <- 32
options(mc.cores=mc.cores)

##'
##' Take iteration `-1E9` to get the "estimate"
##'
est <- read.csv("nonmem/1001/1001.ext", header=TRUE, skip=1, sep="") %>%
  filter(ITERATION == -1E9)

##' Go into the `run.cov` file to get the covariance matrix
.cov <- read.csv("nonmem/1001/1001.cov", header=TRUE, skip=1, sep="")
.cov$NAME <- NULL
##' We only want the covariance matrix for `THETAs`; we'll handle `OMEGA` and `SIGMA` separately
take <- grep("THETA",names(.cov))
cov <- .cov[take,take]
signif(cov,3)

##' `THETA`
theta <- est[grepl("THETA",names(est))]
##' `OMEGA`
omega <- as_bmat(est,"OMEGA")[[1]]
##' `SIGMA`
sigma <- as_bmat(est,"SIGMA")[[1]]


##' ## Use `simpar` to simulate `THETA`s, `OMEGA`s, and `SIGMA`s
##'   * `?simpar`
##'   *  Distributional assumptions
##'       * $\Theta \sim$ multivariate normal
##'       * $\Omega \sim$ Inverse Wishart
##'       * $\Sigma \sim$ Inverse Wishart
##'   *  Arguments:
##'     *  `omega` is the estimated `OMEGA` matrix
##'     *  `sigma` is the estimated `SIGMA` matrix
##'     *  `odf`: `OMEGA` degrees of freedom; `odf` must be greater than `length(omega)`
##'     *  `sdf`: `SIGMA` degrees of freedom; `sdf` must be greater than `length(sigma)`
##'     *  `simpar` returns a matrix; we'll coerce to `data.frame`
##'     *  `nsim` number of sets of simulated values
##'  * Return:
##'     * Matrix of `THETA`s, `OMEGA`s, and `SIGMA`s
##'     * One simulated set per row in the matrix
##'
##'
simpost <- metrumrg::simpar(n=1500,
                            theta=unlist(theta),
                            cov=cov,
                            omega=omega,
                            sigma=sigma,
                            odf=100,sdf=1000) %>% data.frame

##' In the output, each row is one draw from the variance-covariance matrix.
head(simpost)

##' Simulated **TVCL** distribution:
#+ warning=FALSE, fig.width=6, fig.height=5
ggplot(data=simpost) + geom_histogram(aes(x=exp(TH.1)), fill=.dsb, col="grey")

##' Simulated **EC50** distribution:
#+ warning=FALSE, fig.width=6, fig.height=5
ggplot(data=simpost) + geom_histogram(aes(x=exp(TH.14)), fill=.dsb, col="grey")



##' ## Explore how simulated random effect variances depend on `df`
##'   *  We are using the `simblock` function here (`?simblock`)
##'   *  Also, we will parallelize this calculation using `mclapply`
n <- length(unlist(omega))
x <- c(16,30,100,300,1000,3000)
sims <- mclapply(x, function(i) {
  metrumrg::simblock(nwish, df=i,cov=omega) %>%
    as.data.frame %>%
    mutate(df=i)
}) %>% bind_rows



##' Just look at **OMEGA_CL**:
#+ warning=FALSE, fig.height=6
ggplot(sims) + xlim(0,0.3) + facet_wrap(~df) +
  geom_density(aes(x=V1, col=factor(df), group=factor(df)), lwd=1) +
  geom_vline(xintercept=omega[1,1], col="black", lty=2, lwd=0.8)


