`simpar` and inverse Chi-square distribution
============================================

    if(!require(metrumrg)) stop("Install metrumrg package first.")

    library(mrgsolve)
    library(dplyr)
    library(tidyr)
    library(readr)
    library(ggplot2)
    library(parallel)
    library(magrittr)
    source("src/functions.R")
    knitr::opts_chunk$set(comment='.')

Take iteration `-1E9` to get the "estimate"

    est <- read.csv("nonmem/1001/1001.ext", header=TRUE, skip=1, sep="") %>%
      filter(ITERATION == -1E9)

Go into the `run.cov` file to get the covariance matrix

    .cov <- read.csv("nonmem/1001/1001.cov", header=TRUE, skip=1, sep="")
    .cov$NAME <- NULL

We only want the covariance matrix for `THETAs`; we'll handle `OMEGA`
and `SIGMA` separately

    take <- grep("THETA",names(.cov))
    cov <- .cov[take,take]

`THETA`

    theta <- est[grepl("THETA",names(est))]

`OMEGA`

    omega <- as_bmat(est,"OMEGA")[[1]]

`SIGMA`

We'll change `SIGMA` around a bit; make it a single porportional error
variance

    sigma <- matrix(0.028)

    simpost <- metrumrg::simpar(n=1500,
                                theta=unlist(theta),
                                cov=cov,
                                omega=omega,
                                sigma=sigma) %>% data.frame

Some really big values for SG1.1

    summary(simpost[,"SG1.1"])

    .      Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
    .      0.00      0.02      0.07    163.50      0.31 202100.00

When `SIGMA` is 1x1 matrix, we use inverse chi-square (`?rinvchisq`)
distribution to simulate. When `SIGMA` is 2x2 (or more, we use inverse
Wishart)

Check `metrumrg::simblock`, which simulates random effect variances

    metrumrg::simblock

    . function (n, df, cov) 
    . {
    .     if (df < length(cov)) 
    .         stop("df is less than matrix length")
    .     if (length(cov) == 1) 
    .         return(rinvchisq(n, df, cov))
    .     s <- dim(cov)[1]
    .     ncols <- s * (s + 1)/2
    .     res <- matrix(nrow = n, ncol = ncols)
    .     for (i in 1:n) res[i, ] <- half(posmat(riwish(s, df - s + 
    .         1, df * cov)))
    .     res
    . }
    . <environment: namespace:metrumrg>

    metrumrg::rinvchisq

    . function (n, df, cov) 
    . df * cov/rchisq(n, df)
    . <environment: namespace:metrumrg>

By default, `simpar` uses degrees of freedom equal to the length of
`SIGMA`

    length(sigma)

    . [1] 1

In this case, it is 1 ... so simulated values can be all over the place.
Quick sensitivity analysis with `simblock` / `rinvchisq`

    df <- c(1,3,10,30,100,300)
    n <- 10000

    sim <- lapply(df,rinvchisq, n=n,cov=sigma)

    sims <- lapply(sim,function(x) {
        data_frame(min=min(x), median=median(x), mean=mean(x), max=max(x),sd=sd(x))
    })

    sims <- bind_rows(sims) %>% mutate(df=df)

    sims

    . # A tibble: 6 × 6
    .           min     median         mean          max           sd    df
    .         <dbl>      <dbl>        <dbl>        <dbl>        <dbl> <dbl>
    . 1 0.001474452 0.06186630 970.81843679 4.325418e+06 5.803142e+04     1
    . 2 0.004033191 0.03543162   0.09350774 3.412455e+01 6.302146e-01     3
    . 3 0.007401217 0.03007637   0.03481881 2.953080e-01 1.920555e-02    10
    . 4 0.012794978 0.02860721   0.02991510 9.308737e-02 8.298091e-03    30
    . 5 0.017236294 0.02809287   0.02848742 5.095973e-02 4.133225e-03   100
    . 6 0.019946725 0.02801709   0.02817872 4.016431e-02 2.344304e-03   300
