friendly_class_undefined_message <- quanteda:::friendly_class_undefined_message
message_error <- quanteda:::message_error
removals_regex <- quanteda:::removals_regex
pad_dfm <- quanteda:::pad_dfm
get_docvars <- quanteda:::get_docvars
get_docvars.dfm <- quanteda:::get_docvars.dfm

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

get_threads <- function() {
    value <- getOption("quanteda_threads", -1L)
    if (!is.integer(value) || length(value) != 1L)
        stop("Invalid value of threads in quanteda options")
    return(value)
}

