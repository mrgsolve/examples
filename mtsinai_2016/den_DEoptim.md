    library(mrgsolve)
    library(DEoptim)
    library(magrittr) 
    library(dplyr)
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

Returns the value of objective function

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

Simulate a data set

    set.seed(101)
    d <- sim(1,mod,template(mod)) %>% filter(time <= 4032)

Initial estimates `DEoptim` uses `lower` and `upper`

    theta <- log(c(DENCL=6, DENVC=3000, DENVMAX=1000, DENVP=3000))
    upper<-log(c(30,10000,10000,10000))
    lower<-log(c(0.001, 0.001, 0.1, 0.1))

Fit with `DEoptim::DEoptim`

    fit <- DEoptim(ols,d=d,n = names(theta),
                   upper=upper, lower=lower,
                   control=list(itermax=300))

    ## Iteration: 1 bestvalit: 277.031856 bestmemit:   -0.205679    3.556887    8.925739    8.740416
    ## Iteration: 2 bestvalit: 277.031856 bestmemit:   -0.205679    3.556887    8.925739    8.740416
    ## Iteration: 3 bestvalit: 277.031856 bestmemit:   -0.205679    3.556887    8.925739    8.740416
    ## Iteration: 4 bestvalit: 123.555239 bestmemit:    0.638678   -0.813546    8.114813    7.674558
    ## Iteration: 5 bestvalit: 123.555239 bestmemit:    0.638678   -0.813546    8.114813    7.674558
    ## Iteration: 6 bestvalit: 123.555239 bestmemit:    0.638678   -0.813546    8.114813    7.674558
    ## Iteration: 7 bestvalit: 123.555239 bestmemit:    0.638678   -0.813546    8.114813    7.674558
    ## Iteration: 8 bestvalit: 123.497829 bestmemit:    0.638678   -0.250542    8.114813    7.674558
    ## Iteration: 9 bestvalit: 123.497829 bestmemit:    0.638678   -0.250542    8.114813    7.674558
    ## Iteration: 10 bestvalit: 121.733592 bestmemit:    0.638678    2.418125    8.114813    7.674558
    ## Iteration: 11 bestvalit: 121.733592 bestmemit:    0.638678    2.418125    8.114813    7.674558
    ## Iteration: 12 bestvalit: 121.733592 bestmemit:    0.638678    2.418125    8.114813    7.674558
    ## Iteration: 13 bestvalit: 121.733592 bestmemit:    0.638678    2.418125    8.114813    7.674558
    ## Iteration: 14 bestvalit: 79.038917 bestmemit:    1.245348    8.882097    8.494368    6.451065
    ## Iteration: 15 bestvalit: 79.038917 bestmemit:    1.245348    8.882097    8.494368    6.451065
    ## Iteration: 16 bestvalit: 79.038917 bestmemit:    1.245348    8.882097    8.494368    6.451065
    ## Iteration: 17 bestvalit: 79.038917 bestmemit:    1.245348    8.882097    8.494368    6.451065
    ## Iteration: 18 bestvalit: 79.038917 bestmemit:    1.245348    8.882097    8.494368    6.451065
    ## Iteration: 19 bestvalit: 79.038917 bestmemit:    1.245348    8.882097    8.494368    6.451065
    ## Iteration: 20 bestvalit: 79.038917 bestmemit:    1.245348    8.882097    8.494368    6.451065
    ## Iteration: 21 bestvalit: 79.038917 bestmemit:    1.245348    8.882097    8.494368    6.451065
    ## Iteration: 22 bestvalit: 79.038917 bestmemit:    1.245348    8.882097    8.494368    6.451065
    ## Iteration: 23 bestvalit: 79.038917 bestmemit:    1.245348    8.882097    8.494368    6.451065
    ## Iteration: 24 bestvalit: 79.038917 bestmemit:    1.245348    8.882097    8.494368    6.451065
    ## Iteration: 25 bestvalit: 57.093717 bestmemit:    1.069083    7.043426    7.894130    7.713047
    ## Iteration: 26 bestvalit: 57.093717 bestmemit:    1.069083    7.043426    7.894130    7.713047
    ## Iteration: 27 bestvalit: 57.093717 bestmemit:    1.069083    7.043426    7.894130    7.713047
    ## Iteration: 28 bestvalit: 57.093717 bestmemit:    1.069083    7.043426    7.894130    7.713047
    ## Iteration: 29 bestvalit: 25.027574 bestmemit:    1.244999    8.029365    8.210731    7.272920
    ## Iteration: 30 bestvalit: 25.027574 bestmemit:    1.244999    8.029365    8.210731    7.272920
    ## Iteration: 31 bestvalit: 25.027574 bestmemit:    1.244999    8.029365    8.210731    7.272920
    ## Iteration: 32 bestvalit: 25.027574 bestmemit:    1.244999    8.029365    8.210731    7.272920
    ## Iteration: 33 bestvalit: 25.027574 bestmemit:    1.244999    8.029365    8.210731    7.272920
    ## Iteration: 34 bestvalit: 25.027574 bestmemit:    1.244999    8.029365    8.210731    7.272920
    ## Iteration: 35 bestvalit: 25.027574 bestmemit:    1.244999    8.029365    8.210731    7.272920
    ## Iteration: 36 bestvalit: 25.027574 bestmemit:    1.244999    8.029365    8.210731    7.272920
    ## Iteration: 37 bestvalit: 11.762590 bestmemit:    1.036551    8.029365    8.210731    7.272920
    ## Iteration: 38 bestvalit: 11.762590 bestmemit:    1.036551    8.029365    8.210731    7.272920
    ## Iteration: 39 bestvalit: 11.762590 bestmemit:    1.036551    8.029365    8.210731    7.272920
    ## Iteration: 40 bestvalit: 11.762590 bestmemit:    1.036551    8.029365    8.210731    7.272920
    ## Iteration: 41 bestvalit: 11.762590 bestmemit:    1.036551    8.029365    8.210731    7.272920
    ## Iteration: 42 bestvalit: 11.762590 bestmemit:    1.036551    8.029365    8.210731    7.272920
    ## Iteration: 43 bestvalit: 11.762590 bestmemit:    1.036551    8.029365    8.210731    7.272920
    ## Iteration: 44 bestvalit: 11.762590 bestmemit:    1.036551    8.029365    8.210731    7.272920
    ## Iteration: 45 bestvalit: 11.762590 bestmemit:    1.036551    8.029365    8.210731    7.272920
    ## Iteration: 46 bestvalit: 11.762590 bestmemit:    1.036551    8.029365    8.210731    7.272920
    ## Iteration: 47 bestvalit: 11.762590 bestmemit:    1.036551    8.029365    8.210731    7.272920
    ## Iteration: 48 bestvalit: 11.395417 bestmemit:    1.153460    8.104501    8.132667    7.101012
    ## Iteration: 49 bestvalit: 11.395417 bestmemit:    1.153460    8.104501    8.132667    7.101012
    ## Iteration: 50 bestvalit: 9.508993 bestmemit:    1.069650    8.107232    7.942346    5.960391
    ## Iteration: 51 bestvalit: 9.508993 bestmemit:    1.069650    8.107232    7.942346    5.960391
    ## Iteration: 52 bestvalit: 9.508993 bestmemit:    1.069650    8.107232    7.942346    5.960391
    ## Iteration: 53 bestvalit: 9.508993 bestmemit:    1.069650    8.107232    7.942346    5.960391
    ## Iteration: 54 bestvalit: 9.508993 bestmemit:    1.069650    8.107232    7.942346    5.960391
    ## Iteration: 55 bestvalit: 9.508993 bestmemit:    1.069650    8.107232    7.942346    5.960391
    ## Iteration: 56 bestvalit: 9.508993 bestmemit:    1.069650    8.107232    7.942346    5.960391
    ## Iteration: 57 bestvalit: 9.508993 bestmemit:    1.069650    8.107232    7.942346    5.960391
    ## Iteration: 58 bestvalit: 9.508993 bestmemit:    1.069650    8.107232    7.942346    5.960391
    ## Iteration: 59 bestvalit: 9.508993 bestmemit:    1.069650    8.107232    7.942346    5.960391
    ## Iteration: 60 bestvalit: 7.708713 bestmemit:    1.030052    7.536104    8.033540    7.402499
    ## Iteration: 61 bestvalit: 7.708713 bestmemit:    1.030052    7.536104    8.033540    7.402499
    ## Iteration: 62 bestvalit: 7.708713 bestmemit:    1.030052    7.536104    8.033540    7.402499
    ## Iteration: 63 bestvalit: 7.708713 bestmemit:    1.030052    7.536104    8.033540    7.402499
    ## Iteration: 64 bestvalit: 7.708713 bestmemit:    1.030052    7.536104    8.033540    7.402499
    ## Iteration: 65 bestvalit: 7.708713 bestmemit:    1.030052    7.536104    8.033540    7.402499
    ## Iteration: 66 bestvalit: 7.708713 bestmemit:    1.030052    7.536104    8.033540    7.402499
    ## Iteration: 67 bestvalit: 7.708713 bestmemit:    1.030052    7.536104    8.033540    7.402499
    ## Iteration: 68 bestvalit: 7.708713 bestmemit:    1.030052    7.536104    8.033540    7.402499
    ## Iteration: 69 bestvalit: 6.104735 bestmemit:    1.047339    7.819796    8.163492    7.391017
    ## Iteration: 70 bestvalit: 6.104735 bestmemit:    1.047339    7.819796    8.163492    7.391017
    ## Iteration: 71 bestvalit: 6.104735 bestmemit:    1.047339    7.819796    8.163492    7.391017
    ## Iteration: 72 bestvalit: 6.104735 bestmemit:    1.047339    7.819796    8.163492    7.391017
    ## Iteration: 73 bestvalit: 6.104735 bestmemit:    1.047339    7.819796    8.163492    7.391017
    ## Iteration: 74 bestvalit: 6.104735 bestmemit:    1.047339    7.819796    8.163492    7.391017
    ## Iteration: 75 bestvalit: 6.104735 bestmemit:    1.047339    7.819796    8.163492    7.391017
    ## Iteration: 76 bestvalit: 6.104735 bestmemit:    1.047339    7.819796    8.163492    7.391017
    ## Iteration: 77 bestvalit: 6.104735 bestmemit:    1.047339    7.819796    8.163492    7.391017
    ## Iteration: 78 bestvalit: 6.104735 bestmemit:    1.047339    7.819796    8.163492    7.391017
    ## Iteration: 79 bestvalit: 6.104735 bestmemit:    1.047339    7.819796    8.163492    7.391017
    ## Iteration: 80 bestvalit: 6.104735 bestmemit:    1.047339    7.819796    8.163492    7.391017
    ## Iteration: 81 bestvalit: 6.104735 bestmemit:    1.047339    7.819796    8.163492    7.391017
    ## Iteration: 82 bestvalit: 5.667323 bestmemit:    0.981862    7.613318    8.073620    7.323087
    ## Iteration: 83 bestvalit: 5.667323 bestmemit:    0.981862    7.613318    8.073620    7.323087
    ## Iteration: 84 bestvalit: 5.246667 bestmemit:    0.960422    7.650418    8.060350    7.274715
    ## Iteration: 85 bestvalit: 5.246667 bestmemit:    0.960422    7.650418    8.060350    7.274715
    ## Iteration: 86 bestvalit: 5.246667 bestmemit:    0.960422    7.650418    8.060350    7.274715
    ## Iteration: 87 bestvalit: 5.246667 bestmemit:    0.960422    7.650418    8.060350    7.274715
    ## Iteration: 88 bestvalit: 5.246667 bestmemit:    0.960422    7.650418    8.060350    7.274715
    ## Iteration: 89 bestvalit: 5.246667 bestmemit:    0.960422    7.650418    8.060350    7.274715
    ## Iteration: 90 bestvalit: 5.246667 bestmemit:    0.960422    7.650418    8.060350    7.274715
    ## Iteration: 91 bestvalit: 5.246667 bestmemit:    0.960422    7.650418    8.060350    7.274715
    ## Iteration: 92 bestvalit: 5.246667 bestmemit:    0.960422    7.650418    8.060350    7.274715
    ## Iteration: 93 bestvalit: 5.246667 bestmemit:    0.960422    7.650418    8.060350    7.274715
    ## Iteration: 94 bestvalit: 5.246667 bestmemit:    0.960422    7.650418    8.060350    7.274715
    ## Iteration: 95 bestvalit: 5.214262 bestmemit:    0.995285    7.689950    8.019105    7.204798
    ## Iteration: 96 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 97 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 98 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 99 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 100 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 101 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 102 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 103 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 104 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 105 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 106 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 107 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 108 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 109 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 110 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 111 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 112 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 113 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 114 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 115 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 116 bestvalit: 5.062504 bestmemit:    0.996417    7.671688    8.073620    7.323087
    ## Iteration: 117 bestvalit: 5.041098 bestmemit:    0.982088    7.670332    8.093577    7.336485
    ## Iteration: 118 bestvalit: 5.041098 bestmemit:    0.982088    7.670332    8.093577    7.336485
    ## Iteration: 119 bestvalit: 5.041098 bestmemit:    0.982088    7.670332    8.093577    7.336485
    ## Iteration: 120 bestvalit: 5.011957 bestmemit:    0.999731    7.727665    8.083949    7.288127
    ## Iteration: 121 bestvalit: 5.011957 bestmemit:    0.999731    7.727665    8.083949    7.288127
    ## Iteration: 122 bestvalit: 5.011957 bestmemit:    0.999731    7.727665    8.083949    7.288127
    ## Iteration: 123 bestvalit: 5.011957 bestmemit:    0.999731    7.727665    8.083949    7.288127
    ## Iteration: 124 bestvalit: 4.981765 bestmemit:    1.002085    7.737137    8.078997    7.264144
    ## Iteration: 125 bestvalit: 4.981765 bestmemit:    1.002085    7.737137    8.078997    7.264144
    ## Iteration: 126 bestvalit: 4.981765 bestmemit:    1.002085    7.737137    8.078997    7.264144
    ## Iteration: 127 bestvalit: 4.981765 bestmemit:    1.002085    7.737137    8.078997    7.264144
    ## Iteration: 128 bestvalit: 4.981765 bestmemit:    1.002085    7.737137    8.078997    7.264144
    ## Iteration: 129 bestvalit: 4.981765 bestmemit:    1.002085    7.737137    8.078997    7.264144
    ## Iteration: 130 bestvalit: 4.981765 bestmemit:    1.002085    7.737137    8.078997    7.264144
    ## Iteration: 131 bestvalit: 4.981765 bestmemit:    1.002085    7.737137    8.078997    7.264144
    ## Iteration: 132 bestvalit: 4.981291 bestmemit:    0.999731    7.727665    8.083949    7.275500
    ## Iteration: 133 bestvalit: 4.981291 bestmemit:    0.999731    7.727665    8.083949    7.275500
    ## Iteration: 134 bestvalit: 4.959792 bestmemit:    1.000966    7.708603    8.077574    7.291368
    ## Iteration: 135 bestvalit: 4.959792 bestmemit:    1.000966    7.708603    8.077574    7.291368
    ## Iteration: 136 bestvalit: 4.959792 bestmemit:    1.000966    7.708603    8.077574    7.291368
    ## Iteration: 137 bestvalit: 4.959792 bestmemit:    1.000966    7.708603    8.077574    7.291368
    ## Iteration: 138 bestvalit: 4.959792 bestmemit:    1.000966    7.708603    8.077574    7.291368
    ## Iteration: 139 bestvalit: 4.959792 bestmemit:    1.000966    7.708603    8.077574    7.291368
    ## Iteration: 140 bestvalit: 4.957957 bestmemit:    1.001833    7.714986    8.079684    7.288646
    ## Iteration: 141 bestvalit: 4.957957 bestmemit:    1.001833    7.714986    8.079684    7.288646
    ## Iteration: 142 bestvalit: 4.957957 bestmemit:    1.001833    7.714986    8.079684    7.288646
    ## Iteration: 143 bestvalit: 4.957957 bestmemit:    1.001833    7.714986    8.079684    7.288646
    ## Iteration: 144 bestvalit: 4.957957 bestmemit:    1.001833    7.714986    8.079684    7.288646
    ## Iteration: 145 bestvalit: 4.957957 bestmemit:    1.001833    7.714986    8.079684    7.288646
    ## Iteration: 146 bestvalit: 4.957864 bestmemit:    1.000966    7.709180    8.080313    7.291368
    ## Iteration: 147 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 148 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 149 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 150 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 151 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 152 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 153 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 154 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 155 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 156 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 157 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 158 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 159 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 160 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 161 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 162 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 163 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 164 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 165 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 166 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 167 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 168 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 169 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 170 bestvalit: 4.957413 bestmemit:    1.000966    7.709180    8.078596    7.291368
    ## Iteration: 171 bestvalit: 4.957378 bestmemit:    1.001060    7.709180    8.078596    7.291368
    ## Iteration: 172 bestvalit: 4.957378 bestmemit:    1.001060    7.709180    8.078596    7.291368
    ## Iteration: 173 bestvalit: 4.957378 bestmemit:    1.001060    7.709180    8.078596    7.291368
    ## Iteration: 174 bestvalit: 4.957378 bestmemit:    1.001060    7.709180    8.078596    7.291368
    ## Iteration: 175 bestvalit: 4.957378 bestmemit:    1.001060    7.709180    8.078596    7.291368
    ## Iteration: 176 bestvalit: 4.957378 bestmemit:    1.001060    7.709180    8.078596    7.291368
    ## Iteration: 177 bestvalit: 4.957378 bestmemit:    1.001060    7.709180    8.078596    7.291368
    ## Iteration: 178 bestvalit: 4.957174 bestmemit:    0.998394    7.706212    8.078594    7.289829
    ## Iteration: 179 bestvalit: 4.956925 bestmemit:    1.000048    7.709853    8.082304    7.293685
    ## Iteration: 180 bestvalit: 4.956925 bestmemit:    1.000048    7.709853    8.082304    7.293685
    ## Iteration: 181 bestvalit: 4.956925 bestmemit:    1.000048    7.709853    8.082304    7.293685
    ## Iteration: 182 bestvalit: 4.956925 bestmemit:    1.000048    7.709853    8.082304    7.293685
    ## Iteration: 183 bestvalit: 4.956925 bestmemit:    1.000048    7.709853    8.082304    7.293685
    ## Iteration: 184 bestvalit: 4.956715 bestmemit:    1.001859    7.712517    8.080199    7.290047
    ## Iteration: 185 bestvalit: 4.956715 bestmemit:    1.001859    7.712517    8.080199    7.290047
    ## Iteration: 186 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 187 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 188 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 189 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 190 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 191 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 192 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 193 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 194 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 195 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 196 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 197 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 198 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 199 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 200 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 201 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 202 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 203 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 204 bestvalit: 4.956378 bestmemit:    1.001262    7.712517    8.080199    7.290047
    ## Iteration: 205 bestvalit: 4.956318 bestmemit:    1.000495    7.711938    8.080199    7.290047
    ## Iteration: 206 bestvalit: 4.956234 bestmemit:    0.999986    7.709282    8.079347    7.290190
    ## Iteration: 207 bestvalit: 4.956234 bestmemit:    0.999986    7.709282    8.079347    7.290190
    ## Iteration: 208 bestvalit: 4.956234 bestmemit:    0.999986    7.709282    8.079347    7.290190
    ## Iteration: 209 bestvalit: 4.956234 bestmemit:    0.999986    7.709282    8.079347    7.290190
    ## Iteration: 210 bestvalit: 4.956234 bestmemit:    0.999986    7.709282    8.079347    7.290190
    ## Iteration: 211 bestvalit: 4.956234 bestmemit:    0.999986    7.709282    8.079347    7.290190
    ## Iteration: 212 bestvalit: 4.956196 bestmemit:    1.000495    7.711441    8.080199    7.290047
    ## Iteration: 213 bestvalit: 4.956196 bestmemit:    1.000495    7.711441    8.080199    7.290047
    ## Iteration: 214 bestvalit: 4.956196 bestmemit:    1.000495    7.711441    8.080199    7.290047
    ## Iteration: 215 bestvalit: 4.956196 bestmemit:    1.000495    7.711441    8.080199    7.290047
    ## Iteration: 216 bestvalit: 4.956196 bestmemit:    1.000495    7.711441    8.080199    7.290047
    ## Iteration: 217 bestvalit: 4.956196 bestmemit:    1.000495    7.711441    8.080199    7.290047
    ## Iteration: 218 bestvalit: 4.956196 bestmemit:    1.000495    7.711441    8.080199    7.290047
    ## Iteration: 219 bestvalit: 4.956196 bestmemit:    1.000495    7.711441    8.080199    7.290047
    ## Iteration: 220 bestvalit: 4.956196 bestmemit:    1.000495    7.711441    8.080199    7.290047
    ## Iteration: 221 bestvalit: 4.956180 bestmemit:    1.000120    7.710104    8.080186    7.290822
    ## Iteration: 222 bestvalit: 4.956180 bestmemit:    1.000120    7.710104    8.080186    7.290822
    ## Iteration: 223 bestvalit: 4.956180 bestmemit:    1.000120    7.710104    8.080186    7.290822
    ## Iteration: 224 bestvalit: 4.956180 bestmemit:    1.000120    7.710104    8.080186    7.290822
    ## Iteration: 225 bestvalit: 4.956180 bestmemit:    1.000120    7.710104    8.080186    7.290822
    ## Iteration: 226 bestvalit: 4.956180 bestmemit:    1.000120    7.710104    8.080186    7.290822
    ## Iteration: 227 bestvalit: 4.956180 bestmemit:    1.000120    7.710104    8.080186    7.290822
    ## Iteration: 228 bestvalit: 4.956180 bestmemit:    1.000120    7.710104    8.080186    7.290822
    ## Iteration: 229 bestvalit: 4.956180 bestmemit:    1.000120    7.710104    8.080186    7.290822
    ## Iteration: 230 bestvalit: 4.956180 bestmemit:    1.000120    7.710104    8.080186    7.290822
    ## Iteration: 231 bestvalit: 4.956180 bestmemit:    1.000120    7.710104    8.080186    7.290822
    ## Iteration: 232 bestvalit: 4.956180 bestmemit:    1.000120    7.710104    8.080186    7.290822
    ## Iteration: 233 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 234 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 235 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 236 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 237 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 238 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 239 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 240 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 241 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 242 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 243 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 244 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 245 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 246 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 247 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 248 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 249 bestvalit: 4.956168 bestmemit:    1.000120    7.710166    8.080186    7.290822
    ## Iteration: 250 bestvalit: 4.956161 bestmemit:    1.000046    7.709799    8.080417    7.291586
    ## Iteration: 251 bestvalit: 4.956159 bestmemit:    1.000035    7.709918    8.080382    7.291482
    ## Iteration: 252 bestvalit: 4.956159 bestmemit:    1.000035    7.709918    8.080382    7.291482
    ## Iteration: 253 bestvalit: 4.956159 bestmemit:    1.000035    7.709918    8.080382    7.291482
    ## Iteration: 254 bestvalit: 4.956159 bestmemit:    1.000035    7.709918    8.080382    7.291482
    ## Iteration: 255 bestvalit: 4.956159 bestmemit:    1.000035    7.709918    8.080382    7.291482
    ## Iteration: 256 bestvalit: 4.956156 bestmemit:    1.000093    7.710260    8.079967    7.290543
    ## Iteration: 257 bestvalit: 4.956156 bestmemit:    1.000093    7.710260    8.079967    7.290543
    ## Iteration: 258 bestvalit: 4.956156 bestmemit:    1.000093    7.710260    8.079967    7.290543
    ## Iteration: 259 bestvalit: 4.956156 bestmemit:    1.000093    7.710260    8.079967    7.290543
    ## Iteration: 260 bestvalit: 4.956156 bestmemit:    1.000093    7.710260    8.079967    7.290543
    ## Iteration: 261 bestvalit: 4.956156 bestmemit:    1.000225    7.710475    8.079956    7.290385
    ## Iteration: 262 bestvalit: 4.956152 bestmemit:    1.000280    7.710142    8.080225    7.291205
    ## Iteration: 263 bestvalit: 4.956152 bestmemit:    1.000280    7.710142    8.080225    7.291205
    ## Iteration: 264 bestvalit: 4.956152 bestmemit:    1.000136    7.710132    8.080243    7.291119
    ## Iteration: 265 bestvalit: 4.956152 bestmemit:    1.000136    7.710132    8.080243    7.291119
    ## Iteration: 266 bestvalit: 4.956152 bestmemit:    1.000136    7.710132    8.080243    7.291119
    ## Iteration: 267 bestvalit: 4.956152 bestmemit:    1.000136    7.710132    8.080243    7.291119
    ## Iteration: 268 bestvalit: 4.956152 bestmemit:    1.000136    7.710132    8.080243    7.291119
    ## Iteration: 269 bestvalit: 4.956152 bestmemit:    1.000136    7.710132    8.080243    7.291119
    ## Iteration: 270 bestvalit: 4.956152 bestmemit:    1.000136    7.710132    8.080243    7.291119
    ## Iteration: 271 bestvalit: 4.956152 bestmemit:    1.000136    7.710132    8.080243    7.291119
    ## Iteration: 272 bestvalit: 4.956151 bestmemit:    1.000195    7.710243    8.080025    7.290745
    ## Iteration: 273 bestvalit: 4.956151 bestmemit:    1.000195    7.710243    8.080025    7.290745
    ## Iteration: 274 bestvalit: 4.956151 bestmemit:    1.000195    7.710243    8.080025    7.290745
    ## Iteration: 275 bestvalit: 4.956151 bestmemit:    1.000195    7.710243    8.080025    7.290745
    ## Iteration: 276 bestvalit: 4.956151 bestmemit:    1.000195    7.710243    8.080025    7.290745
    ## Iteration: 277 bestvalit: 4.956151 bestmemit:    1.000195    7.710243    8.080025    7.290745
    ## Iteration: 278 bestvalit: 4.956151 bestmemit:    1.000195    7.710243    8.080025    7.290745
    ## Iteration: 279 bestvalit: 4.956151 bestmemit:    1.000195    7.710243    8.080025    7.290745
    ## Iteration: 280 bestvalit: 4.956151 bestmemit:    1.000195    7.710243    8.080025    7.290745
    ## Iteration: 281 bestvalit: 4.956151 bestmemit:    1.000195    7.710243    8.080025    7.290745
    ## Iteration: 282 bestvalit: 4.956151 bestmemit:    1.000195    7.710243    8.080025    7.290745
    ## Iteration: 283 bestvalit: 4.956151 bestmemit:    1.000195    7.710243    8.080025    7.290745
    ## Iteration: 284 bestvalit: 4.956150 bestmemit:    1.000231    7.710210    8.080146    7.290989
    ## Iteration: 285 bestvalit: 4.956150 bestmemit:    1.000231    7.710210    8.080146    7.290989
    ## Iteration: 286 bestvalit: 4.956150 bestmemit:    1.000231    7.710210    8.080146    7.290989
    ## Iteration: 287 bestvalit: 4.956150 bestmemit:    1.000231    7.710210    8.080146    7.290989
    ## Iteration: 288 bestvalit: 4.956150 bestmemit:    1.000231    7.710210    8.080146    7.290989
    ## Iteration: 289 bestvalit: 4.956150 bestmemit:    1.000217    7.710201    8.080150    7.290985
    ## Iteration: 290 bestvalit: 4.956150 bestmemit:    1.000217    7.710201    8.080150    7.290985
    ## Iteration: 291 bestvalit: 4.956150 bestmemit:    1.000217    7.710201    8.080150    7.290985
    ## Iteration: 292 bestvalit: 4.956150 bestmemit:    1.000206    7.710129    8.080164    7.291086
    ## Iteration: 293 bestvalit: 4.956150 bestmemit:    1.000206    7.710129    8.080164    7.291086
    ## Iteration: 294 bestvalit: 4.956150 bestmemit:    1.000206    7.710129    8.080164    7.291086
    ## Iteration: 295 bestvalit: 4.956150 bestmemit:    1.000206    7.710129    8.080164    7.291086
    ## Iteration: 296 bestvalit: 4.956150 bestmemit:    1.000206    7.710129    8.080164    7.291086
    ## Iteration: 297 bestvalit: 4.956150 bestmemit:    1.000206    7.710129    8.080164    7.291086
    ## Iteration: 298 bestvalit: 4.956150 bestmemit:    1.000206    7.710129    8.080164    7.291086
    ## Iteration: 299 bestvalit: 4.956150 bestmemit:    1.000206    7.710129    8.080164    7.291086
    ## Iteration: 300 bestvalit: 4.956150 bestmemit:    1.000206    7.710129    8.080164    7.291086

Results

    exp(fit$optim$bestmem)

    ##        par1        par2        par3        par4 
    ##    2.718842 2230.830147 3229.761358 1467.163375

    as.numeric(param(mod))[names(theta)]

    ##   DENCL   DENVC DENVMAX   DENVP 
    ##    2.75 2340.00 3110.00 1324.00
