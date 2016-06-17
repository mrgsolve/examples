

all:
	make NEWNM
	make DE
	make MCMC

NEWNM:
	Rscript den_newuoa_NM.R

DE:
	Rscript den_DEoptim.R

MCMC:
	Rscript den_mcmc.R

render:
	Rscript -e 'library(rmarkdown)' -e 'render("den_newuoa_NM.R"); render("den_DEoptim.R"); render("den_mcmc.R")'




