#include "lib.h"
#include "dev.h"
#include <RcppArmadillo.h>

using namespace quanteda;

static const double epsilon = 0.000000001; // the same value as R code

inline std::vector<double> to_vector(const arma::sp_mat& mt) {
    return arma::conv_to< std::vector<double> >::from(arma::mat(mt));
}

inline std::vector<double> to_vector(const arma::rowvec& v) {
    return arma::conv_to< std::vector<double> >::from(v);
}

inline double yates_correction(
        const double &a,
        const double &b,
        const double &c,
        const double &d
) {
    double N = a + b + c + d;
    if (std::abs(a *  d - b * c) >= N / 2
         && ((a + b) * (a + c) / N < 5
          || (a + b) * (b + d) / N < 5
          || (a + c) * (c + d) / N < 5
          || (c + d) * (b + d) / N < 5
        )
    ) {
        return 0.5;
    } else {
        return 0.0;
    }
}

inline double williams_correction(
        const double &a,
        const double &b,
        const double &c,
        const double &d
) {
    if (a * b * c * d == 0) return 1.0;
    double N = a + b + c + d;
    return 1.0 + (N / (a + b) + N / (c + d) - 1.0) * (N / (a + c) + N / (b + d) - 1.0) / (6.0 * N);
}

inline double chisq_lambda(
        const double &a,
        const double &b,
        const std::vector<double> &mrg,
        const std::string &cor
) {
    double tN = mrg[0];
    double rN = mrg[1];
    double c = tN - a, d = rN - b, N = a + b + c + d, E = (a + b) * (a + c) / N;
    double delta = (cor == "default" || cor == "yates") ? yates_correction(a, b, c, d) : 0.0;
    double q = (cor == "williams") ? williams_correction(a, b, c, d) : 1.0;
    double num = N * std::pow(std::abs((a * d) - (b * c)) - (N * delta), 2.0);
    double den = (a + b) * (c + d) * (a + c) * (b + d) * (a > E ? 1.0 : -1.0) / q;
    return num / den;
}

inline double lr_lambda(
        const double &a,
        const double &b,
        const std::vector<double> &mrg,
        const std::string &cor
) {
    double tN = mrg[0];
    double rN = mrg[1];
    double c = tN - a, d = rN - b, N = a + b + c + d, E = (a + b) * (a + c) / N;
    double aa = a, bb = b, cc = c , dd = d;

    if (cor == "default" || cor == "yates") {
        double delta = yates_correction(a, b, c, d);
        bool sign = a * d - b * c > 0;
        aa += sign ? -delta : delta;
        bb += sign ? delta : -delta;
        cc += sign ? delta : -delta;
        dd += sign ? -delta : delta;
    }

    double res = (2 * (
        aa * std::log(aa / ((aa + bb) * (aa + cc) / N) + epsilon) +
            bb * std::log(bb / ((aa + bb) * (bb + dd) / N) + epsilon) +
            cc * std::log(cc / ((aa + cc) * (cc + dd) / N) + epsilon) +
            dd * std::log(dd / ((bb + dd) * (cc + dd) / N) + epsilon)
    )) * (a > E ? 1.0 : -1.0);

    if (cor == "williams")
        res /= williams_correction(a, b, c, d);
    return res;
}

inline double pmi_lambda(
        const double &a,
        const double &b,
        const std::vector<double> &mrg,
        const bool normal = false
) {

    const double tN = mrg[0];
    const double rN = mrg[1];
    double c = tN - a, d = rN - b, N = a + b + c + d, E = (a + b) * (a + c) / N;
    double res = std::log(a / E + epsilon);
    if (normal)
        res *= (a > E ? 1.0 : -1.0) / (std::log(a / N) * -1.0);
    return res;

}

// [[Rcpp::export]]
Rcpp::NumericVector cpp_keyness(arma::sp_mat &mt,
                                const std::string measure,
                                const std::string correct,
                                const int thread = -1) {

    if (mt.n_rows != 2)
        throw std::range_error("Invalid DFM object");

    std::size_t I = mt.n_cols;
    std::vector<double> margin = to_vector(arma::sum(mt, 1));
    std::vector<double> row0 = to_vector(mt.row(0));
    std::vector<double> row1 = to_vector(mt.row(1));
    DoubleParams stats(mt.n_cols);

#if QUANTEDA_USE_TBB
    tbb::task_arena arena(thread);
    arena.execute([&]{
        tbb::parallel_for(tbb::blocked_range<int>(0, I), [&](tbb::blocked_range<int> r) {
            if (measure == "chi2") {
                for (int i = r.begin(); i < r.end(); ++i) {
                    stats[i] = chisq_lambda(row0[i], row1[i], margin, correct);
                }
            } else if (measure == "lr") {
                for (int i = r.begin(); i < r.end(); ++i) {
                    stats[i] = lr_lambda(row0[i], row1[i], margin, correct);
                }
            } else if (measure == "pmi") {
                for (int i = r.begin(); i < r.end(); ++i) {
                    stats[i] = pmi_lambda(row0[i], row1[i], margin, false);
                }
            }
        });
    });
#else
    if (measure == "chi2") {
        for (std::size_t i = 0; i < I; i++) {
            stats[i] = chisq_lambda(row0[i], row1[i], margin, correct);
        }
    } else if (measure == "lr") {
        for (std::size_t i = 0; i < I; i++) {
            stats[i] = lr_lambda(row0[i], row1[i], margin, correct);
        }
    } else if (measure == "pmi") {
        for (std::size_t i = 0; i < I; i++) {
            stats[i] = pmi_lambda(row0[i], row1[i], margin, false);
        }
    }
#endif

    return Rcpp::wrap(stats);
}
