``` r
library(dplyr)
library(mrgsolve)
library(magrittr)
library(ggplot2)
```

Get time-after-dose in simulated output
=======================================

-   Argument to `mrgsim`: `tad = TRUE`

Some considerations
-------------------

-   We are keeping track of time of last dose (`TOLD`) as the simulation proceeds
-   `TOLD` is not currently being made available to use in model code
-   **QUESTION** Would it be useful to pass `TOLD` back to the user (for example in `$MAIN` or `$TABLE`)?
-   An error is generated if `tad` is found in `$CAPTURE`

Load a model
------------

-   And we'll increase the volume to get some accumulation

``` r
mod <- mread("pk1cmt", modlib(),quiet=TRUE) %>% param(VC = 50)
```

Simulate with `tad=TRUE`

``` r
out <- 
  mod %>% 
  ev(amt=100,ii=24,addl=9) %>% Req(CP) %>%
  mrgsim(tad=TRUE,end=240, delta=0.5, digits=3) 
```

``` r
head(out)
```

    . Model:  pk1cmt

    .   ID time tad    CP
    . 1  1  0.0 0.0 0.000
    . 2  1  0.0 0.0 0.000
    . 3  1  0.5 0.5 0.783
    . 4  1  1.0 1.0 1.250
    . 5  1  1.5 1.5 1.530
    . 6  1  2.0 2.0 1.680

``` r
tail(out)
```

    . Model:  pk1cmt

    .     ID  time  tad   CP
    . 477  1 237.5 21.5 3.45
    . 478  1 238.0 22.0 3.42
    . 479  1 238.5 22.5 3.39
    . 480  1 239.0 23.0 3.35
    . 481  1 239.5 23.5 3.32
    . 482  1 240.0 24.0 3.29

``` r
unique(out$tad)
```

    .  [1]  0.0  0.5  1.0  1.5  2.0  2.5  3.0  3.5  4.0  4.5  5.0  5.5  6.0  6.5
    . [15]  7.0  7.5  8.0  8.5  9.0  9.5 10.0 10.5 11.0 11.5 12.0 12.5 13.0 13.5
    . [29] 14.0 14.5 15.0 15.5 16.0 16.5 17.0 17.5 18.0 18.5 19.0 19.5 20.0 20.5
    . [43] 21.0 21.5 22.0 22.5 23.0 23.5 24.0

Mark the dose number

``` r
out %<>% mutate(dosen = 1+(time-tad)/24)
```

Plot

``` r
ggplot(out, aes(tad,CP,col=factor(dosen))) + 
  geom_line(lwd=1)
```

![](img/auto_tad-unnamed-chunk-9-1.png)
