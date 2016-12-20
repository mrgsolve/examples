[PROB]

# Annotated model
  - Author: Kyle
  - Date: `r date()`
  
```{r,echo=TRUE} 
  mod %>% 
    ev(amt=100, ii=12, addl=3) %>%
    mrgsim %>% plot
```

[SET] delta = 0.1, end=48

[PARAM] @annotated
CL :  1 : Clearance (L/hr)
V  :  2 : Volume of distribution (L)
KA :  3 : Absorption rate constant (1/hr)

[PARAM]
KIN = 100, KOUT = 0.2, EC50 = 10
    
[FIXED]  @annotated
F1 :  0.8 : Bioavability

[THETA] @annotated
1.1  : TVCL
0.32 : Exponent WT ~ CL
5    : TVVC

[CMT] @annotated
GUT : Dosing compartment (mg) 

[INIT] @annotated
CENT :  10 : Central compartment (mg)

[OMEGA] @cor @annotated
ECL : 1 : ETA on CL
EV  : 0.9 3 : ETA on VC
EKA : 0.2 0.4 1 : ETA on KA
    
    
[MAIN]
double CLi = CL*exp(ECL);
double Vi  = V*exp(EV);
double KAi = KA;
F_GUT      = F1;

[PKMODEL] ncmt=1, depot=TRUE

[TABLE]
double DV = CENT/V;

[CAPTURE]  @annotated
DV : Plasma concentration (mg/L)




  



