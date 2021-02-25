test_that("pattern2list is working with collocations", {
    txt <- c(". . . . a b c . . a b c . . . c d e",
             "a b . . a b . . a b . . a b . a b",
             "b c d . . b c . b c . . . b c")
    toks <- quanteda::tokens(txt)
    type <- quanteda::types(toks)
    col <- textstat_collocations(toks, size = 2:3)
    ids <- if (packageVersion("quanteda") < 2.9) {
        quanteda:::pattern2list(col, type, "fixed", TRUE)
    } else {
        quanteda::object2id(col, type, "fixed", TRUE)
    }
    expect_equivalent(col$collocation,
                      vapply(ids, function(x, y) paste0(y[x], collapse = " "), character(1), type))
    expect_equal(names(ids), col$collocation)
})
