#' Tabulate feature frequencies
#'
#' Produces counts and document frequencies summaries of the features in a
#' [dfm][quanteda::dfm], optionally grouped by a [docvars][quanteda::docvars]
#' variable or other supplied grouping variable.
#' @param x a [dfm][quanteda::dfm] object
#' @param n (optional) integer specifying the top `n` features to be returned,
#' within group if `groups` is specified
#' @param ties_method character string specifying how ties are treated.  See
#'   [base::rank()] for details.  Unlike that function, however, the default is
#'   `"min"`, so that frequencies of 10, 10, 11 would be ranked 1, 1, 3.
#' @param ... additional arguments passed to [dfm_group()][quanteda::dfm_group].
#'   This can be useful in passing `force = TRUE`, for instance, if you are
#'   grouping a dfm that has been weighted.
#' @inheritParams quanteda::groups
#' @return a data.frame containing the following variables:
#' \describe{
#' \item{`feature`}{(character) the feature}
#' \item{`frequency`}{count of the feature}
#' \item{`rank`}{rank of the feature, where 1 indicates the greatest
#' frequency}
#' \item{`docfreq`}{document frequency of the feature, as a count (the
#' number of documents in which this feature occurred at least once)}
#' \item{`docfreq`}{document frequency of the feature, as a count}
#' \item{`group`}{(only if `groups` is specified) the label of the group.
#' If the features have been grouped, then all counts, ranks, and document
#' frequencies are within group.  If groups is not specified, the `group`
#' column is omitted from the returned data.frame.}
#' }
#' @examples
#' library("quanteda")
#' set.seed(20)
#' dfmat1 <- dfm(tokens(c("a a b b c d", "a d d d", "a a a")))
#'
#' textstat_frequency(dfmat1)
#' textstat_frequency(dfmat1, groups = c("one", "two", "one"), ties_method = "first")
#' textstat_frequency(dfmat1, groups = c("one", "two", "one"), ties_method = "average")
#'
#' dfmat2 <- corpus_subset(data_corpus_inaugural, President == "Obama") %>%
#'    tokens(remove_punct = TRUE) %>%
#'    tokens_remove(stopwords("en")) %>%
#'    dfm()
#' tstat1 <- textstat_frequency(dfmat2)
#' head(tstat1, 10)
#'
#' dfmat3 <- head(data_corpus_inaugural) %>%
#'    tokens(remove_punct = TRUE) %>%
#'    tokens_remove(stopwords("en")) %>%
#'    dfm()
#' textstat_frequency(dfmat3, n = 2, groups = President)
#'
#'
#' \dontrun{
#' # plot 20 most frequent words
#' library("ggplot2")
#' ggplot(tstat1[1:20, ], aes(x = reorder(feature, frequency), y = frequency)) +
#'     geom_point() +
#'     coord_flip() +
#'     labs(x = NULL, y = "Frequency")
#'
#' # plot relative frequencies by group
#' dfmat3 <- data_corpus_inaugural %>%
#'     corpus_subset(Year > 2000) %>%
#'     tokens(remove_punct = TRUE) %>%
#'     tokens_remove(stopwords("en")) %>%
#'     dfm() %>%
#'     dfm_group(groups = President) %>%
#'     dfm_weight(scheme = "prop")
#'
#' # calculate relative frequency by president
#' tstat2 <- textstat_frequency(dfmat3, n = 10, groups = President)
#'
#' # plot frequencies
#' ggplot(data = tstat2, aes(x = factor(nrow(tstat2):1), y = frequency)) +
#'     geom_point() +
#'     facet_wrap(~ group, scales = "free") +
#'     coord_flip() +
#'     scale_x_discrete(breaks = nrow(tstat2):1,
#'                        labels = tstat2$feature) +
#'     labs(x = NULL, y = "Relative frequency")
#' }
#' @return `textstat_frequency` returns a data.frame of features and
#'   their term and document frequencies within groups.
#' @export
#' @importFrom quanteda dfm_group
#' @keywords plot
textstat_frequency <- function(x, n = NULL, groups = NULL,
                               ties_method = c("min", "average", "first", "random", "max", "dense"),
                               ...) {
    UseMethod("textstat_frequency")
}

#' @export
textstat_frequency.default <- function(x, n = NULL, groups = NULL,
                               ties_method = c("min", "average", "first", "random", "max", "dense"),
                               ...) {
    stop(friendly_class_undefined_message(class(x), "textstat_frequency"))
}

#' @importFrom stats ave
#' @export
textstat_frequency.dfm <- function(x, n = NULL, groups = NULL,
                               ties_method = c("min", "average", "first", "random", "max", "dense"),
                               ...) {
    ties_method <- match.arg(ties_method)
    x <- as.dfm(x)

    if (!sum(x))
        stop(message_error("dfm_empty"))

    if (missing(groups)) {
        groups <- rep("all", ndoc(x))
    } else {
        field <- deparse(substitute(groups))
        groups <- eval(substitute(groups), get_docvars(x, user = TRUE, system = TRUE), parent.frame())
        if (!field %in% names(get_docvars(x)) || !is.factor(groups))
            field <- NULL
        groups <- as.factor(groups)
    }

    tf <- x
    tf <- dfm_group(tf, groups, ...)
    tf <- as(as(tf, "TsparseMatrix"), "dgTMatrix")

    df <- dfm_weight(x, "boolean", force = TRUE)
    df <- dfm_group(df, groups, ...)
    df <- as(as(df, "TsparseMatrix"), "dgTMatrix")

    result <- data.frame(
        feature = colnames(tf)[tf@j + 1L],
        frequency = tf@x,
        rank = NA,
        docfreq = df@x,
        group = rownames(tf)[tf@i + 1L],
        stringsAsFactors = FALSE
    )

    # get the frequency ranks and sort
    result$rank <- ave(result$frequency, result$group,
                       FUN = function(y) rank(-y, ties.method = ties_method))
    result <- result[order(result$group, result$rank), ]

    # keep only first n items by group, if n is specified
    if (!is.null(n)) {
        result <- do.call(rbind, lapply(split(result, result$group), head, n))
    }

    class(result) <- c("frequency", "textstat", "data.frame")
    rownames(result) <- as.character(seq_len(nrow(result)))
    return(result)
}
