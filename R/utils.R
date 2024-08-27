friendly_class_undefined_message <- quanteda:::friendly_class_undefined_message
message_error <- quanteda:::message_error
removals_regex <- quanteda:::removals_regex
pad_dfm <- quanteda:::pad_dfm
# get_docvars <- quanteda:::get_docvars
# get_docvars.dfm <- quanteda:::get_docvars.dfm
is_system <- quanteda:::is_system

#' Check arguments passed to other functions via ...
#' @param ... dots to check
#' @param method the names of functions `...` is passed to
#' @keywords internal development
check_dots <- function(..., method = NULL) {
    arg <- setdiff(names(list(...)), "")
    if (!is.null(method)) {
        arg_used <- unlist(lapply(method, function(x) names(formals(x))))
        arg <- setdiff(arg, arg_used)
    }
    if (length(arg) > 1) {
        warning(paste0(arg, collapse = ", "), " arguments are not used.", call. = FALSE)
    } else if (length(arg) == 1) {
        warning(arg, " argument is not used.", call. = FALSE)
    }
}

#' Internal function to extract docvars
#' @param x an object from which docvars are extracted
#' @param field name of docvar fields
#' @param user if `TRUE`, return user variables
#' @param system if `TRUE`, return system variables
#' @param drop if `TRUE`, convert data.frame with one variable to a vector
#' @keywords internal
get_docvars <- function(x, field = NULL, user = TRUE, system = FALSE, drop = FALSE) {
    UseMethod("get_docvars")
}

#' @method get_docvars corpus
get_docvars.corpus <- function(x, field = NULL, user = TRUE, system = FALSE, drop = FALSE) {
    select_docvars(attr(x, "docvars"), field, user, system, drop)
}

#' @method get_docvars tokens
get_docvars.tokens <- function(x, field = NULL, user = TRUE, system = FALSE, drop = FALSE) {
    select_docvars(attr(x, "docvars"), field, user, system, drop)
}

#' @method get_docvars dfm
get_docvars.dfm <- function(x, field = NULL, user = TRUE, system = FALSE, drop = FALSE) {
    select_docvars(x@docvars, field, user, system, drop)
}

# Internal function to select columns of docvars
select_docvars <- function(x, field = NULL, user = TRUE, system = FALSE, drop = FALSE) {
    x <- x[user * !is_system(names(x)) | system * is_system(names(x))]
    if (is.null(field)) {
        return(x)
    }
    error <- !field %in% names(x)
    if (any(error))
        stop("field(s) ", paste(field[error], collapse = ", "), " not found")
    if (length(field) == 1 && drop) {
        return(x[[field]])
    }
    return(x[field])
}
