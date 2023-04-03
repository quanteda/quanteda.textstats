#' nsyllable methods for tokens
#'
#' Extends `nsyllable()` methods for [quanteda.textstats::tokens] objects.
#' @inheritParams nsyllable::nsyllable
#' @examples
#' \dontshow{
#' library("nsyllable")
#' txt <- c(one = "super freakily yes",
#'          two = "merrily all go aerodynamic")
#' toks <- quanteda::tokens(txt)
#' nsyllable(toks)
#' }
#' @importFrom nsyllable nsyllable
#' @export
#' @keywords internal
nsyllable.tokens <- function(x, language = "en",
                             syllable_dictionary = nsyllable::data_syllables_en,
                             use.names = FALSE) {
    types <- types(x)
    if (attr(x, "padding")) {
        vocab_sylls <- nsyllable(c("", types), use.names = use.names)
        lapply(unclass(x), function(y) vocab_sylls[y + 1])
    } else {
        vocab_sylls <- nsyllable(types, use.names = use.names)
        lapply(unclass(x), function(y) vocab_sylls[y])
    }
}
