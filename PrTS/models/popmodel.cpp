$PARAM
WT = 70, SEX=0, EGFR=100, BMI = 20, ALT = 0.5
BLACK=0, FORM=1, FBIO=1

$THETA
0.57 1.6 4.34
1.24 -0.078 0.3656 0.4720 0.0216 0.480
-0.0638141 0.79283 4.61 3.82 2.22 0.72 

$CMT GUT CENT  PERIPH

$MAIN

F_GUT = 1;
if(FORM==2) F_GUT = FBIO;

double LTVCL = THETA1 + THETA6 *log(BMI/25) + THETA8 *SEX + THETA7*log(EGFR/100);
double LTVVC = THETA2 + THETA9 *log(BMI/25) + THETA10*SEX;
double LTVVP = THETA3 + THETA11*log(BMI/25);
double LTVQ  = THETA4;
double LTVKA = THETA5;

double CL    = exp(LTVCL + ETA(1));
double VC    = exp(LTVVC);
double KA    = exp(LTVKA + ETA(3));
double Q     = exp(LTVQ );
double VP    = exp(LTVVP + ETA(2));

double E0    = exp(THETA12 + ETA(4));
double EC50  = exp(THETA14);
double EMAX  = exp(THETA13);
double m     = exp(THETA15);

$OMEGA 0 0 0 0
$SIGMA 0 0

$ODE
dxdt_GUT  = -KA*GUT;
dxdt_CENT =  KA*GUT - (CL+Q)*CP + Q*CT;
dxdt_PERIPH = Q*(CP - CT);

$GLOBAL 
double BASE = 0, base=0;
#define CT (PERIPH/VP)
#define CP (CENT/VC)
#define driver CP

$TABLE
double DV = CP*exp(EPS(1));
double IPRED = CENT/VC;

double EFF = E0 - EMAX*pow(driver,m)/(pow(EC50,m)+pow(driver,m));

if(NEWIND <=1) {
  BASE = EFF;
  base = EFF + EPS(2);
}

double dEFF = EFF - BASE;
double deff = EFF - base + EPS(2);

$CAPTURE CL EFF dEFF deff

  