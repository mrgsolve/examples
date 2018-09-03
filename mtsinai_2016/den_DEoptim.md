den\_DEoptim.R
================
kyleb
Mon Sep 3 15:58:54 2018

``` r
library(mrgsolve)
library(DEoptim)
library(magrittr) 
library(dplyr)
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

Returns the value of objective function

``` r
ols <- function(par,d,n,pred=FALSE) {
  
  par <- setNames(lapply(par,exp),n)
  
  out<- 
    mod %>% 
    param(par) %>%
    data_set(d) %>% 
    Req(DENCP) %>% 
    drop.re %>%
    mrgsim(obsonly=TRUE) %>%
    filter(!is.na(DENCP) & time!=0)
  
  if(pred) return(out)
  
  d %<>% filter(time > 0 & evid==0)
  
  log.yhat <- log(out$DENCP)
  log.y    <- log(d$DENmMOL)
  
  obj <- sum((log.y - log.yhat)^2, na.rm=TRUE)
  
  return(obj)
}
```

Simulate a data set

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

Initial estimates `DEoptim` uses `lower` and `upper`

``` r
theta <- log(c(DENCL=6, DENVC=3000, DENVMAX=1000, DENVP=3000))
upper<-log(c(30,10000,10000,10000))
lower<-log(c(0.001, 0.001, 0.1, 0.1))
```

Fit with `DEoptim::DEoptim`

``` r
fit <- DEoptim(ols,d=d,n = names(theta),
               upper=upper, lower=lower,
               control=list(itermax=300))
```

    ## Iteration: 1 bestvalit: 385.880712 bestmemit:    1.192689    5.158434    0.578591    7.209640
    ## Iteration: 2 bestvalit: 97.606776 bestmemit:    0.224142    8.751962    8.478294    2.106225
    ## Iteration: 3 bestvalit: 97.606776 bestmemit:    0.224142    8.751962    8.478294    2.106225
    ## Iteration: 4 bestvalit: 97.606776 bestmemit:    0.224142    8.751962    8.478294    2.106225
    ## Iteration: 5 bestvalit: 97.606776 bestmemit:    0.224142    8.751962    8.478294    2.106225
    ## Iteration: 6 bestvalit: 97.606776 bestmemit:    0.224142    8.751962    8.478294    2.106225
    ## Iteration: 7 bestvalit: 97.606776 bestmemit:    0.224142    8.751962    8.478294    2.106225
    ## Iteration: 8 bestvalit: 97.606776 bestmemit:    0.224142    8.751962    8.478294    2.106225
    ## Iteration: 9 bestvalit: 97.606776 bestmemit:    0.224142    8.751962    8.478294    2.106225
    ## Iteration: 10 bestvalit: 97.606776 bestmemit:    0.224142    8.751962    8.478294    2.106225
    ## Iteration: 11 bestvalit: 86.414769 bestmemit:    1.129013   -4.197826    8.689614    8.390206
    ## Iteration: 12 bestvalit: 58.604712 bestmemit:    1.181842    7.815107    7.333771    5.396649
    ## Iteration: 13 bestvalit: 58.604712 bestmemit:    1.181842    7.815107    7.333771    5.396649
    ## Iteration: 14 bestvalit: 58.604712 bestmemit:    1.181842    7.815107    7.333771    5.396649
    ## Iteration: 15 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 16 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 17 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 18 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 19 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 20 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 21 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 22 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 23 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 24 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 25 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 26 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 27 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 28 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 29 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 30 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 31 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 32 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 33 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 34 bestvalit: 11.903587 bestmemit:    0.874818    7.934127    7.868615    5.289047
    ## Iteration: 35 bestvalit: 7.840963 bestmemit:    0.934570    8.029966    7.873285    4.340293
    ## Iteration: 36 bestvalit: 7.840963 bestmemit:    0.934570    8.029966    7.873285    4.340293
    ## Iteration: 37 bestvalit: 7.840963 bestmemit:    0.934570    8.029966    7.873285    4.340293
    ## Iteration: 38 bestvalit: 7.840963 bestmemit:    0.934570    8.029966    7.873285    4.340293
    ## Iteration: 39 bestvalit: 7.840963 bestmemit:    0.934570    8.029966    7.873285    4.340293
    ## Iteration: 40 bestvalit: 7.840963 bestmemit:    0.934570    8.029966    7.873285    4.340293
    ## Iteration: 41 bestvalit: 7.840963 bestmemit:    0.934570    8.029966    7.873285    4.340293
    ## Iteration: 42 bestvalit: 7.840963 bestmemit:    0.934570    8.029966    7.873285    4.340293
    ## Iteration: 43 bestvalit: 7.840963 bestmemit:    0.934570    8.029966    7.873285    4.340293
    ## Iteration: 44 bestvalit: 7.840963 bestmemit:    0.934570    8.029966    7.873285    4.340293
    ## Iteration: 45 bestvalit: 7.840963 bestmemit:    0.934570    8.029966    7.873285    4.340293
    ## Iteration: 46 bestvalit: 7.840963 bestmemit:    0.934570    8.029966    7.873285    4.340293
    ## Iteration: 47 bestvalit: 7.840963 bestmemit:    0.934570    8.029966    7.873285    4.340293
    ## Iteration: 48 bestvalit: 7.840963 bestmemit:    0.934570    8.029966    7.873285    4.340293
    ## Iteration: 49 bestvalit: 7.840963 bestmemit:    0.934570    8.029966    7.873285    4.340293
    ## Iteration: 50 bestvalit: 7.840963 bestmemit:    0.934570    8.029966    7.873285    4.340293
    ## Iteration: 51 bestvalit: 7.275763 bestmemit:    1.070780    8.272275    8.037956   -0.688256
    ## Iteration: 52 bestvalit: 7.275763 bestmemit:    1.070780    8.272275    8.037956   -0.688256
    ## Iteration: 53 bestvalit: 7.275763 bestmemit:    1.070780    8.272275    8.037956   -0.688256
    ## Iteration: 54 bestvalit: 6.009014 bestmemit:    1.098595    8.378090    8.103026   -1.878403
    ## Iteration: 55 bestvalit: 6.009014 bestmemit:    1.098595    8.378090    8.103026   -1.878403
    ## Iteration: 56 bestvalit: 6.009014 bestmemit:    1.098595    8.378090    8.103026   -1.878403
    ## Iteration: 57 bestvalit: 6.009014 bestmemit:    1.098595    8.378090    8.103026   -1.878403
    ## Iteration: 58 bestvalit: 6.005405 bestmemit:    1.098595    8.378090    8.103026    0.043428
    ## Iteration: 59 bestvalit: 5.995894 bestmemit:    1.098595    8.378090    8.103026    1.269668
    ## Iteration: 60 bestvalit: 5.995894 bestmemit:    1.098595    8.378090    8.103026    1.269668
    ## Iteration: 61 bestvalit: 5.995894 bestmemit:    1.098595    8.378090    8.103026    1.269668
    ## Iteration: 62 bestvalit: 5.995894 bestmemit:    1.098595    8.378090    8.103026    1.269668
    ## Iteration: 63 bestvalit: 5.995894 bestmemit:    1.098595    8.378090    8.103026    1.269668
    ## Iteration: 64 bestvalit: 5.995894 bestmemit:    1.098595    8.378090    8.103026    1.269668
    ## Iteration: 65 bestvalit: 5.995894 bestmemit:    1.098595    8.378090    8.103026    1.269668
    ## Iteration: 66 bestvalit: 5.995894 bestmemit:    1.098595    8.378090    8.103026    1.269668
    ## Iteration: 67 bestvalit: 5.995894 bestmemit:    1.098595    8.378090    8.103026    1.269668
    ## Iteration: 68 bestvalit: 5.995894 bestmemit:    1.098595    8.378090    8.103026    1.269668
    ## Iteration: 69 bestvalit: 5.995894 bestmemit:    1.098595    8.378090    8.103026    1.269668
    ## Iteration: 70 bestvalit: 5.995894 bestmemit:    1.098595    8.378090    8.103026    1.269668
    ## Iteration: 71 bestvalit: 5.995894 bestmemit:    1.098595    8.378090    8.103026    1.269668
    ## Iteration: 72 bestvalit: 5.164809 bestmemit:    1.099724    8.220400    7.926373    0.713531
    ## Iteration: 73 bestvalit: 5.164809 bestmemit:    1.099724    8.220400    7.926373    0.713531

    ## Warning in log(out$DENCP): NaNs produced

    ## Iteration: 74 bestvalit: 5.164809 bestmemit:    1.099724    8.220400    7.926373    0.713531
    ## Iteration: 75 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 76 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 77 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 78 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 79 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 80 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 81 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 82 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 83 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 84 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 85 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 86 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 87 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 88 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 89 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 90 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 91 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 92 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 93 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 94 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 95 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 96 bestvalit: 4.515973 bestmemit:    1.071866    8.271520    7.991708    2.155853
    ## Iteration: 97 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 98 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 99 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 100 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 101 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 102 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 103 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 104 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 105 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 106 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 107 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 108 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 109 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 110 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 111 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 112 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 113 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 114 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 115 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 116 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 117 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 118 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 119 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 120 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 121 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 122 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 123 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 124 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 125 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 126 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 127 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 128 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 129 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 130 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 131 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 132 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 133 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 134 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 135 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 136 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 137 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 138 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 139 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 140 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 141 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 142 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 143 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 144 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 145 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 146 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 147 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 148 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 149 bestvalit: 3.860807 bestmemit:    1.037889    8.050652    7.928018    6.133253
    ## Iteration: 150 bestvalit: 3.119051 bestmemit:    1.040254    7.908866    8.044615    6.979273
    ## Iteration: 151 bestvalit: 3.119051 bestmemit:    1.040254    7.908866    8.044615    6.979273
    ## Iteration: 152 bestvalit: 3.119051 bestmemit:    1.040254    7.908866    8.044615    6.979273
    ## Iteration: 153 bestvalit: 3.119051 bestmemit:    1.040254    7.908866    8.044615    6.979273
    ## Iteration: 154 bestvalit: 3.119051 bestmemit:    1.040254    7.908866    8.044615    6.979273
    ## Iteration: 155 bestvalit: 3.119051 bestmemit:    1.040254    7.908866    8.044615    6.979273
    ## Iteration: 156 bestvalit: 3.119051 bestmemit:    1.040254    7.908866    8.044615    6.979273
    ## Iteration: 157 bestvalit: 3.119051 bestmemit:    1.040254    7.908866    8.044615    6.979273
    ## Iteration: 158 bestvalit: 3.119051 bestmemit:    1.040254    7.908866    8.044615    6.979273
    ## Iteration: 159 bestvalit: 3.119051 bestmemit:    1.040254    7.908866    8.044615    6.979273
    ## Iteration: 160 bestvalit: 3.119051 bestmemit:    1.040254    7.908866    8.044615    6.979273
    ## Iteration: 161 bestvalit: 3.119051 bestmemit:    1.040254    7.908866    8.044615    6.979273
    ## Iteration: 162 bestvalit: 3.119051 bestmemit:    1.040254    7.908866    8.044615    6.979273
    ## Iteration: 163 bestvalit: 3.047084 bestmemit:    1.040254    7.941147    8.052967    6.979273
    ## Iteration: 164 bestvalit: 3.047084 bestmemit:    1.040254    7.941147    8.052967    6.979273
    ## Iteration: 165 bestvalit: 3.047084 bestmemit:    1.040254    7.941147    8.052967    6.979273
    ## Iteration: 166 bestvalit: 3.047084 bestmemit:    1.040254    7.941147    8.052967    6.979273
    ## Iteration: 167 bestvalit: 3.047084 bestmemit:    1.040254    7.941147    8.052967    6.979273
    ## Iteration: 168 bestvalit: 3.047084 bestmemit:    1.040254    7.941147    8.052967    6.979273
    ## Iteration: 169 bestvalit: 3.047084 bestmemit:    1.040254    7.941147    8.052967    6.979273
    ## Iteration: 170 bestvalit: 3.047084 bestmemit:    1.040254    7.941147    8.052967    6.979273
    ## Iteration: 171 bestvalit: 3.047084 bestmemit:    1.040254    7.941147    8.052967    6.979273
    ## Iteration: 172 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 173 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 174 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 175 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 176 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 177 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 178 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 179 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 180 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 181 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 182 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 183 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 184 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 185 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 186 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 187 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 188 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 189 bestvalit: 3.039149 bestmemit:    1.041646    7.941147    8.052967    6.979273
    ## Iteration: 190 bestvalit: 2.892675 bestmemit:    0.998542    7.821371    8.070528    7.153507
    ## Iteration: 191 bestvalit: 2.892675 bestmemit:    0.998542    7.821371    8.070528    7.153507
    ## Iteration: 192 bestvalit: 2.892675 bestmemit:    0.998542    7.821371    8.070528    7.153507
    ## Iteration: 193 bestvalit: 2.892675 bestmemit:    0.998542    7.821371    8.070528    7.153507
    ## Iteration: 194 bestvalit: 2.892675 bestmemit:    0.998542    7.821371    8.070528    7.153507
    ## Iteration: 195 bestvalit: 2.892675 bestmemit:    0.998542    7.821371    8.070528    7.153507
    ## Iteration: 196 bestvalit: 2.892675 bestmemit:    0.998542    7.821371    8.070528    7.153507
    ## Iteration: 197 bestvalit: 2.892675 bestmemit:    0.998542    7.821371    8.070528    7.153507
    ## Iteration: 198 bestvalit: 2.892675 bestmemit:    0.998542    7.821371    8.070528    7.153507
    ## Iteration: 199 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 200 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 201 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 202 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 203 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 204 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 205 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 206 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 207 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 208 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 209 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 210 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 211 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 212 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 213 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 214 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 215 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 216 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 217 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 218 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 219 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 220 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 221 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 222 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 223 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 224 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 225 bestvalit: 2.694816 bestmemit:    0.994029    7.770788    8.037837    7.134657
    ## Iteration: 226 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 227 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 228 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 229 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 230 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 231 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 232 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 233 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 234 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 235 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 236 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 237 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 238 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 239 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 240 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 241 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 242 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 243 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 244 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 245 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 246 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 247 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 248 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 249 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 250 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 251 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 252 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 253 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 254 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 255 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 256 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 257 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 258 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 259 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 260 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 261 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 262 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 263 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 264 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 265 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 266 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 267 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 268 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 269 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 270 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 271 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 272 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 273 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 274 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 275 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 276 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 277 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 278 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 279 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 280 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 281 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 282 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 283 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 284 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 285 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 286 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 287 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 288 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 289 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 290 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 291 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 292 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 293 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 294 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 295 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 296 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 297 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 298 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 299 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657
    ## Iteration: 300 bestvalit: 2.672278 bestmemit:    0.994029    7.770788    8.035054    7.134657

Results

``` r
exp(fit$optim$bestmem)
```

    ##        par1        par2        par3        par4 
    ##    2.702099 2370.338409 3087.305919 1254.706264

``` r
as.numeric(param(mod))[names(theta)]
```

    ##   DENCL   DENVC DENVMAX   DENVP 
    ##    2.75 2340.00 3110.00 1324.00
