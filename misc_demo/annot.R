##' ---
##' output: 
##'   md_document:
##'     variant: markdown_github
##' ---


##' 
##' # Annotated model specification
##' 
##' A recent addition to the development version of `mrgsolve` allows 
##' users to add annotation to their model specification.  For each parameter
##' or compartment element in the model, users can add a description of that element, 
##' a unit, and as well as other parsed tags for that element.  Annotations can be added 
##' to the following blocks: `$PARAM`, `$FIXED`, and `$THETA` to annotate parameters 
##' and `$CMT`, `$INIT`, and `$VCMT` to annotate compartments.
##' 
##' ## For example
##' 
##' An annotated `$PARAM` block might look like
##'  
#+ eval=FALSE
$PARAM >> annotated = TRUE

CL   : 1.25 : Clearance (L/hr) [PK]
VC   : 20.8 : Volume of distribution (L) [PK]
EMAX : 33   : Maximum effect (.) [PD]

##' 
##' Note that we have specified `>> annotated = TRUE` ... to tell `mrgsolve` to parse
##' this as an annotated block.  The `>>` indicates that the following text is to be parsed
##' as `name = value` options for the block.  
##' 
##' This block annotates 3 parameters: `CL`, `VC` and `EMAX` with values `1.25 L/hr`, `20.8 L`, and `33`,
##' respectively. `CL` and `VC` are "PK" parameters and `EMAX` is a "PD" parameter.  The pattern for the annotation is:
##' `name : value : description (unit) [other tags]`.  
##' 
##' ## Another example
##' 
##' Similarly, compartment blocks can be annotated like this:
#+ eval=FALSE
$CMT >> annotated = TRUE
GUT  : Dosing compartment (mg)
CENT : Central compartment (mg) 
RESP : Response (units)

##' 
##' Here, the pattern is `name : description (unit)` because the `value` for `$CMT` is assumed to be zero.
##' 
##' Again, notice that we have added the `>> annotated = TRUE` option to this block.
##' 
##' ## Model annotations are parsed and made available as an `R` object
##' 
##' 
##' If we compile the two blocks above we get
#+ message=FALSE

library(mrgsolve)
options(mrgsolve_mread_quiet=TRUE)
code <- '
$PARAM >> annotated  = TRUE

CL   : 1.25 : Clearance (L/hr) [PK]
VC   : 20.8 : Volume of distribution (L) [PK]
EMAX : 33   : Maximum effect (.) [PD]

$CMT >> annotated = TRUE
GUT  : Dosing compartment (mg)
CENT : Central compartment (mg) 
RESP : Response (units)
'
#+
mod <- mcode("annot", code)


##' 
##' Parameter list and compartments as usual
##' 
param(mod)

#+ 
init(mod)


##'
##' We can retreive the model annotations like this
##' 
##' 
mrgsolve:::details(mod) 
#+
list.files(soloc(mod))
