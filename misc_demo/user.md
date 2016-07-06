A user-defined function
=======================

This uses just `C++` for now.

``` r
user <- '
#include <vector>
#include <numeric>

extern "C" { double myfun(std::vector<double>& a) {
  double b = accumulate(a.begin(), a.end(), 0.0);
    return(b);
  }
}
'
```

Just standard `R` procedure for compiling and loading
-----------------------------------------------------

It seem like you could / should utilize the convenience of `sourceCpp` here. But we need to know the name of the `dll` (see below). I wasn't sure how to do that. So the example just follows the sort of thing I do in `mrgsolve`. A function to build and load the user function

``` r
build <- function(code,stem,func) {
  cpp <- paste0(stem, ".cpp")
  cat(code, file=cpp)
  system(paste("R CMD SHLIB ",cpp))
  dyn.load(paste0(stem, .Platform$dynlib.ext))
  return(getNativeSymbolInfo(func,PACKAGE=stem))
}
```

``` r
x <- build(user,"foo", "myfun")
```

Our dll is loaded

``` r
getLoadedDLLs()
```

    ##                                                                                             Filename
    ## base                                                                                            base
    ## utils             /Library/Frameworks/R.framework/Versions/3.2/Resources/library/utils/libs/utils.so
    ## methods       /Library/Frameworks/R.framework/Versions/3.2/Resources/library/methods/libs/methods.so
    ## grDevices /Library/Frameworks/R.framework/Versions/3.2/Resources/library/grDevices/libs/grDevices.so
    ## graphics    /Library/Frameworks/R.framework/Versions/3.2/Resources/library/graphics/libs/graphics.so
    ## stats             /Library/Frameworks/R.framework/Versions/3.2/Resources/library/stats/libs/stats.so
    ## digest                                                  /Users/kyleb/Rlibs/lib/digest/libs/digest.so
    ## Rcpp                                                        /Users/kyleb/Rlibs/lib/Rcpp/libs/Rcpp.so
    ## htmltools                                         /Users/kyleb/Rlibs/lib/htmltools/libs/htmltools.so
    ## tools             /Library/Frameworks/R.framework/Versions/3.2/Resources/library/tools/libs/tools.so
    ## yaml                                                        /Users/kyleb/Rlibs/lib/yaml/libs/yaml.so
    ## stringi                                               /Users/kyleb/Rlibs/lib/stringi/libs/stringi.so
    ## foo                                                         /Users/kyleb/git/m4solve.git/demo/foo.so
    ##           Dynamic.Lookup
    ## base               FALSE
    ## utils              FALSE
    ## methods            FALSE
    ## grDevices          FALSE
    ## graphics           FALSE
    ## stats              FALSE
    ## digest              TRUE
    ## Rcpp                TRUE
    ## htmltools           TRUE
    ## tools              FALSE
    ## yaml                TRUE
    ## stringi             TRUE
    ## foo                 TRUE

The address of the user-function

``` r
x
```

    ## $name
    ## [1] "myfun"
    ## 
    ## $address
    ## <pointer: 0x1079e4f70>
    ## attr(,"class")
    ## [1] "NativeSymbol"
    ## 
    ## $package
    ## DLL name: foo
    ## Filename: /Users/kyleb/git/m4solve.git/demo/foo.so
    ## Dynamic lookup: TRUE
    ## 
    ## attr(,"class")
    ## [1] "NativeSymbolInfo"

``` r
x$address
```

    ## <pointer: 0x1079e4f70>
    ## attr(,"class")
    ## [1] "NativeSymbol"

The main code base
==================

Now, write the "code base" that will do everything except what the user must supply in the user-defined function . This will take in `x$address` as `SEXP`, use `R_ExternalPtrAddr` to create a pointer to my function.

The following mimics code in an R package. Please use your imagination here. But I think the important thing here is that this large base of code gets compiled once. When different user functions are needed, they will get compiled and then passed into the package.

There is one function called `pkgfun` that does a bunch of cool stuff, but the user needs to supply a function to call.

A "package"
-----------

``` r
library(Rcpp)

package <- '
#include <Rcpp.h>
#include <Rinternals.h>

typedef double user_func(std::vector<double>& a);

// Like the user function, but embedded with the "package"
extern "C" { double house(std::vector<double>& a) {
    double b = accumulate(a.begin(), a.end(), 0.0);
    return(b);
  }
}


//[[Rcpp::export]]
Rcpp::List pkgfun(SEXP fun_,Rcpp::NumericVector input_, Rcpp::NumericVector call) {

  user_func* myfun = (user_func*) R_ExternalPtrAddr(fun_);
  std::vector<double> input = Rcpp::as<std::vector<double> >(input_);
   
  // Call the user-supplied function
  double result = myfun(input);
  
  // if call is 0, use myfun(input); if not, use house(input)
  for(int i=0; i < 30000; i++) {
    result = call[0]==0 ?  myfun(input) : house(input);
  }

  Rcpp::List ans;
  ans["result"] = result;
  return(ans);
}
'
```

Mimics building the package
---------------------------

``` r
sourceCpp(code=package)
```

Use the package
---------------

Generate some input

``` r
set.seed(220201)
a <- rnorm(1000)
```

Call the package code, passing in the user-supplied function

``` r
pkgfun(x$address, a, 0)
```

    ## $result
    ## [1] -30.27183

``` r
sum(a)
```

    ## [1] -30.27183

Another user-supplied function.
-------------------------------

Okay to have another `myfun` around. It will be in a different `so`. But I usually still generate a unique name for this.

``` r
user2 <- '

#include <vector>
#include <numeric>

extern "C" { double myfun(std::vector<double>& a) {
  double b = accumulate(a.begin(), a.end(), 0.0)/double(a.size());
    return(b);
  }
}
'

x2 <- build(user2,"foo2", "myfun")
```

Call the same function in the "package", but with a different user supplied function.

``` r
pkgfun(x2$address,a, 0)
```

    ## $result
    ## [1] -0.03027183

``` r
mean(a)
```

    ## [1] -0.03027183

Benchmark against function "internal" to the package
====================================================

``` r
library(rbenchmark)
```

Get the `house` function in the package We don't **need** to specify the `PACKAGE`; `R` will find it But usually, specify `PACKAGE` to avoid confusion

``` r
h <- getNativeSymbolInfo("house")
```

``` r
benchmark(pkgfun(x$address,a,0),
          pkgfun(h$address,a,0),
          pkgfun(h$address,a,1), 
          replications=1000, 
          columns=c("test", "replications","elapsed", "relative"))
```

    ##                      test replications elapsed relative
    ## 2 pkgfun(h$address, a, 0)         1000  27.105    1.008
    ## 3 pkgfun(h$address, a, 1)         1000  26.901    1.000
    ## 1 pkgfun(x$address, a, 0)         1000  27.761    1.032
