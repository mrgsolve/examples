[PROB]

# An example annotated model

- Author: Kyle Baron, PhWho?
- Client: Pills, Inc
- Project Number: ABC123xyz
- Date: `r date()`
- Parent: `1013.cpp`

[SET] delta = 0.1, end=48

[PARAM] @annotated
CL : 1 : Clearance (L/hr)
V  : 2 : Volume of distribution (L)
KA : 3 : Absorption rate constant (1/hr)

[FIXED]  @annotated
F1 :  0.8 : Bioavailability fraction (.)

[THETA] @annotated
1.1  : Covariate AGE~CL (.)
0.32 : Covariate BMI~CL (.) 
5    : Covariate BMI~V  (.)

[CMT] @annotated
GUT : Dosing compartment (mg)

[INIT] @annotated
CENT : 10 : Central compartment (mg)

[OMEGA] @annotated @cor
ECL : 1     : IIV on CL
EV  : 0.9 3 : IIV on V

[MAIN]
double CLi = CL*exp(ECL);
double Vi  = V*exp(EV);
double KAi = KA;
F_GUT      = F1;

[PKMODEL] ncmt=1, depot=TRUE, trans=11

[TABLE]
double DV = CENT/V;

[CAPTURE] @annotated
DV : Plasma concentration (mg/L)


