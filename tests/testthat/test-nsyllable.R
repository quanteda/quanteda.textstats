test_that("nsyllable.tokens works", {
  toks <- tokens("one ten twenty")
  expect_equal(
    nsyllable(toks),
    list(text1 = c(1, 1, 2))
  )
  expect_equal(
    nsyllable(tokens_remove(toks, "ten", padding = TRUE)),
    list(text1 = c(1, NA, 2))
  )
})
