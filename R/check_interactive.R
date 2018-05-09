#' Verify Correctness of User-Specified Interactive Preference
#'
#' @inheritParams data_collection_program
#'
#' @keywords internal
#'
check_interactive <- function(interactive) {
  if (all(!interactive(), interactive)) {
    message(
      paste("Cannot run data_collection_program interactively.",
        "Setting interactive = FALSE."))
    interactive <- FALSE
  }

  return(interactive)
}
