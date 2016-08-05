
.libPaths("lib")
library(mrgsolve)
library(doParallel)
library(parallel)
library(dplyr)
library(doRNG)


code <- '
$PARAM CL=1, VC=1
$OMEGA 
labels="ET"
1
$CAPTURE ET

'
mod <- mcode("test",code)

mod %>% mrgsim


cl <- makeCluster(4); registerDoParallel(cl)

clusterCall(cl, function() {
  .libPaths("lib"); library(mrgsolve); library(dplyr)
})


set.seed(1010)

out <- foreach(i=1:10) %dorng% {
  loadso(mod)
  mod %>% mrgsim %>% as.tbl
} %>% bind_rows


out

set.seed(1010)
out <- foreach(i=1:10) %dorng% {
  loadso(mod)
  mod %>% mrgsim %>% as.tbl
} %>% bind_rows


out


## Here is the mrgsolve:::house() example
out <- foreach(i=1:10) %dorng% {
  mod <- mrgsolve:::house() %>% ev(amt=100)
  mod %>% mrgsim %>% as.tbl
} %>% bind_rows


out

set.seed(1010)
out <- foreach(i=1:10) %dorng% {
  mod <- mrgsolve:::house() %>% ev(amt=100)
  mod %>% mrgsim %>% as.tbl
} %>% bind_rows


out


stopCluster(cl)
