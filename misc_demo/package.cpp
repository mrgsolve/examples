
#include <Rcpp.h>
#include <Rinternals.h>

typedef double user_func(std::vector<double> a);

Rcpp::List pkgfun(SEXP fun_) {
       //Rcpp::NumericVector input_ = Rcpp::as<Rcpp::NumericVector>(input__);
      //user_func* myfun = (user_func*) R_ExternalPtrAddr(fun_);
      //std::vector<double> input = Rcpp::as<std::vector<double> >(input_);
      //double result = myfun(input);
      Rcpp::List ans;
  
      return(ans);
  }
