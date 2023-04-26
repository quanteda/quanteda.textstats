#include "lib.h"
using namespace quanteda;

#ifdef QUANTEDA
float GLOBAL_PATTERN_MAX_LOAD_FACTOR = 0.05;
float GLOBAL_NGRAMS_MAX_LOAD_FACTOR = 0.25;
#endif

// [[Rcpp::export]]
void qatd_cpp_set_meta(RObject object_, List meta_) {
    object_.attr("meta") = meta_;
}
