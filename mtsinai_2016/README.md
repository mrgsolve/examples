## Comparing the Performance of Four Open-Source Methods for Multiple Parameter Estimation in a Systems Pharmacology Model

Find the poster [here](http://metrumrg.com/wp-content/uploads/2017/06/Eudy_MtSinai_poster_06.2016.pdf)

Example code:

* Fit with `newuoa` and `optim`: [den_newuoa_NM.md](den_newuoa_NM.md)
* Fit with `DEoptim`: [den_DEoptim.md](den_DEoptim.md)
* Fit with `MCMCpack`: [den_mcmc.md](den_mcmc.md)



`mrgsolve` model code:


```cpp
 
$GLOBAL
#define DMABCP (DENCENT/DENVC)
#define DENMOL (DENCENT/DENVC/150000)*1000*1000
#define DENCLNL (DENVMAX/(DENKM+DMABCP))
  
$PARAM
  DENVMAX = 3110
  DENKM = 188
  DENVC = 2340
  DENVP = 1324  
  DENCL = 2.75
  
$FIXED
  DENQ = 18.67 
  DENKA = 0.00592
  DENF = 0.72

$CMT DENSC DENCENT DENPER
  
$MAIN F_DENSC=DENF;
  
$ODE
  dxdt_DENSC =  -DENKA*DENSC;
  dxdt_DENCENT = DENKA*DENSC + DENQ*DENPER/DENVP - (DENQ+DENCL+DENCLNL)*DENCENT/DENVC ;
  dxdt_DENPER =  DENQ*DENCENT/DENVC - DENQ*DENPER/DENVP;
  
$SIGMA 0.0449
  
$TABLE
  double DENCP   = (DENCENT/DENVC/150000)*1000;
  double DENmMOL = DENCP*(1+EPS(1)) ;
  
   
$CAPTURE DENmMOL DENCP
```
