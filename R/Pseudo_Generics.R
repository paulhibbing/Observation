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
#' @seealso \code{\link{example_data}}
#'
#' @family collection functions
#'
#' @examples
#' if (interactive()) {
#' data_collection_program()
#' }
#'
#' # Load Sample of interactively-collected data for comparison
#' #    with manually-entered data
#'
#' data("example_data")
#'
#' # Example of manually defining input variables -------------------------
#'
#' id <- "Test_ID"
#'
#' timestamps <- c("2018-05-06 02:40:37", "2018-05-06 02:40:46",
#'     "2018-05-06 02:40:59", "2018-05-06 02:41:14",
#'     "2018-05-06 02:41:27", "2018-05-06 02:41:37",
#'     "2018-05-06 02:41:48", "2018-05-06 02:42:03",
#'     "2018-05-06 02:42:24", "2018-05-06 02:42:39",
#'     "2018-05-06 02:42:53")
#'
#' activities <- c("sitting still", "sitting stretching",
#'     "sitting shoulder press", "sitting cycling",
#'     "standing still", "standing stretching",
#'     "standing shoulder press", "walking slowly",
#'     "walking quickly", "jumping jacks")
#'
#' durations <- c(9, 13, 15, 13, 10, 11, 15, 21, 15, 14.460825920105)
#'
#' Tree_Intensity <- c("Sedentary", "Sedentary/Light",
#'     "Light/Moderate", "Indeterminate", "Light", "Light",
#'     "Light/Moderate", "Light", "MVPA", "Light/Moderate")
#'
#' seated <- c("yes", "yes", "yes", "yes", "no", "no", "no",
#'     "no", "no", "no")
#'
#' large_muscles_moving <- c("no", "yes", "yes", "yes",
#'     "no", "yes", "yes", "yes", "yes", "yes")
#'
#' slow <- c(NA, "yes", "yes", "no", NA, "yes", "yes",
#'     "no", "no", "no")
#'
#' slowed_by_resistance <- c(NA, "no", "yes", NA, NA,
#'     "no", "yes", NA, NA, NA)
#'
#' ambulation <- c(NA, NA, NA, NA, NA, NA, NA,
#'     "yes", "yes", "no")
#'
#' light_walking <- c(NA, NA, NA, NA, NA, NA,
#'     NA, "yes", "no", NA)
#'
#' # Example of using the manual program ----------------------------------
#'
#' manual_data <- data_collection_program(
#'   interactive = FALSE, id = id, timestamps = timestamps,
#'   activities = activities, durations = durations, seated = seated,
#'   large_muscles_moving = large_muscles_moving, slow = slow,
#'   slowed_by_resistance = slowed_by_resistance, ambulation = ambulation,
#'   light_walking = light_walking
#' )
#'
#' # Comparing output of interactive vs manual program --------------------
#'
#' test_names <- intersect(names(example_data), names(manual_data))
#' test_names <- setdiff(names(test_names), "duration_s")
#'
#' all.equal(
#'   example_data[ ,test_names],
#'   manual_data[ ,test_names],
#'   scale = 1,
#'   tolerance = 5
#' )
data_collection_program <- function(interactive = TRUE, ...) {

  interactive <- check_interactive(interactive)

  observation <- if (interactive) {
    interactive_data_collection_program(...)
  } else {
    manual_data_collection_program(...)
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
#' @family processing functions
#'
#' @examples
#' data(example_data)
#'
#' compendium_reference(example_data, FALSE, kids = "yes", mvpa = "yes")
#' if (interactive()) {
#'     compendium_reference(example_data)
#' }
#'
compendium_reference <- function(obs_data, interactive = TRUE, ...){

  interactive <- check_interactive(interactive)

  obs_data <- if (interactive) {
    interactive_compendium_reference(obs_data, ...)
  } else {
    manual_compendium_reference(obs_data, ...)
  }

  return(obs_data)

}
