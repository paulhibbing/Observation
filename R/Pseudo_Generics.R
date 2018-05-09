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
#'     [data_collection_program_manual()],
#'     [example_data]
#'
#' @examples
#' if (interactive()) {
#' data_collection_program()
#' }
#'
#' data_collection_program(interactive = FALSE)
data_collection_program <- function(interactive = TRUE, ...) {

  interactive <- check_interactive(interactive)

  observation <- if (interactive) {
    data_collection_program_interactive(...)
  } else {
    data_collection_program_manual()
  }

  return(observation)
}

#' Consult the
#' \href{https://sites.google.com/site/compendiumofphysicalactivities/}{Compendium
#' of Physical Activities} to Encode Direct Observation Intensities
#'
#' @param obs_data A data frame outputted from
#'   \code{\link{data_collection_program}}
#'
#' @inheritParams data_collection_program
#'
#' @return A data frame fully annotated with intensity values
#' @export
#'
#' @note If `interactive = TRUE`, but R is not being used interactively, a
#'   message is issued and an override is implemented to set `interactive =
#'   FALSE`.
#'
#' @seealso [compendium_reference_interactive()],
#'     [compendium_reference_manual()]
#'
#' @examples
#' data(example_data)
#'
#' compendium_reference(example_data, FALSE)
#' if (interactive()) {
#'     compendium_reference(example_data)
#' }
#'
compendium_reference <- function(obs_data, interactive = TRUE, ...){

  interactive <- check_interactive(interactive)

  obs_data <- if (interactive) {
    compendium_reference_interactive(obs_data, ...)
  } else {
    compendium_reference_manual(obs_data)
  }

  return(obs_data)

}
