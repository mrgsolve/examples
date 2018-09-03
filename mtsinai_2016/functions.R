

##   ID time evid   amt cmt   ii addl dose  DENmMOL irep
## 1  1    0    0 0e+00   0    0    0   10 0.000000    1
## 2  1    0    1 1e+07   1 4032    3   10 0.000000    1
## 3  1   12    0 0e+00   0    0    0   10 1.655885    1
## 4  1   34    0 0e+00   0    0    0   10 3.758968    1
## 5  1  168    0 0e+00   0    0    0   10 5.909730    1
## 6  1  336    0 0e+00   0    0    0   10 6.741199    1
sim <- function(n, mod) {
  data <- expand.ev(amt = c(10,60,210)*1E6, ii = 4032, addl = 3)
  data <- mutate(data, dose = amt)
  x <- c(12,34,seq(0,52,1)*168)
  out <- mrgsim(
    mod, data = data, add = x, end = -1, Req = "DENmMOL",
    carry.out = c("evid", "amt", "cmt", "ii", "addl")
  )
  as_data_frame(out)
  
}

