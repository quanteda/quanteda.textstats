#' Count the Scrabble letter values of text
#'
#' Tally the Scrabble letter values of text given a user-supplied function, such
#' as the sum (default) or mean of the character values.
#' @param x a character vector
#' @param FUN function to be applied to the character values in the text;
#'   default is `sum`, but could also be `mean` or a user-supplied
#'   function.  Missing values are automatically removed.
#' @author Kenneth Benoit
#' @return a (named) integer vector of Scrabble letter values, computed using
#'   `FUN`, corresponding to the input text(s)
#' @note Character values are only defined for non-accented Latin a-z, A-Z
#'   letters.  Lower-casing is unnecessary.
#'
#'   We would be happy to add more languages to this *extremely useful
#'   function* if you send us the values for your language!
#' @examples
#' nscrabble(c("muzjiks", "excellency"))
#' nscrabble(quanteda::data_corpus_inaugural[1:5], mean)
#' @export
#' @keywords internal
nscrabble <- function(x, FUN = sum) {
  UseMethod("nscrabble")
}

#' @export
nscrabble.default <- function(x, FUN = sum) {
  stop(friendly_class_undefined_message(class(x), "nscrabble"))
}

#' @rdname nscrabble
#' @noRd
#' @export
nscrabble.character <- function(x, FUN = sum) {
  FUN <- match.fun(FUN)
  points <- structure(as.integer(rep(c(1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3,
                                       1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10), 2)),
                      names = c(letters, LETTERS))
  result <- sapply(stringi::stri_split_boundaries(x, type = "character"),
                   function(y) FUN(na.omit(points[y])))
  names(result) <- names(x)
  ifelse(result == 0, NA, result)
}

## English scrabble values
# (1 point)   A, E, I, O, U, L, N, S, T, R
# (2 points)  D, G
# (3 points)  B, C, M, P
# (4 points)  F, H, V, W, Y
# (5 points)  K
# (8 points)  J, X
# (10 points) Q, Z
