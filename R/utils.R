unused_dots <- quanteda.core:::unused_dots

friendly_class_undefined_message <- quanteda.core:::friendly_class_undefined_message

message_error <- quanteda.core:::message_error

removals_regex <- quanteda.core:::removals_regex

pad_dfm <- quanteda.core:::pad_dfm

get_cache <- function(x, field, ...) {
    if (Sys.info()[["sysname"]] == "SunOS")
        return(NULL)
    meta <- meta(x, type = "all")
    hash <- hash_object(x, ...)
    #print(hash)
    if (identical(meta$object[[field]][["hash"]], hash)) {
        result <- meta$object[[field]][["data"]]
    } else {
        result <- NULL
    }
    return(result)
}

set_cache <- function(x, field, object, ...) {
    if (Sys.info()[["sysname"]] == "SunOS")
        return()
    meta <- meta(x, type = "all")
    hash <- hash_object(x, ...)
    #print(hash)
    meta$object[[field]] <- list("hash" = hash, "data" = object)
    qatd_cpp_set_meta(x, meta)
}

clear_cache <- function(x, field) {
    if (Sys.info()[["sysname"]] == "SunOS")
        return()
    meta <- meta(x, type = "all")
    if (field %in% names(meta$object)) {
        meta$object[[field]] <- list()
        qatd_cpp_set_meta(x, meta)
    }
}

hash_object <- function(x, ...) {
    attr(x, "meta") <- NULL
    digest::digest(list(x, utils::packageVersion("quanteda"), ...),
                   algo = "sha256")
}
