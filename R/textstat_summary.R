#' Summarize documents as syntactic and lexical feature counts
#'
#' Count syntactic and lexical features of documents such as tokens, types,
#' sentences, and character categories.
#'
#' Count the total number of characters, tokens and sentences as well as special
#' tokens such as numbers, punctuation marks, symbols, tags and emojis.
#' \itemize{
#' \item chars = number of characters; equal to [nchar()]
#' \item sents
#' = number of sentences; equal `ntoken(tokens(x), what = "sentence")`
#' \item
#' tokens = number of tokens; equal to [ntoken()]
#' \item types = number of unique tokens; equal to [ntype()]
#' \item puncts = number of punctuation marks (`^\p{P}+$`)
#' \item numbers = number of numeric tokens
#' (`^\p{Sc}{0,1}\p{N}+([.,]*\p{N})*\p{Sc}{0,1}$`)
#' \item symbols = number of symbols (`^\p{S}$`)
#' \item tags = number of tags; sum of `pattern_username` and `pattern_hashtag`
#' in [quanteda::quanteda_options()]
#' \item emojis = number of emojis (`^\p{Emoji_Presentation}+$`)
#' }
#' @param x corpus to be summarized
#' @param ... additional arguments passed through to [dfm()]
#' @export
#' @keywords textstat
#' @examples
#' if (Sys.info()["sysname"] != "SunOS") {
#' library("quanteda")
#' corp <- data_corpus_inaugural[1:5]
#' textstat_summary(corp)
#' toks <- tokens(corp)
#' textstat_summary(toks)
#' dfmat <- dfm(toks)
#' textstat_summary(dfmat)
#' }
textstat_summary <- function(x, ...) {
    UseMethod("textstat_summary")
}

#' @export
textstat_summary.default <- function(x, ...) {
    stop(friendly_class_undefined_message(class(x), "textstat_summary"))
}

#' @method textstat_summary corpus
#' @importFrom quanteda as.corpus
#' @export
textstat_summary.corpus <- function(x, ...) {
    summarize(as.corpus(x), ...)
}

#' @method textstat_summary tokens
#' @importFrom quanteda as.tokens is.corpus
#' @export
textstat_summary.tokens <- function(x, ...) {
    summarize(as.tokens(x), ...)
}

#' @method textstat_summary dfm
#' @importFrom quanteda as.dfm
#' @export
textstat_summary.dfm <- function(x, ...) {
    summarize(as.dfm(x), ...)
}

summarize <- function(x, ...) {

    patterns <- removals_regex(punct = TRUE, symbols = TRUE,
                               numbers = TRUE, url = TRUE)
    patterns[["tag"]] <-
        list("username" = paste0("^", quanteda::quanteda_options("pattern_username"), "$"),
             "hashtag" = paste0("^", quanteda::quanteda_options("pattern_hashtag"), "$"))
    patterns[["emoji"]] <- "^\\p{Emoji_Presentation}+$"
    dict <- quanteda::dictionary(patterns)

    y <- dfm(if (is.corpus(x)) tokens(x) else x, ...)
    temp <- quanteda::convert(
        quanteda::dfm_lookup(y, dictionary = dict, valuetype = "regex", levels = 1),
        "data.frame",
        docid_field = "document"
    )
    result <- data.frame(
        "document" = quanteda::docnames(y),
        "chars" = NA,
        "sents" = NA,
        "tokens" = quanteda::ntoken(y),
        "types" = quanteda::ntype(y),
        "puncts" = as.integer(temp$punct),
        "numbers" = as.integer(temp$numbers),
        "symbols" = as.integer(temp$symbols),
        "urls" = as.integer(temp$url),
        "tags" = as.integer(temp$tag),
        "emojis" = as.integer(temp$emoji),
        row.names = seq_len(quanteda::ndoc(y)),
        stringsAsFactors = FALSE
    )

    if (quanteda::is.corpus(x)) {
        result$chars <- nchar(x)
        result$sents <- quanteda::ntoken(quanteda::tokens(x, what = "sentence"))
    }

    return(result)
}
