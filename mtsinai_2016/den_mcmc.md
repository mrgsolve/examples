den\_mcmc.R
================
kyleb
Mon Sep 3 15:59:56 2018

``` r
library(mrgsolve)
library(magrittr) 
library(dplyr)
library(MCMCpack)
source("functions.R")
```

The model

``` r
mod <- mread("denpk", "model")
param(mod)
```

    ## 
    ##  Model parameters (N=5):
    ##  name  value . name    value
    ##  DENCL 2.75  | DENVMAX 3110 
    ##  DENKM 188   | DENVP   1324 
    ##  DENVC 2340  | .       .

``` r
init(mod)
```

    ## 
    ##  Model initial conditions (N=3):
    ##  name          value . name        value
    ##  DENCENT (2)   0     | DENSC (1)   0    
    ##  DENPER (3)    0     | . ...       .

Log prior density without constants:

``` r
nprior <- function(theta,mu=0,tau2=1E-6) {
  -0.5*tau2*(theta-mu)^2
}
igprior <- function(theta,a=0.01,b=0.01) {
  -(a+1)*log(theta) - b/theta
}
```

Returns log prior + log likelihood

``` r
mcfun <- function(par,d,n,pred=FALSE) {
  
  par <- setNames(par,n)
  
  mod %<>% param(lapply(par[which_pk],exp))
  
  out<- 
    mod %>% 
    data_set(d) %>% 
    Req(DENCP) %>% 
    drop.re %>%
    mrgsim(obsonly=TRUE) %>%
    filter(!is.na(DENCP) & time!=0)
  
  if(pred) return(out)
  
  d %<>% filter(time > 0 & evid==0)
  
  log.yhat <- log(out$DENCP)
  log.y    <- log(d$DENmMOL)
  
  sig2 <- exp(par[which_sig])
  
  data.like <- dnorm(log.y, 
                     mean = log.yhat, 
                     sd   = sqrt(sig2), 
                     log  = TRUE)
  
  pri.pkpars <- nprior(par[which_pk])
  pri.sig2 <- igprior(sig2)
  jac.sig2 <- log(sig2)
  sum.prior <- sum(pri.pkpars,pri.sig2,jac.sig2)
  
  return(sum(data.like,sum.prior))
}
```

Simulate data

``` r
set.seed(101)
d <- sim(1,mod) %>% filter(time <= 4032)

head(as.data.frame(d))
```

    ##   ID time evid   amt cmt   ii addl  DENmMOL
    ## 1  1    0    0 0e+00   0    0    0 0.000000
    ## 2  1    0    1 1e+07   1 4032    3 0.000000
    ## 3  1   12    0 0e+00   0    0    0 1.655885
    ## 4  1   34    0 0e+00   0    0    0 3.758968
    ## 5  1  168    0 0e+00   0    0    0 5.909730
    ## 6  1  336    0 0e+00   0    0    0 6.741199

Initial estimates

``` r
theta <- log(c(DENCL=6,DENVC=3000, DENVMAX=1000, DENVP=3000, sig2=0.1))
which_pk <- grep("DEN", names(theta))
which_sig <- grep("sig", names(theta))
```

Fit with `MCMCpack::MCMCmetrop1R`

``` r
contr <- list(fnscale = -1, trace = 0,  maxit = 1500, parscale = theta)
```

``` r
fit <- MCMCmetrop1R(fun=mcfun,
                    theta.init = theta,
                    burnin=2000, mcmc=2000,
                    d=d,n=names(theta),
                    optim.method="Nelder",
                    verbose = 100, tune=2,
                    optim.control = contr)
```

    ## MCMCmetrop1R iteration 1 of 4000 
    ## function value = -1478.96754
    ## theta = 
    ##    1.78701
    ##    8.02474
    ##    6.97452
    ##    8.11488
    ##   -2.13668
    ## Metropolis acceptance rate = 1.00000
    ## 
    ## MCMCmetrop1R iteration 101 of 4000 
    ## function value = -165.35841
    ## theta = 
    ##    1.91545
    ##    8.29164
    ##    6.74728
    ##    7.38028
    ##    1.75170
    ## Metropolis acceptance rate = 0.44554
    ## 
    ## MCMCmetrop1R iteration 201 of 4000 
    ## function value = -160.60871
    ## theta = 
    ##    1.73355
    ##    8.04069
    ##    6.36477
    ##    6.76810
    ##    1.19217
    ## Metropolis acceptance rate = 0.47761
    ## 
    ## MCMCmetrop1R iteration 301 of 4000 
    ## function value = -157.84615
    ## theta = 
    ##    1.23283
    ##    7.25603
    ##    5.89426
    ##    6.26205
    ##    1.34779
    ## Metropolis acceptance rate = 0.43854
    ## 
    ## MCMCmetrop1R iteration 401 of 4000 
    ## function value = -155.73058
    ## theta = 
    ##    0.99690
    ##    6.56405
    ##    5.91617
    ##    6.60609
    ##    1.32113
    ## Metropolis acceptance rate = 0.44140
    ## 
    ## MCMCmetrop1R iteration 501 of 4000 
    ## function value = -154.15153
    ## theta = 
    ##    0.91101
    ##    6.88857
    ##    5.98223
    ##    6.28285
    ##    1.16935
    ## Metropolis acceptance rate = 0.43713
    ## 
    ## MCMCmetrop1R iteration 601 of 4000 
    ## function value = -159.29181
    ## theta = 
    ##    0.76246
    ##    6.80186
    ##    5.74450
    ##    6.02753
    ##    1.23614
    ## Metropolis acceptance rate = 0.42429
    ## 
    ## MCMCmetrop1R iteration 701 of 4000 
    ## function value = -156.78908
    ## theta = 
    ##    0.75531
    ##    6.51672
    ##    5.80706
    ##    6.31107
    ##    1.41239
    ## Metropolis acceptance rate = 0.40799
    ## 
    ## MCMCmetrop1R iteration 801 of 4000 
    ## function value = -156.90216
    ## theta = 
    ##    0.90357
    ##    6.99166
    ##    5.96733
    ##    6.08742
    ##    0.80738
    ## Metropolis acceptance rate = 0.39576
    ## 
    ## MCMCmetrop1R iteration 901 of 4000 
    ## function value = -155.18005
    ## theta = 
    ##    0.82692
    ##    6.79535
    ##    5.81181
    ##    5.99377
    ##    1.31693
    ## Metropolis acceptance rate = 0.40511
    ## 
    ## MCMCmetrop1R iteration 1001 of 4000 
    ## function value = -155.75859
    ## theta = 
    ##    0.71601
    ##    6.48018
    ##    5.69957
    ##    6.14557
    ##    1.11293
    ## Metropolis acceptance rate = 0.39061
    ## 
    ## MCMCmetrop1R iteration 1101 of 4000 
    ## function value = -156.28871
    ## theta = 
    ##    0.74767
    ##    6.85483
    ##    5.75054
    ##    5.64852
    ##    1.28950
    ## Metropolis acceptance rate = 0.39964
    ## 
    ## MCMCmetrop1R iteration 1201 of 4000 
    ## function value = -150.90306
    ## theta = 
    ##    0.83876
    ##    6.74407
    ##    6.02078
    ##    6.23563
    ##    0.95262
    ## Metropolis acceptance rate = 0.39384
    ## 
    ## MCMCmetrop1R iteration 1301 of 4000 
    ## function value = -154.73241
    ## theta = 
    ##    1.02402
    ##    6.78295
    ##    5.97639
    ##    6.52350
    ##    0.92010
    ## Metropolis acceptance rate = 0.39585
    ## 
    ## MCMCmetrop1R iteration 1401 of 4000 
    ## function value = -152.34550
    ## theta = 
    ##    0.86882
    ##    6.91250
    ##    5.97037
    ##    6.01717
    ##    1.05814
    ## Metropolis acceptance rate = 0.40186
    ## 
    ## MCMCmetrop1R iteration 1501 of 4000 
    ## function value = -151.27017
    ## theta = 
    ##    1.08206
    ##    6.95780
    ##    6.16178
    ##    6.44975
    ##    1.18036
    ## Metropolis acceptance rate = 0.40040
    ## 
    ## MCMCmetrop1R iteration 1601 of 4000 
    ## function value = -152.37546
    ## theta = 
    ##    0.64579
    ##    6.51174
    ##    5.81917
    ##    5.96480
    ##    1.10317
    ## Metropolis acceptance rate = 0.39600
    ## 
    ## MCMCmetrop1R iteration 1701 of 4000 
    ## function value = -151.28538
    ## theta = 
    ##    0.57645
    ##    6.68304
    ##    6.04972
    ##    5.83134
    ##    0.90699
    ## Metropolis acceptance rate = 0.39683
    ## 
    ## MCMCmetrop1R iteration 1801 of 4000 
    ## function value = -147.50854
    ## theta = 
    ##    0.61921
    ##    6.52463
    ##    6.10580
    ##    6.08572
    ##    1.20499
    ## Metropolis acceptance rate = 0.39256
    ## 
    ## MCMCmetrop1R iteration 1901 of 4000 
    ## function value = -145.61949
    ## theta = 
    ##    0.74908
    ##    6.67630
    ##    6.30494
    ##    6.39461
    ##    0.99818
    ## Metropolis acceptance rate = 0.38874
    ## 
    ## MCMCmetrop1R iteration 2001 of 4000 
    ## function value = -145.19375
    ## theta = 
    ##    0.69747
    ##    6.66395
    ##    6.21336
    ##    6.14180
    ##    1.10845
    ## Metropolis acceptance rate = 0.38781
    ## 
    ## MCMCmetrop1R iteration 2101 of 4000 
    ## function value = -136.16387
    ## theta = 
    ##    0.82180
    ##    6.91404
    ##    6.53163
    ##    6.29558
    ##    0.60380
    ## Metropolis acceptance rate = 0.38696
    ## 
    ## MCMCmetrop1R iteration 2201 of 4000 
    ## function value = -124.41493
    ## theta = 
    ##    1.06087
    ##    7.29907
    ##    6.92639
    ##    6.51210
    ##    0.39862
    ## Metropolis acceptance rate = 0.38437
    ## 
    ## MCMCmetrop1R iteration 2301 of 4000 
    ## function value = -102.00680
    ## theta = 
    ##    1.00348
    ##    7.23823
    ##    7.31833
    ##    6.90955
    ##    0.15270
    ## Metropolis acceptance rate = 0.37897
    ## 
    ## MCMCmetrop1R iteration 2401 of 4000 
    ## function value =  -15.79713
    ## theta = 
    ##    0.88158
    ##    7.46358
    ##    7.79774
    ##    6.99351
    ##   -2.77866
    ## Metropolis acceptance rate = 0.37443
    ## 
    ## MCMCmetrop1R iteration 2501 of 4000 
    ## function value =   14.00938
    ## theta = 
    ##    0.99405
    ##    7.77359
    ##    7.97319
    ##    7.01478
    ##   -2.79306
    ## Metropolis acceptance rate = 0.36505
    ## 
    ## MCMCmetrop1R iteration 2601 of 4000 
    ## function value =   19.79123
    ## theta = 
    ##    0.97470
    ##    7.67557
    ##    8.05735
    ##    7.25540
    ##   -3.30859
    ## Metropolis acceptance rate = 0.35333
    ## 
    ## MCMCmetrop1R iteration 2701 of 4000 
    ## function value =   19.03431
    ## theta = 
    ##    0.96367
    ##    7.70440
    ##    8.02679
    ##    7.16571
    ##   -3.19399
    ## Metropolis acceptance rate = 0.34395
    ## 
    ## MCMCmetrop1R iteration 2801 of 4000 
    ## function value =   19.57579
    ## theta = 
    ##    1.01727
    ##    7.79601
    ##    8.02137
    ##    7.11524
    ##   -3.45969
    ## Metropolis acceptance rate = 0.33631
    ## 
    ## MCMCmetrop1R iteration 2901 of 4000 
    ## function value =   16.39262
    ## theta = 
    ##    0.96527
    ##    7.73744
    ##    7.98218
    ##    7.02789
    ##   -3.08627
    ## Metropolis acceptance rate = 0.32713
    ## 
    ## MCMCmetrop1R iteration 3001 of 4000 
    ## function value =   18.38386
    ## theta = 
    ##    1.02025
    ##    7.82790
    ##    8.06431
    ##    7.13754
    ##   -3.35441
    ## Metropolis acceptance rate = 0.31823
    ## 
    ## MCMCmetrop1R iteration 3101 of 4000 
    ## function value =   15.33080
    ## theta = 
    ##    1.00344
    ##    7.74881
    ##    7.95489
    ##    7.03442
    ##   -3.14591
    ## Metropolis acceptance rate = 0.31151
    ## 
    ## MCMCmetrop1R iteration 3201 of 4000 
    ## function value =   20.45072
    ## theta = 
    ##    0.99430
    ##    7.77247
    ##    8.01630
    ##    7.10515
    ##   -3.40201
    ## Metropolis acceptance rate = 0.30397
    ## 
    ## MCMCmetrop1R iteration 3301 of 4000 
    ## function value =   16.92088
    ## theta = 
    ##    1.04269
    ##    7.81120
    ##    8.07304
    ##    7.21256
    ##   -3.30684
    ## Metropolis acceptance rate = 0.29688
    ## 
    ## MCMCmetrop1R iteration 3401 of 4000 
    ## function value =   19.54238
    ## theta = 
    ##    0.99806
    ##    7.77061
    ##    8.01760
    ##    7.09137
    ##   -3.33500
    ## Metropolis acceptance rate = 0.28962
    ## 
    ## MCMCmetrop1R iteration 3501 of 4000 
    ## function value =   20.04475
    ## theta = 
    ##    0.99432
    ##    7.75595
    ##    8.05188
    ##    7.19865
    ##   -3.26890
    ## Metropolis acceptance rate = 0.28278
    ## 
    ## MCMCmetrop1R iteration 3601 of 4000 
    ## function value =   20.48443
    ## theta = 
    ##    0.99506
    ##    7.73546
    ##    8.04772
    ##    7.20249
    ##   -3.52615
    ## Metropolis acceptance rate = 0.27576
    ## 
    ## MCMCmetrop1R iteration 3701 of 4000 
    ## function value =   20.55083
    ## theta = 
    ##    1.01097
    ##    7.78483
    ##    8.04537
    ##    7.16067
    ##   -3.42616
    ## Metropolis acceptance rate = 0.26858
    ## 
    ## MCMCmetrop1R iteration 3801 of 4000 
    ## function value =   18.14819
    ## theta = 
    ##    1.01766
    ##    7.78705
    ##    8.06273
    ##    7.19751
    ##   -3.03362
    ## Metropolis acceptance rate = 0.26414
    ## 
    ## MCMCmetrop1R iteration 3901 of 4000 
    ## function value =   19.20427
    ## theta = 
    ##    0.95281
    ##    7.60649
    ##    8.02959
    ##    7.26500
    ##   -3.36853
    ## Metropolis acceptance rate = 0.25993
    ## 
    ## 
    ## 
    ## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ## The Metropolis acceptance rate was 0.25400
    ## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

Results

``` r
summary(exp(fit))
```

    ## 
    ## Iterations = 2001:4000
    ## Thinning interval = 1 
    ## Number of chains = 1 
    ## Sample size per chain = 2000 
    ## 
    ## 1. Empirical mean and standard deviation for each variable,
    ##    plus standard error of the mean:
    ## 
    ##           Mean       SD  Naive SE Time-series SE
    ## [1,]    2.6614   0.1536  0.003434        0.03332
    ## [2,] 2084.6977 491.7948 10.996867      187.75421
    ## [3,] 2673.4269 818.1140 18.293584      509.90216
    ## [4,] 1182.3966 242.0906  5.413310       70.85466
    ## [5,]    0.3193   0.6583  0.014720        0.33342
    ## 
    ## 2. Quantiles for each variable:
    ## 
    ##           2.5%       25%       50%       75%    97.5%
    ## var1   2.18610 2.650e+00 2.705e+00 2.748e+00    2.823
    ## var2 794.75145 2.102e+03 2.288e+03 2.374e+03 2522.810
    ## var3 611.05410 2.915e+03 3.034e+03 3.116e+03 3223.642
    ## var4 520.81668 1.154e+03 1.257e+03 1.338e+03 1499.045
    ## var5   0.02885 3.352e-02 3.805e-02 4.576e-02    2.301

``` r
as.numeric(param(mod))[names(theta)]
```

    ##   DENCL   DENVC DENVMAX   DENVP    <NA> 
    ##    2.75 2340.00 3110.00 1324.00      NA
