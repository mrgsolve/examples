stopifnot(require(ggplot2))
.colSet1 <- function(...) scale_color_brewer(palette="Set1",...)
.fillSet1 <- function(...) scale_fill_brewer(palette="Set1",...)


.density <- function(x) {
  x <- density(x)
  with(x,data.frame(x,y))
}

.dsb <- "darkslateblue"

rm.parens <- function(x) {
  x <- gsub("\\(|\\)", "", x)
  x <- gsub(",", '.', x)
  x

}
nfact <- function(x,prefix="", suffix="",pad=TRUE) {
  ux <- sort(unique(x))
  if(pad) return(factor(x,ux, paste(prefix,ux,suffix)))
  return(factor(x,ux, paste0(prefix,ux,suffix)))
}


checkwd <- function(x) {
  if(!file.exists(x)) {
    stop(paste0("Could not find file ", x, "; check working directory"), call.=FALSE)
  }
  stopifnot(file.exists(x))
}

defactor <- function(x,...) UseMethod("defactor")
defactor.data.frame <- function(x,all.char=FALSE, ...) {
  y <- which(sapply(x,is.factor))
  if(all.char) y <- 1:ncol(x)
  for(i in y) {
    x[,i] <- as.character(x[,i])
  }
  return(x)
}
defactor.tbl <- function(x,...) {
  defactor(as.data.frame(x) ,...)
}

geom_ribbon_density <- function(d,filt,fill=NULL) {
  d %<>% filter_(filt)
  geom_ribbon(data=d, aes_string(ymax="y",fill=fill), ymin=0,alpha=0.5)
}


