#' Collect Direct Observation Data
#'
#' A generic-like function for collecting direct observation data manually or
#' interactively, depending on user-specified preference and session
#' capabilities.
#'
#' @param interactive Logical. Should program be run interactively?
#' @param ... Additional arguments passed to method-like functions (under "See Also" below)
#'
#' @export
#' @note If `interactive = TRUE`, but R is not being used interactively, a
#'   message is issued and an override is implemented to set `interactive =
#'   FALSE`.
#'
#' @seealso [data_collection_program_interactive()],
#'     [data_collection_program_manual()]
#'
#' @examples
#' if (interactive()) {
#' data_collection_program()
#' }
#'
#' data_collection_program(interactive = FALSE)
data_collection_program <- function(interactive = TRUE, ...) {

  if (all(!interactive(), interactive)) {
    message(
      paste("Cannot run data_collection_program interactively.",
        "Setting interactive = FALSE."))
    interactive <- FALSE
  }

  observation <- if (interactive) {
    data_collection_program_interactive()
  } else {
    data_collection_program_manual()
  }

  return(observation)
}
