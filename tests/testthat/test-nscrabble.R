test_that("test nscrabble", {
    txt1 <- c("muzjiks", "excellency", "")
    txt2 <- c(d1 = "muzjiks", d2 = "excellency", d3 = "")

    expect_identical(nscrabble(txt1), c(29L, 24L, NA))
    expect_identical(nscrabble(txt2), c(d1 = 29L, d2 = 24L, d3 = NA))

    txt3 <- "muzjiks excellency "
    expect_identical(
        nscrabble(txt3, FUN = sum),
        53L
    )
    expect_identical(
        nscrabble("xyz", FUN = min),
        4L
    )
    expect_equal(
        nscrabble("xyz", FUN = mean),
        7.333,
        tol = .001
    )

    # with names
    expect_identical(
        nscrabble(c(d1 = "xyz")),
        c(d1 = 22L)
    )
})
