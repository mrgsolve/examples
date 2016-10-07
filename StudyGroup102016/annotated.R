library(mrgsolve)

##' The regular model
modd <- mread("model")

modd %>% ev(amt=100, ii=12, addl=3) %>% mrgsim %>% plot


##' The annotated version
mod <- mread("annotated")

mod %>% ev(amt=100, ii=12, addl=3) %>% mrgsim %>% plot

identical(param(mod), param(modd))
identical(init(mod), init(modd))

mod %>% ev(amt=100, ii=12,addl=3) %>% mrgsim(nid=10) %>% plot

##' Extract annotations
mrgsolve:::details(mod)


##' Render into a document
##' Really ... you need the latest from github to do this:
mrgsolve:::render(mod,output_options=list(theme="united"))

