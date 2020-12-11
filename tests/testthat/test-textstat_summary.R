test_that("textstat_summary method works", {
    skip_on_os("solaris")
    corp <- quanteda::data_corpus_inaugural[10:15]
    toks <- quanteda::tokens_tolower(quanteda::tokens(corp))
    dfmt <- quanteda::dfm(toks)

    col_summ <- c("document", "chars", "sents", "tokens", "types",
                  "puncts", "numbers", "symbols", "urls",
                  "tags", "emojis")

    # corpus
    summ_corp <- textstat_summary(corp)
    expect_equal(
        summ_corp$sents,
        unname(quanteda::ntoken(quanteda::tokens(corp, what = "sentence")))
    )
    expect_equal(
        names(summ_corp),
        col_summ
    )

    # tokens
    summ_toks <- textstat_summary(toks)
    expect_equal(
        summ_toks$puncts,
        unname(quanteda::ntoken(quanteda::tokens_select(toks, quanteda:::removals_regex(punct = TRUE)[[1]],
                                    valuetype = "regex")))
    )
    expect_equal(
        summ_toks$numbers,
        unname(quanteda::ntoken(quanteda::tokens_select(toks, quanteda:::removals_regex(numbers = TRUE)[[1]],
                                    valuetype = "regex")))
    )
    expect_equal(
        summ_toks$tokens,
        unname(quanteda::ntoken(toks))
    )
    expect_equal(
        summ_toks$types,
        unname(quanteda::ntype(toks))
    )
    expect_equal(
        summ_toks$sents,
        rep(NA, quanteda::ndoc(toks))
    )
    expect_equal(
        names(summ_toks),
        col_summ
    )

    # dfm
    summ_dfm <- textstat_summary(dfmt)
    expect_equal(
        summ_dfm$puncts,
        unname(quanteda::ntoken(quanteda::dfm_select(dfmt, quanteda:::removals_regex(punct = TRUE)[[1]],
                                 valuetype = "regex")))
    )
    expect_equal(
        summ_dfm$numbers,
        unname(quanteda::ntoken(quanteda::dfm_select(dfmt, quanteda:::removals_regex(numbers = TRUE)[[1]],
                                 valuetype = "regex")))
    )
    expect_equal(
        summ_dfm$tokens,
        unname(quanteda::ntoken(dfmt))
    )
    expect_equal(
        summ_dfm$types,
        unname(quanteda::ntype(dfmt))
    )
    expect_equal(
        summ_dfm$sents,
        rep(NA, quanteda::ndoc(dfmt))
    )
    expect_equal(
        names(summ_dfm),
        col_summ
    )
})

test_that("textstat_summary counts hashtag and emoji correctly", {
    skip_on_os("solaris")
    txt <- c("£ € 👏 Rock on❗ 💪️🎸",
             "Hi @qi #quanteda https://quanteda.io")
    toks <- quanteda::tokens(txt)
    summ <- textstat_summary(toks)
    expect_identical(summ$tokens, c(8L, 4L))
    expect_identical(summ$tags, c(0L, 2L))
    expect_identical(summ$emojis, c(4L, 0L))
    expect_identical(summ$urls, c(0L, 1L))
})
