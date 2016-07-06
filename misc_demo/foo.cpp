
#include <vector>
#include <numeric>

extern "C" { double myfun(std::vector<double>& a) {
  double b = accumulate(a.begin(), a.end(), 0.0);
    return(b);
  }
}
