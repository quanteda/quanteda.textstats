// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// qatd_cpp_collocations
DataFrame qatd_cpp_collocations(const List& texts_, const CharacterVector& types_, const IntegerVector& words_ignore_, const unsigned int count_min, const IntegerVector sizes_, const String& method, const double smoothing);
RcppExport SEXP _quanteda_textstats_qatd_cpp_collocations(SEXP texts_SEXP, SEXP types_SEXP, SEXP words_ignore_SEXP, SEXP count_minSEXP, SEXP sizes_SEXP, SEXP methodSEXP, SEXP smoothingSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< const List& >::type texts_(texts_SEXP);
    Rcpp::traits::input_parameter< const CharacterVector& >::type types_(types_SEXP);
    Rcpp::traits::input_parameter< const IntegerVector& >::type words_ignore_(words_ignore_SEXP);
    Rcpp::traits::input_parameter< const unsigned int >::type count_min(count_minSEXP);
    Rcpp::traits::input_parameter< const IntegerVector >::type sizes_(sizes_SEXP);
    Rcpp::traits::input_parameter< const String& >::type method(methodSEXP);
    Rcpp::traits::input_parameter< const double >::type smoothing(smoothingSEXP);
    rcpp_result_gen = Rcpp::wrap(qatd_cpp_collocations(texts_, types_, words_ignore_, count_min, sizes_, method, smoothing));
    return rcpp_result_gen;
END_RCPP
}
// qatd_cpp_keyness
Rcpp::NumericVector qatd_cpp_keyness(arma::sp_mat& mt, const std::string measure, const std::string correct);
RcppExport SEXP _quanteda_textstats_qatd_cpp_keyness(SEXP mtSEXP, SEXP measureSEXP, SEXP correctSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< arma::sp_mat& >::type mt(mtSEXP);
    Rcpp::traits::input_parameter< const std::string >::type measure(measureSEXP);
    Rcpp::traits::input_parameter< const std::string >::type correct(correctSEXP);
    rcpp_result_gen = Rcpp::wrap(qatd_cpp_keyness(mt, measure, correct));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_quanteda_textstats_qatd_cpp_collocations", (DL_FUNC) &_quanteda_textstats_qatd_cpp_collocations, 7},
    {"_quanteda_textstats_qatd_cpp_keyness", (DL_FUNC) &_quanteda_textstats_qatd_cpp_keyness, 3},
    {NULL, NULL, 0}
};

RcppExport void R_init_quanteda_textstats(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
