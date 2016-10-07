library(mrgsolve)
library(rbenchmark)
library(dplyr)

##' Daily dosing for 3 months
mod <- mread("pk1cmt",modlib(), end=2135, delta=1, atol=1E-100)
e <- ev(amt=1000, ii=24, addl=89)
a <- system.time(out <- mrgsim(mod,events=e,obsonly=TRUE,recsort=2))

##' Same run, but using a slightly quicker program
evmat <- recmatrix(e, stime(mod))
b <- system.time(outt <- qsim(mod,evmat))

a/b

identical(as.matrix(out),as.matrix(outt))


##' Add idata set
data(exidata)
exidata

##' 1000 ID
id <- lapply(1:100,function(i) exidata) %>% bind_rows

##' Quick sim?
q <- system.time(out <- qsim(mod,evmat,id))
dim(out) 
head(out)

##' Not as fast, but not by much
m <- system.time(out <- mrgsim(mod,ev=e,idata=id,obsonly=TRUE))
dim(out)

q/m


