#' Calculate keyness statistics
#'
#' Calculate "keyness", a score for features that occur differentially across
#' different categories.  Here, the categories are defined by reference to a
#' "target" document index in the [dfm], with the reference group
#' consisting of all other documents.
#' @param x a [dfm] containing the features to be examined for keyness
#' @param target the document index (numeric, character or logical) identifying
#'   the document forming the "target" for computing keyness; all other
#'   documents' feature frequencies will be combined for use as a reference
#' @param measure (signed) association measure to be used for computing keyness.
#'   Currently available: `"chi2"`; `"exact"` (Fisher's exact test); `"lr"` for
#'   the likelihood ratio; `"pmi"` for pointwise mutual information.  Note that
#'   the "exact" test is very computationally intensive and therefore much
#'   slower than the other methods.
#' @param sort logical; if `TRUE` sort features scored in descending order
#'   of the measure, otherwise leave in original feature order
#' @param correction if `"default"`, Yates correction is applied to
#'   `"chi2"`; William's correction is applied to `"lr"`; and no
#'   correction is applied for the `"exact"` and `"pmi"` measures.
#'   Specifying a value other than the default can be used to override the
#'   defaults, for instance to apply the Williams correction to the chi2
#'   measure.  Specifying a correction for the `"exact"` and `"pmi"`
#'   measures has no effect and produces a warning.
#' @param ... not used
#' @references Bondi, M. & Scott, M. (eds) (2010). *Keyness in
#'   Texts*. Amsterdam, Philadelphia: John Benjamins.
#'
#'   Stubbs, M. (2010). Three Concepts of Keywords. In *Keyness in
#'   Texts*, Bondi, M. & Scott, M. (eds): 1--42. Amsterdam, Philadelphia:
#'   John Benjamins.
#'
#'   Scott, M. & Tribble, C. (2006). *Textual Patterns: Keyword and Corpus
#'   Analysis in Language Education*. Amsterdam: Benjamins: 55.
#'
#'   Dunning, T. (1993). [Accurate Methods for the Statistics of Surprise and
#'   Coincidence](https://dl.acm.org/doi/10.5555/972450.972454). *Computational
#'   Linguistics*, 19(1): 61--74.
#' @return a data.frame of computed statistics and associated p-values, where
#'   the features scored name each row, and the number of occurrences for both
#'   the target and reference groups. For `measure = "chi2"` this is the
#'   chi-squared value, signed positively if the observed value in the target
#'   exceeds its expected value; for `measure = "exact"` this is the
#'   estimate of the odds ratio; for `measure = "lr"` this is the
#'   likelihood ratio \eqn{G2} statistic; for `"pmi"` this is the pointwise
#'   mutual information statistics.
#' @export
#' @return `textstat_keyness` returns a data.frame of features and
#'   their keyness scores and frequency counts.
#' @keywords textstat
#' @importFrom stats chisq.test
#' @examples
#' library("quanteda")
#'
#' # compare pre- v. post-war terms using grouping
#' period <- ifelse(docvars(data_corpus_inaugural, "Year") < 1945, "pre-war", "post-war")
#' dfmat1 <- dfm(data_corpus_inaugural, groups = period)
#' head(dfmat1) # make sure 'post-war' is in the first row
#' head(tstat1 <- textstat_keyness(dfmat1), 10)
#' tail(tstat1, 10)
#'
#' # compare pre- v. post-war terms using logical vector
#' dfmat2 <- dfm(data_corpus_inaugural)
#' head(textstat_keyness(dfmat2, docvars(data_corpus_inaugural, "Year") >= 1945), 10)
#'
#' # compare Trump 2017 to other post-war preseidents
#' dfmat3 <- dfm(corpus_subset(data_corpus_inaugural, period == "post-war"))
#' head(textstat_keyness(dfmat3, target = "2017-Trump"), 10)
#'
#' # using the likelihood ratio method
#' head(textstat_keyness(dfm_smooth(dfmat3), measure = "lr", target = "2017-Trump"), 10)
textstat_keyness <- function(x, target = 1L,
                             measure = c("chi2", "exact", "lr", "pmi"),
                             sort = TRUE,
                             correction = c("default", "yates", "williams", "none"),
                             ...) {
    UseMethod("textstat_keyness")
}

#' @export
textstat_keyness.default <- function(x, target = 1L,
                                     measure = c("chi2", "exact", "lr", "pmi"),
                                     sort = TRUE,
                                     correction = c("default", "yates", "williams", "none"),
                                     ...) {
    stop(friendly_class_undefined_message(class(x), "textstat_keyness"))
}

#' @importFrom quanteda dfm_group ndoc
#' @export
textstat_keyness.dfm <- function(x, target = 1L, measure = c("chi2", "exact", "lr", "pmi"),
                                 sort = TRUE,
                                 correction = c("default", "yates", "williams", "none"),
                                 ...) {
    check_dots(...)
    x <- as.dfm(x)
    if (!sum(x)) stop(message_error("dfm_empty"))

    measure <- match.arg(measure)
    correction <- match.arg(correction)
    # error checking
    if (ndoc(x) < 2)
        stop("x must have at least two documents")
    if (is.character(target) && !(all(target %in% docnames(x))))
        stop("target not found in docnames(x)")
    if (is.numeric(target) && any(target < 1 | target > ndoc(x)))
        stop("target index outside range of documents")
    if (is.logical(target) && length(target) != ndoc(x))
        stop("logical target value length must equal the number of documents")

    # convert all inputs into logical vector
    if (is.numeric(target)) {
        target <- seq(ndoc(x)) %in% target
    } else if (is.character(target)) {
        target <- docnames(x) %in% target
    } else if (is.logical(target)) {
        target <- target
    } else {
        stop("target must be numeric, character or logical")
    }

    # check if number of target documents < ndoc
    if (sum(target) >= ndoc(x)) {
        stop("target cannot be all the documents")
    }

    # use original docnames only when there are two (different) documents
    if (ndoc(x) == 2 && length(unique(docnames(x))) > 1) {
        label <- docnames(x)[order(target, decreasing = TRUE)]
    } else {
        if (sum(target) == 1 && !is.null(docnames(x)[target])) {
            label <- c(docnames(x)[target], "reference")
        } else {
            label <- c("target", "reference")
        }
    }
    grouping <- factor(target, levels = c(TRUE, FALSE), labels = label)
    temp <- dfm_group(x, groups = grouping)

    if (measure == "exact") {
        if (measure == "exact" && !correction %in% c("default", "none"))
            warning("correction is always none for exact")
        result <- keyness_exact(temp)
    } else {
        if (measure == "pmi" && !correction %in% c("default", "none"))
            warning("correction is always none for pmi")
        result <- data.frame(
            feature = featnames(temp),
            stat = qatd_cpp_keyness(temp, measure, correction),
            p = NA,
            n_target = as.vector(temp[1, ]),
            n_reference = as.vector(temp[2, ]),
            stringsAsFactors = FALSE
        )
        result$p <- 1 - stats::pchisq(abs(result$stat), 1) # abs() for pmi
    }

    if (sort)
        result <- result[order(result$stat, result$feature,
                               decreasing = c(TRUE, FALSE), method = "radix"), ]
    names(result)[2] <- switch(measure, chi2 = "chi2", exact = "exact", lr = "G2", pmi = "pmi")
    rownames(result) <- NULL
    attr(result, "groups") <- docnames(temp)
    class(result) <- c("keyness", "textstat", "data.frame")
    return(result)
}

keyness_exact <- function(x) {
    sums <- rowSums(x)
    temp <- as.data.frame(
        do.call(rbind,
                apply(x, 2, function(y) {
                    et <- stats::fisher.test(matrix(c(as.numeric(y),
                                                      as.numeric(sums - y)),
                                                    nrow = 2))
                    data.frame(or = as.numeric(et$estimate), p = et$p.value)
                }))
    )

    data.frame(feature = colnames(x),
               stat = temp$or,
               p = temp$p,
               n_target = as.vector(x[1, ]),
               n_reference = as.vector(x[2, ]),
               stringsAsFactors = FALSE)
}
