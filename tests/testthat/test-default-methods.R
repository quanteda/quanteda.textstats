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
        textstat_collocations(TRUE),
        "textstat_collocations\\(\\) only works on.*tokens objects"
    )
    expect_error(
        textstat_entropy(tokens(data_char_sampletext)),
        "textstat_entropy() only works on dfm objects.", fixed = TRUE
    )
    expect_error(
        textstat_summary(data_char_sampletext),
        "textstat_summary() only works on corpus, dfm, tokens objects",
        fixed = TRUE
    )
    expect_error(
        nscrabble(TRUE),
        "nscrabble\\(\\) only works on character.*objects"
    )
})