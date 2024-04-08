#include "lib.h"
#include "dev.h"
#include <bitset>
using namespace quanteda;

#ifdef QUANTEDA
float GLOBAL_PATTERN_MAX_LOAD_FACTOR = 0.05;
float GLOBAL_NGRAMS_MAX_LOAD_FACTOR = 0.25;
#endif

#if QUANTEDA_USE_TBB
#if TBB_VERSION_MAJOR >= 2021
typedef std::atomic<unsigned int> UintAtomic; //oneAPI TBB
#else
typedef tbb::atomic<unsigned int> UintAtomic; //old TBB
#endif
typedef tbb::concurrent_unordered_map<Ngram, std::pair<UintAtomic, UintAtomic>, hash_ngram, equal_ngram> MapNgramsPair;
#else
typedef std::atomic<unsigned int> UintAtomic;
typedef std::unordered_map<Ngram, std::pair<UintAtomic, UintAtomic>, hash_ngram, equal_ngram> MapNgramsPair;
#endif
typedef std::vector<std::pair<Ngram, unsigned int>> VecNgramsPair;

// return the matching pattern between two words at each position, 0 for matching, 1 for not matching.
// for example, for 3-gram, bit = 000, 001, 010 ... 111 eg. 0-7
int match_bit2(const std::vector<unsigned int> &tokens1,
               const std::vector<unsigned int> &tokens2){

    std::size_t len1 = tokens1.size();
    std::size_t len2 = tokens2.size();
    int bit = 0;
    for (std::size_t i = 0; i < len1 && i < len2; i++) {
        if (tokens1[i] == tokens2[i]) bit += std::pow(2, i); // position dependent, bit=0:(2^n-1)
    }
    return bit;
}

// unigram subtuples from B&J algorithm -- lambda1
double sigma_uni2(const std::vector<double> &counts, const std::size_t ntokens){
    double s = 0.0;
    s += std::pow(ntokens - 1, 2) / counts[0];
    for (std::size_t b = 0; b < ntokens; b++) {
        s += 1.0 / counts[std::pow(2, b)];
    }
    s += 1.0 / counts[std::pow(2, ntokens) - 1];
    return std::sqrt(s);
}

double lambda_uni2(const std::vector<double> &counts, const std::size_t ntokens){
    double l = 0.0;
    l += std::log(counts[0]) * (ntokens - 1); // c0
    for (std::size_t b = 0; b < ntokens; b++) {  //c(b), #(b)=1
        l -= std::log(counts[std::pow(2, b)]);
    }
    l += std::log(counts[std::pow(2, ntokens) - 1]); //c(2^n-1)
    return l;
}

// all subtuples from B&J algorithm
double sigma_all2(const std::vector<double> &counts){
    const std::size_t n = counts.size();
    double s = 0.0;

    for (std::size_t b = 0; b < n; b++) {
        s += 1.0 / counts[b];
    }

    return std::sqrt(s);
}

double lambda_all2(const std::vector<double> &counts, const std::size_t ntokens){
    const std::size_t n = counts.size();

    double l = 0.0;

    for (std::size_t b = 0; b < n; b++) {  //c(b), #(b)=1
        std::bitset<8> bitb(b);
        l += std::pow(-1, ntokens - bitb.count()) * std::log(counts[b]);
    }

    return l;
}

//calculate dice coefficients
// dice = 2*C(2^n-1)/sum(i=1:2^n-1)(#(i)*C(i)): #(i) counts number of digit'1'
double compute_dice2(const std::vector<double> &counts){
    double dice = 0.0;
    const std::size_t n = counts.size();
    for (std::size_t b = 1; b < n; b++) {  //c(b), #(b)=1
        std::bitset<8> bitb(b);
        dice += bitb.count() * counts[b];
    }
    //Rcout<<"counts[n-1]="<<counts[n-1]<<"dice="<<dice<<std::endl;
    dice = counts[n-1]/(dice);  // smoothing has been applied when declaring counts_bit[]
    return dice;
}

Text mark(Text tokens,
          SetUnigrams &set_ignore,
          unsigned int &id_ignore){

    if (tokens.size() == 0) return {}; // return empty vector for empty text

    for (std::size_t i = 0; i < tokens.size(); i++) {
        auto it = set_ignore.find(tokens[i]);
        if (it != set_ignore.end()) {
            tokens[i] = id_ignore;
        }
    }
    return tokens;
}

void counts2(Text text,
             MapNgramsPair &map_seqs,
             const std::vector<unsigned int> &sizes,
             const unsigned int &id_ignore){

    std::vector<bool> flags_nested(text.size(), false);
    std::vector<bool> flags_temp(text.size(), false);

    for (auto size : sizes) { // start from the largest size
        if (text.size() < size) continue;
        for (std::size_t i = 0; i < text.size() - size + 1; i++) {

            bool marked = false; // if the segment contain ineligible
            bool nested = false;
            bool padded = false;

            // check if sub-vector will contain ineligible
            for (std::size_t j = i; j <  i + size; j++) {
                if (text[j] == 0) {
                    padded = true;
                } else if (text[j] == id_ignore) {
                    marked = true;
                    i = j; // jump
                    break;
                }
                if (flags_nested[j]) {
                    nested = true;
                }
            }

            if (!marked) {
                Text text_sub(text.begin() + i, text.begin() + i + size);
                //Rcout << "@" << i << " " <<  nested << ": ";
                //dev::print_ngram(text_sub);
                auto &count = map_seqs[text_sub];
                count.first++;
                if (!padded) {
                    if (nested) {
                        count.second++;
                    }
                    std::fill(flags_temp.begin() + i, flags_temp.begin() + i + size, true);
                }
            }
        }
        flags_nested = flags_temp;
    }
}

void estimates_lambda2(std::size_t i,
                       const VecNgrams &seqs,
                       const VecNgramsPair &seqs_counts,
                       DoubleParams &sgma,
                       DoubleParams &lmda,
                       const String &method,
                       const double smoothing) {

    std::size_t n = seqs[i].size();
    if (n == 1) return; // ignore single words

    std::vector<double> counts_bit(std::pow(2, n), smoothing);
    for (std::size_t j = 0; j < seqs_counts.size(); j++) {
        if (seqs_counts[j].first.size() != n) continue; // skip different lengths
        int bit = match_bit2(seqs[i], seqs_counts[j].first);
        counts_bit[bit] += seqs_counts[j].second;
    }

    //B-J algorithm
    if (method == "lambda1"){
        sgma[i] = sigma_uni2(counts_bit, n);
        lmda[i] = lambda_uni2(counts_bit, n);
    } else {
        sgma[i] = sigma_all2(counts_bit);
        lmda[i] = lambda_all2(counts_bit, n);
    }
}

/*
 * This function estimates the strength of association between specified words
 * that appear in sequences.
 * @used sequences()
 * @param texts_ tokens object
 * @param count_min sequences appear less than this are ignored
 * @param method method to estimate collocation association
 * @param smoothing this number is added to collocation counts
 * @param nested estimate parameters for nested collocations
 */
// [[Rcpp::export]]
DataFrame cpp_collocations(const List &texts_,
                           const CharacterVector &types_,
                           const IntegerVector &words_ignore_,
                           const unsigned int count_min,
                           const IntegerVector sizes_,
                           const String &method,
                           const double smoothing,
                           const int thread = -1){

    Texts texts = as<Texts>(texts_);
    std::vector<unsigned int> sizes = as< std::vector<unsigned int> >(sizes_);
    std::sort(sizes.begin(), sizes.end(), std::greater<unsigned int>()); // sort in descending order
    std::vector<unsigned int> words_ignore = as< std::vector<unsigned int> >(words_ignore_);
    unsigned int id_ignore = UINT_MAX; // use largest limit as filler

    SetUnigrams set_ignore;
    set_ignore.max_load_factor(GLOBAL_PATTERN_MAX_LOAD_FACTOR);
    for (size_t g = 0; g < words_ignore.size(); g++) {
        set_ignore.insert(words_ignore[g]);
    }

    // replace ineligble tokens with special ID
    std::size_t H = texts.size();
#if QUANTEDA_USE_TBB
    tbb::task_arena arena(thread);
    arena.execute([&]{
        tbb::parallel_for(tbb::blocked_range<int>(0, H), [&](tbb::blocked_range<int> r) {
            for (int h = r.begin(); h < r.end(); ++h) {
                texts[h] = mark(texts[h], set_ignore, id_ignore);
            }
        });
    });
#else
    for (std::size_t h = 0; h < H; h++) {
        texts[h] = mark(texts[h], set_ignore, id_ignore);
    }
#endif

    MapNgramsPair map_seqs;
    map_seqs.max_load_factor(GLOBAL_PATTERN_MAX_LOAD_FACTOR);

    //dev::Timer timer;
    //dev::start_timer("Count", timer);
#if QUANTEDA_USE_TBB
    arena.execute([&]{
        tbb::parallel_for(tbb::blocked_range<int>(0, H), [&](tbb::blocked_range<int> r) {
            for (int h = r.begin(); h < r.end(); ++h) {
                counts2(texts[h], map_seqs, sizes, id_ignore);
            }
        });
    });
#else
    for (std::size_t h = 0; h < H; h++) {
        counts2(texts[h], map_seqs, sizes, id_ignore);
    }
#endif

    std::size_t N = map_seqs.size();
    
    // for estimation
    VecNgramsPair seqs_count; // all the collocation
    seqs_count.reserve(N);
    VecNgrams seqs; // only eligible collocation 
    seqs.reserve(N);
    
    // for output
    IntParams counts, counts_nested, lengths;
    counts.reserve(N);
    counts_nested.reserve(N);
    lengths.reserve(N);
    
    for (auto it = map_seqs.begin(); it != map_seqs.end(); ++it) {
        // convert to a vector for faster iteration
        seqs_count.push_back(std::make_pair(it->first, (unsigned int)it->second.first));
        if (it->second.first < count_min) continue;
        // estimate only sequences without padding
        if (std::none_of(it->first.begin(), it->first.end(), [](unsigned int v){ return v == 0; })) {
            seqs.push_back(it->first);
            lengths.push_back(it->first.size());
            counts.push_back(it->second.first);
            counts_nested.push_back(it->second.second);
        }
    }

    std::size_t len_np = seqs.size();
    DoubleParams sgma(len_np), lmda(len_np);
    //DoubleParams dice(len_np), pmi(len_np), logratio(len_np), chi2(len_np), gensim(len_np), lfmd(len_np);

    //dev::start_timer("Estimate", timer);
    std::size_t I = seqs.size();
#if QUANTEDA_USE_TBB
    arena.execute([&]{
        tbb::parallel_for(tbb::blocked_range<int>(0, I), [&](tbb::blocked_range<int> r) {
            for (int i = r.begin(); i < r.end(); ++i) {
                estimates_lambda2(i, seqs, seqs_count, sgma, lmda, method, smoothing);
            }
        });
    });
#else
    for (std::size_t i = 0; i < I; i++) {
        estimates_lambda2(i, seqs, seqs_count, sgma, lmda, method, smoothing);
    }
#endif
    //dev::stop_timer("Estimate", timer);

    // convert sequences from integer to character
    CharacterVector seqs_(I);
    for (std::size_t i = 0; i < I; i++) {
        seqs_[i] = join_strings(seqs[i], types_, " ");
    }

    // Rcout << "collocation: " << seqs_.size() << "\n";
    // Rcout << "count: " << counts.size() << "\n";
    // Rcout << "count_nested: " << counts_nested.size() << "\n";
    // Rcout << "lmda: " << lmda.size() << "\n";
    // Rcout << "sgma: " << sgma.size() << "\n";

    DataFrame output_ = DataFrame::create(
        _["collocation"] = seqs_,
        _["count"] = as<IntegerVector>(wrap(counts)),
        _["count_nested"] = as<IntegerVector>(wrap(counts_nested)),
        _["length"] = as<NumericVector>(wrap(lengths)),
        _[method] = as<NumericVector>(wrap(lmda)),
        _["sigma"] = as<NumericVector>(wrap(sgma)),
        _["stringsAsFactors"] = false);

    return output_;

}


/***R
require(quanteda)
toks <- tokens(data_corpus_inaugural)
toks <- tokens_select(toks, stopwords("english"), "remove", padding = TRUE)
id_ignore <- unlist(pattern2id("^\\p{P}+$", types, 'regex', FALSE), use.names = FALSE)
if (is.null(id_ignore)) id_ignore <- integer(0)
(out <- qatd_cpp_collocations(toks, types(toks), id_ignore, 2, 2:3, "lambda", 0.5))
(out <- out[order(out$lambda, decreasing = TRUE),])
(out <- out[out$count != out$count_nested & out$length < max(out$length),])
txt <- "A gains capital B C capital gains A B capital C capital gains tax gains tax gains B gains C capital gains tax"
toks2 <- tokens(txt)
(out2 <- qatd_cpp_collocations(toks2, types(toks2), numeric(), 1, 3, "lambda", 0.0))
toks3 <- tokens('a b c . d e f')
(out3 <- qatd_cpp_collocations(toks3, types(toks3), 4, 1, 2:3, "lambda", 0.0))
*/
