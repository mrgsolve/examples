    library(mrgsolve)
    library(magrittr) 
    library(dplyr)
    library(MCMCpack)
    source("functions.R")

The model

    mod <- mread("denpk", "model")
    param(mod)

    ## 
    ##  Model parameters (N=5):
    ##  name  value . name    value
    ##  DENCL 2.75  | DENVMAX 3110 
    ##  DENKM 188   | DENVP   1324 
    ##  DENVC 2340  | .       .

    init(mod)

    ## 
    ##  Model initial conditions (N=3):
    ##  name          value . name        value
    ##  DENCENT (2)   0     | DENSC (1)   0    
    ##  DENPER (3)    0     | . ...       .

Log prior density without constants:

    nprior <- function(theta,mu=0,tau2=1E-6) {
      -0.5*tau2*(theta-mu)^2
    }
    igprior <- function(theta,a=0.01,b=0.01) {
      -(a+1)*log(theta) - b/theta
    }

Returns log prior + log likelihood

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

Simulate data

    set.seed(101)
    d <- sim(1,mod,template(mod)) %>% filter(time <= 4032)

Initial estimates

    theta <- log(c(DENCL=6,DENVC=3000, DENVMAX=1000, DENVP=3000, sig2=0.1))
    which_pk <- grep("DEN", names(theta))
    which_sig <- grep("sig", names(theta))

Fit with `MCMCpack::MCMCmetrop1R`

    contr <- list(fnscale = -1, trace = 0,  maxit = 1500, parscale = theta)

    fit <- MCMCmetrop1R(fun=mcfun,
                        theta.init = theta,
                        burnin=2000, mcmc=2000,
                        d=d,n=names(theta),
                        optim.method="Nelder",
                        verbose = 100, tune=2,
                        optim.control = contr)

    ## MCMCmetrop1R iteration 1 of 4000 
    ## function value = -1994.92371
    ## theta = 
    ##    1.78810
    ##    8.02417
    ##    6.97610
    ##    8.10815
    ##   -2.16963
    ## Metropolis acceptance rate = 1.00000
    ## 
    ## MCMCmetrop1R iteration 101 of 4000 
    ## function value = -243.21870
    ## theta = 
    ##    1.97338
    ##    8.14424
    ##    6.61981
    ##    7.53677
    ##    1.53071
    ## Metropolis acceptance rate = 0.51485
    ## 
    ## MCMCmetrop1R iteration 201 of 4000 
    ## function value = -236.65006
    ## theta = 
    ##    1.78760
    ##    7.94391
    ##    6.45321
    ##    7.23084
    ##    0.92867
    ## Metropolis acceptance rate = 0.50249
    ## 
    ## MCMCmetrop1R iteration 301 of 4000 
    ## function value = -233.86130
    ## theta = 
    ##    1.35143
    ##    7.32095
    ##    5.91696
    ##    6.58210
    ##    1.16217
    ## Metropolis acceptance rate = 0.46179
    ## 
    ## MCMCmetrop1R iteration 401 of 4000 
    ## function value = -229.92185
    ## theta = 
    ##    1.29300
    ##    7.04903
    ##    6.12829
    ##    6.91049
    ##    1.05521
    ## Metropolis acceptance rate = 0.45387
    ## 
    ## MCMCmetrop1R iteration 501 of 4000 
    ## function value = -230.79782
    ## theta = 
    ##    1.28063
    ##    7.45690
    ##    6.27197
    ##    6.65450
    ##    1.11142
    ## Metropolis acceptance rate = 0.45110
    ## 
    ## MCMCmetrop1R iteration 601 of 4000 
    ## function value = -231.44416
    ## theta = 
    ##    1.21970
    ##    7.31813
    ##    6.03396
    ##    6.42455
    ##    0.89143
    ## Metropolis acceptance rate = 0.43594
    ## 
    ## MCMCmetrop1R iteration 701 of 4000 
    ## function value = -226.88576
    ## theta = 
    ##    1.37789
    ##    7.35801
    ##    6.38183
    ##    6.97682
    ##    1.03291
    ## Metropolis acceptance rate = 0.42083
    ## 
    ## MCMCmetrop1R iteration 801 of 4000 
    ## function value = -224.91869
    ## theta = 
    ##    1.45210
    ##    7.59302
    ##    6.52087
    ##    6.91744
    ##    0.82678
    ## Metropolis acceptance rate = 0.41448
    ## 
    ## MCMCmetrop1R iteration 901 of 4000 
    ## function value = -224.17283
    ## theta = 
    ##    1.37037
    ##    7.37388
    ##    6.47694
    ##    6.94443
    ##    1.11104
    ## Metropolis acceptance rate = 0.41731
    ## 
    ## MCMCmetrop1R iteration 1001 of 4000 
    ## function value = -223.19448
    ## theta = 
    ##    1.18613
    ##    7.18302
    ##    6.37235
    ##    6.77467
    ##    0.79099
    ## Metropolis acceptance rate = 0.40659
    ## 
    ## MCMCmetrop1R iteration 1101 of 4000 
    ## function value = -218.72384
    ## theta = 
    ##    1.22242
    ##    7.35747
    ##    6.42367
    ##    6.52395
    ##    0.76097
    ## Metropolis acceptance rate = 0.40781
    ## 
    ## MCMCmetrop1R iteration 1201 of 4000 
    ## function value = -212.76032
    ## theta = 
    ##    1.26089
    ##    7.33740
    ##    6.62050
    ##    6.77938
    ##    0.77539
    ## Metropolis acceptance rate = 0.40550
    ## 
    ## MCMCmetrop1R iteration 1301 of 4000 
    ## function value = -210.37778
    ## theta = 
    ##    1.28505
    ##    7.28682
    ##    6.68769
    ##    6.90280
    ##    0.64750
    ## Metropolis acceptance rate = 0.40200
    ## 
    ## MCMCmetrop1R iteration 1401 of 4000 
    ## function value = -200.68822
    ## theta = 
    ##    1.27379
    ##    7.51539
    ##    6.84547
    ##    6.64059
    ##    0.60214
    ## Metropolis acceptance rate = 0.40186
    ## 
    ## MCMCmetrop1R iteration 1501 of 4000 
    ## function value = -168.08594
    ## theta = 
    ##    1.16141
    ##    7.38717
    ##    7.20485
    ##    6.86737
    ##    0.16704
    ## Metropolis acceptance rate = 0.40040
    ## 
    ## MCMCmetrop1R iteration 1601 of 4000 
    ## function value = -141.24595
    ## theta = 
    ##    0.86264
    ##    7.11728
    ##    7.27628
    ##    6.77763
    ##   -0.37529
    ## Metropolis acceptance rate = 0.39101
    ## 
    ## MCMCmetrop1R iteration 1701 of 4000 
    ## function value =   11.44198
    ## theta = 
    ##    1.02534
    ##    7.69909
    ##    8.00722
    ##    7.21280
    ##   -2.86036
    ## Metropolis acceptance rate = 0.38918
    ## 
    ## MCMCmetrop1R iteration 1801 of 4000 
    ## function value =   18.49154
    ## theta = 
    ##    0.99395
    ##    7.67779
    ##    8.10614
    ##    7.34799
    ##   -2.96424
    ## Metropolis acceptance rate = 0.37590
    ## 
    ## MCMCmetrop1R iteration 1901 of 4000 
    ## function value =   18.63398
    ## theta = 
    ##    1.01226
    ##    7.70454
    ##    8.05080
    ##    7.25921
    ##   -3.03296
    ## Metropolis acceptance rate = 0.35928
    ## 
    ## MCMCmetrop1R iteration 2001 of 4000 
    ## function value =   15.97851
    ## theta = 
    ##    1.00859
    ##    7.72891
    ##    8.15731
    ##    7.39963
    ##   -3.00456
    ## Metropolis acceptance rate = 0.34683
    ## 
    ## MCMCmetrop1R iteration 2101 of 4000 
    ## function value =   18.81698
    ## theta = 
    ##    1.00054
    ##    7.72217
    ##    8.03491
    ##    7.20710
    ##   -3.04284
    ## Metropolis acceptance rate = 0.33317
    ## 
    ## MCMCmetrop1R iteration 2201 of 4000 
    ## function value =   19.28453
    ## theta = 
    ##    1.01059
    ##    7.75323
    ##    8.05362
    ##    7.20323
    ##   -3.21424
    ## Metropolis acceptance rate = 0.32258
    ## 
    ## MCMCmetrop1R iteration 2301 of 4000 
    ## function value =   19.97572
    ## theta = 
    ##    0.99851
    ##    7.68204
    ##    8.10591
    ##    7.35728
    ##   -3.21222
    ## Metropolis acceptance rate = 0.31247
    ## 
    ## MCMCmetrop1R iteration 2401 of 4000 
    ## function value =   19.97572
    ## theta = 
    ##    0.99851
    ##    7.68204
    ##    8.10591
    ##    7.35728
    ##   -3.21222
    ## Metropolis acceptance rate = 0.29946
    ## 
    ## MCMCmetrop1R iteration 2501 of 4000 
    ## function value =   14.42526
    ## theta = 
    ##    1.02572
    ##    7.75458
    ##    8.04379
    ##    7.21418
    ##   -2.77010
    ## Metropolis acceptance rate = 0.28908
    ## 
    ## MCMCmetrop1R iteration 2601 of 4000 
    ## function value =   19.89124
    ## theta = 
    ##    0.99539
    ##    7.73533
    ##    8.06762
    ##    7.23478
    ##   -3.12079
    ## Metropolis acceptance rate = 0.28028
    ## 
    ## MCMCmetrop1R iteration 2701 of 4000 
    ## function value =   15.84245
    ## theta = 
    ##    0.97193
    ##    7.65152
    ##    8.12988
    ##    7.39891
    ##   -3.30962
    ## Metropolis acceptance rate = 0.27249
    ## 
    ## MCMCmetrop1R iteration 2801 of 4000 
    ## function value =   17.77725
    ## theta = 
    ##    1.01133
    ##    7.69794
    ##    8.12538
    ##    7.37277
    ##   -3.24893
    ## Metropolis acceptance rate = 0.26598
    ## 
    ## MCMCmetrop1R iteration 2901 of 4000 
    ## function value =   15.86419
    ## theta = 
    ##    1.00302
    ##    7.78909
    ##    8.09503
    ##    7.22533
    ##   -2.93941
    ## Metropolis acceptance rate = 0.26129
    ## 
    ## MCMCmetrop1R iteration 3001 of 4000 
    ## function value =   19.65104
    ## theta = 
    ##    1.00048
    ##    7.74981
    ##    8.06789
    ##    7.22784
    ##   -3.07585
    ## Metropolis acceptance rate = 0.25691
    ## 
    ## MCMCmetrop1R iteration 3101 of 4000 
    ## function value =   19.15993
    ## theta = 
    ##    1.00439
    ##    7.73725
    ##    8.10926
    ##    7.32497
    ##   -3.10316
    ## Metropolis acceptance rate = 0.25153
    ## 
    ## MCMCmetrop1R iteration 3201 of 4000 
    ## function value =   20.01397
    ## theta = 
    ##    1.00752
    ##    7.73038
    ##    8.07458
    ##    7.26349
    ##   -3.06373
    ## Metropolis acceptance rate = 0.24555
    ## 
    ## MCMCmetrop1R iteration 3301 of 4000 
    ## function value =   16.77582
    ## theta = 
    ##    1.03457
    ##    7.71676
    ##    8.09521
    ##    7.34560
    ##   -3.19739
    ## Metropolis acceptance rate = 0.24114
    ## 
    ## MCMCmetrop1R iteration 3401 of 4000 
    ## function value =   20.18502
    ## theta = 
    ##    1.00757
    ##    7.73939
    ##    8.08421
    ##    7.27163
    ##   -3.24851
    ## Metropolis acceptance rate = 0.23522
    ## 
    ## MCMCmetrop1R iteration 3501 of 4000 
    ## function value =   19.81054
    ## theta = 
    ##    0.99011
    ##    7.70684
    ##    8.08334
    ##    7.27991
    ##   -3.16490
    ## Metropolis acceptance rate = 0.22908
    ## 
    ## MCMCmetrop1R iteration 3601 of 4000 
    ## function value =   18.89641
    ## theta = 
    ##    0.97791
    ##    7.66010
    ##    8.10384
    ##    7.34639
    ##   -3.18095
    ## Metropolis acceptance rate = 0.22494
    ## 
    ## MCMCmetrop1R iteration 3701 of 4000 
    ## function value =   20.33411
    ## theta = 
    ##    0.99806
    ##    7.71443
    ##    8.09324
    ##    7.30082
    ##   -3.20734
    ## Metropolis acceptance rate = 0.21967
    ## 
    ## MCMCmetrop1R iteration 3801 of 4000 
    ## function value =   15.82300
    ## theta = 
    ##    0.95581
    ##    7.65783
    ##    8.09977
    ##    7.32635
    ##   -3.06071
    ## Metropolis acceptance rate = 0.21626
    ## 
    ## MCMCmetrop1R iteration 3901 of 4000 
    ## function value =   17.34716
    ## theta = 
    ##    0.98215
    ##    7.68362
    ##    8.06501
    ##    7.28252
    ##   -3.42347
    ## Metropolis acceptance rate = 0.21353
    ## 
    ## 
    ## 
    ## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ## The Metropolis acceptance rate was 0.20975
    ## @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

Results

    summary(exp(fit))

    ## 
    ## Iterations = 2001:4000
    ## Thinning interval = 1 
    ## Number of chains = 1 
    ## Sample size per chain = 2000 
    ## 
    ## 1. Empirical mean and standard deviation for each variable,
    ##    plus standard error of the mean:
    ## 
    ##           Mean        SD  Naive SE Time-series SE
    ## [1,] 2.722e+00  0.039367 0.0008803      4.209e-03
    ## [2,] 2.233e+03 73.834567 1.6509911      8.228e+00
    ## [3,] 3.235e+03 89.423079 1.9995608      1.010e+01
    ## [4,] 1.468e+03 81.385804 1.8198419      1.024e+01
    ## [5,] 4.391e-02  0.006035 0.0001349      6.832e-04
    ## 
    ## 2. Quantiles for each variable:
    ## 
    ##           2.5%       25%       50%       75%     97.5%
    ## var1    2.6404 2.706e+00 2.718e+00    2.7419    2.8139
    ## var2 2088.1627 2.172e+03 2.240e+03 2279.9235 2379.7709
    ## var3 3086.8758 3.169e+03 3.240e+03 3313.9797 3420.7981
    ## var4 1330.2953 1.412e+03 1.460e+03 1522.7096 1636.8509
    ## var5    0.0326 4.027e-02 4.315e-02    0.0477    0.0573

    as.numeric(param(mod))[names(theta)]

    ##   DENCL   DENVC DENVMAX   DENVP    <NA> 
    ##    2.75 2340.00 3110.00 1324.00      NA
