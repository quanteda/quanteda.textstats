Sys.setenv("R_TESTS" = "")
Sys.setenv("_R_CHECK_LENGTH_1_CONDITION_" = TRUE)

library("testthat")
# library("quanteda")
library("quanteda.textstats")
quanteda::quanteda_options(reset = TRUE)

# return an error for all Matrix deprecations
options(Matrix.warnDeprecatedCoerce = 2)

test_check("quanteda.textstats")
