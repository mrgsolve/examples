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
                                sigma=matrix(0.026)) %>% data.frame

Some really big values for SG1.1

    summary(simpost[,"SG1.1"])

    .      Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
    .      0.00      0.02      0.06    204.60      0.26 289700.00

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
    . 1 0.001834822 0.06070980 308.03820346 9.499481e+05 1.209999e+04     1
    . 2 0.004580428 0.03489106   0.08405027 1.916500e+01 3.656436e-01     3
    . 3 0.007691071 0.02997820   0.03531946 5.202483e-01 2.102530e-02    10
    . 4 0.011256158 0.02858158   0.02989566 9.809111e-02 8.306302e-03    30
    . 5 0.017416953 0.02826722   0.02861499 4.799660e-02 4.134006e-03   100
    . 6 0.020787387 0.02801129   0.02816523 3.989168e-02 2.315294e-03   300
