#include "lib.h"
using namespace quanteda;

// [[Rcpp::export]]
void qatd_cpp_set_meta(RObject object_, List meta_) {
    object_.attr("meta") = meta_;
}
