Annotated model specification
=============================

A recent addition to the development version of `mrgsolve` allows users to add annotation to their model specification. For each parameter or compartment element in the model, users can add a description of that element, a unit, and as well as other parsed tags for that element. Annotations can be added to the following blocks: `$PARAM`, `$FIXED`, and `$THETA` to annotate parameters and `$CMT`, `$INIT`, and `$VCMT` to annotate compartments.

For example
-----------

An annotated `$PARAM` block might look like

``` r
$PARAM >> annotated = TRUE

CL   : 1.25 : Clearance (L/hr) [PK]
VC   : 20.8 : Volume of distribution (L) [PK]
EMAX : 33   : Maximum effect (.) [PD]
```

Note that we have specified `>> annotated = TRUE` ... to tell `mrgsolve` to parse this as an annotated block. The `>>` indicates that the following text is to be parsed as `name = value` options for the block.

This block annotates 3 parameters: `CL`, `VC` and `EMAX` with values `1.25 L/hr`, `20.8 L`, and `33`, respectively. `CL` and `VC` are "PK" parameters and `EMAX` is a "PD" parameter. The pattern for the annotation is: `name : value : description (unit) [other tags]`.

Another example
---------------

Similarly, compartment blocks can be annotated like this:

``` r
$CMT >> annotated = TRUE
GUT  : Dosing compartment (mg)
CENT : Central compartment (mg) 
RESP : Response (units)
```

Here, the pattern is `name : description (unit)` because the `value` for `$CMT` is assumed to be zero.

Again, notice that we have added the `>> annotated = TRUE` option to this block.

Model annotations are parsed and made available as an `R` object
----------------------------------------------------------------

If we compile the two blocks above we get

``` r
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
```

``` r
mod <- mcode("annot", code)
```

Parameter list and compartments as usual

``` r
param(mod)
```

    ## 
    ##  Model parameters (N=3):
    ##  name value . name value
    ##  CL   1.25  | VC   20.8 
    ##  EMAX 33    | .    .

``` r
init(mod)
```

    ## 
    ##  Model initial conditions (N=3):
    ##  name       value . name       value
    ##  CENT (2)   0     | RESP (3)   0    
    ##  GUT (1)    0     | . ...      .

We can retreive the model annotations like this

``` r
mrgsolve:::details(mod) 
```

    ## [[1]]
    ##   block name                  descr unit options
    ## 1 PARAM   CL              Clearance L/hr      PK
    ## 2 PARAM   VC Volume of distribution    L      PK
    ## 3 PARAM EMAX         Maximum effect    .      PD
    ## 
    ## [[2]]
    ##   block name               descr  unit options
    ## 1   CMT  GUT  Dosing compartment    mg       .
    ## 2   CMT CENT Central compartment    mg       .
    ## 3   CMT RESP            Response units       .

Details from `mrgsolve:::house()`
=================================

``` r
mod <- mrgsolve:::house()

mrgsolve:::details(mod) %>% (dplyr::bind_rows)
```

    ##      block  name                    descr     unit options
    ## 1    PARAM    CL                Clearance     L/hr       .
    ## 2    PARAM    VC   Volume of distribution        L       .
    ## 3    PARAM    KA Absorption rate constant     1/hr       .
    ## 4    PARAM    F1 Bioavailability fraction        .       .
    ## 5    PARAM    WT                   Weight       kg       .
    ## 6    PARAM   SEX     Covariate female sex        .       .
    ## 7    PARAM  WTCL        Exponent WT on CL        .       .
    ## 8    PARAM  WTVC        Exponent WT on VC        .       .
    ## 9    PARAM SEXCL    Prop cov effect on CL        .       .
    ## 10   PARAM SEXVC    Prop cov effect on VC        .       .
    ## 11   PARAM   KIN  Resp prod rate constant     1/hr       .
    ## 12   PARAM  KOUT  Resp elim rate constant     1/hr       .
    ## 13   PARAM  IC50 Conc giving 50% max resp    ng/ml       .
    ## 14     CMT   GUT       Dosing compartment       mg       .
    ## 15     CMT  CENT      Central compartment       mg       .
    ## 16     CMT  RESP                 Response unitless       .
    ## 17 CAPTURE    DV       Dependent variable    ng/ml       .
    ## 18 CAPTURE    CP     Plasma concentration    ng/ml       .

``` r
list.files(soloc(mod))
```

    ## [1] "mrgsolve.so"
