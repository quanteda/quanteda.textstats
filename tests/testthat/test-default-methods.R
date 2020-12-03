context("test default methods for nice error messages")

test_that("test default textstat methods", {
    expect_error(
        textstat_dist(TRUE),
        "textstat_dist\\(\\) only works on dfm objects"
    )
    expect_error(
        textstat_keyness(TRUE),
        "textstat_keyness\\(\\) only works on dfm objects"
    )
    expect_error(
        textstat_simil(TRUE),
        "textstat_simil\\(\\) only works on dfm objects"
    )
    expect_error(
        textstat_lexdiv(TRUE),
        "textstat_lexdiv\\(\\) only works on dfm, tokens objects"
    )
    expect_error(
        textstat_readability(TRUE),
        "textstat_readability\\(\\) only works on character, corpus objects"
    )
    expect_error(
        textstat_collocations(TRUE),
        "textstat_collocations\\(\\) only works on.*tokens objects"
    )
    expect_error(
        textstat_entropy(quanteda::tokens("one two three")),
        "textstat_entropy() only works on dfm objects.", fixed = TRUE
    )
    expect_error(
        textstat_summary(LETTERS),
        "textstat_summary() only works on corpus, dfm, tokens objects",
        fixed = TRUE
    )
    expect_error(
        textstat_select(FALSE),
        "textstat_select() only works on textstat objects",
        fixed = TRUE
    )
    expect_error(
        textstat_frequency(LETTERS),
        "textstat_frequency() only works on dfm objects",
        fixed = TRUE
    )
    expect_error(
        nscrabble(TRUE),
        "nscrabble\\(\\) only works on character.*objects"
    )
})
