//* MRGSOLVE file
#include "modelheader.h"
#ifndef MODELINCLUDEGUARD
#define INITFUN___ _model_ind__model_main__
#define ODEFUN___ _model_ind__model_ode__
#define TABLECODE___ _model_ind__model_table__
#define _nEQ 2
#define _nPAR 2
#define GUT _A_[0]
#define CENT _A_[1]
#define GUT_0 _A_0_[0]
#define CENT_0 _A_0_[1]
#define dxdt_GUT _DADT_[0]
#define dxdt_CENT _DADT_[1]
#define CL _THETA_[0]
#define VC _THETA_[1]
#define MODELINCLUDEGUARD
#endif

// GLOBAL VARIABLES:


typedef double localdouble;
typedef int localint;
typedef bool localbool;

// MAIN CODE BLOCK:
BEGIN_main
pred_CL = CL;
pred_V = VC;
END_main

// DIFFERENTIAL EQUATIONS:
BEGIN_ode
DXDTZERO();

END_ode

// TABLE CODE BLOCK:
BEGIN_table
table(DV) = CENT/pred_V; 
 
END_table
