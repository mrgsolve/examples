[PROB]
A plain old model. 
Let's turn this into annotated model.

[SET] delta = 0.1, end=48

[PARAM] CL = 1, V = 2, KA = 3

[FIXED]  F1 = 0.8

[THETA]
1.1 0.32 5

[CMT] GUT 

[INIT] CENT = 10

[OMEGA]
@cor @labels ECL EV
1 0.9 3

[MAIN]
double CLi = CL*exp(ECL);
double Vi  = V*exp(EV);
double KAi = KA;
F_GUT      = F1;

[PKMODEL] ncmt=1, depot=TRUE

[TABLE]
double DV = CENT/V;

[CAPTURE] DV


