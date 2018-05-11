#' Manually Collect Direct Observation Data
#'
#' @param id Character scalar giving ID to assign to the trial
#' @param timestamps Vector of times (character or POSIX) corresponding to onset of each activity and (if \code{durations = NULL}) offset of the final activity (i.e., ending time of the trial)
#' @param activities Character vector of activities in the sequence they were performed
#' @param durations Optional numeric vector giving duration of each activity, in seconds
#' @param seated Character vector giving yes/no/NA response for whether the participant was seated during each activity
#' @param large_muscles_moving Character vector giving yes/no/NA response for whether the participant was moving large muscles during each activity
#' @param slow Character vector giving yes/no/NA response for whether muscle contractions were slow during each activity
#' @param slowed_by_resistance Character vector giving yes/no/NA response for whether slow muscle contractions were slowed because of resistance
#' @param ambulation Character vector giving yes/no/NA response for whether the each activity is ambulatory
#' @param light_walking Character vector giving yes/no/NA response for whether ambulation was slow enough to be considered light activity instead of moderate or vigorous
#' @param rational Logical: Should numeric minute of the day be given as a rational number (TRUE) or an integer (FALSE)
#' @param ... Additional arguments passed to \code{\link[AGread]{get_minute}}
#'
#' @return A dataframe of pre-processed direct observation data generated
#'     from minimal input
#'
#' @note By default, activity duration is automatically calculated, which is accomplished via \code{\link[base]{diff.POSIXt}} and thus requires \code{n + 1} timestamps, where \code{n} is the number of activities. Alternatively, durations can be manually specified via the \code{durations} parameter, in which case only \code{n} timestamps are needed, corresponding to the onset of each activity.
#'
#' @family collection functions
#' @keywords internal
#'
data_collection_program_manual <- function(id, timestamps, activities,
  durations = NULL, seated = NA,
  large_muscles_moving = NA, slow = NA,
  slowed_by_resistance = NA, ambulation = NA,
  light_walking = NA, rational = TRUE, ...) {


    if (all(is.null(durations),
      length(timestamps) != (length(activities) + 1))) {
      stop(paste("Cannot calculate duration for final activity",
        "unless timestamps vector has an extra entry giving stop time of."))
    }

    if (is.null(durations)) {
      timestamps <- as.POSIXct(as.character(timestamps), "UTC")
      durations <- diff.POSIXt(timestamps)
    }

    all_data <- data.frame(
      id = id,
      Timestamp = timestamps[seq(activities)],
      dayofyear =
        AGread::get_day_of_year(timestamps[seq(activities)],
          ...),
      minofday =
        AGread::get_minute(timestamps[seq(activities)],
          ..., rational = rational),
      Activity = activities,
      duration_s = durations,
      Tree_Intensity = "Indeterminate",
      seated = seated,
      large_muscles_moving = large_muscles_moving,
      slow = slow,
      slowed_by_resistance = slowed_by_resistance,
      ambulation = ambulation,
      light_walking = light_walking, stringsAsFactors = FALSE)

    tree_names <- c("seated", "large_muscles_moving",
      "slow", "slowed_by_resistance",
      "ambulation", "light_walking")
    descriptions <-
      apply(all_data[ ,tree_names], 1, tree_intensity_manual)
    all_data$Tree_Intensity <-
      factor(as.character(descriptions),
        levels = c("Sedentary", "Sedentary/Light",
          "Light/Moderate", "Indeterminate",
          "Light", "MVPA"))

    tree_data <- all_data[ ,tree_names]
    tree_data <-
      do.call(data.frame,
        sapply(tree_data, factor,
          levels = c("yes", "no"), simplify = FALSE))
    all_data[ ,tree_names] <- tree_data
  return(all_data)
}

#' Manually Pre-Classify Activity Intensity
#'
#' Manually implement the pre-classification decision tree described
#'     at the end of Supplemental Document 3 from \href{https://www.ncbi.nlm.nih.gov/pubmed/29135657}{Hibbing et al. (2018,
#' *Med Sci Sports Exerc*)}.
#'
#' @param prompt_responses A vector of responses to the decision tree prompts
#' @keywords internal
#'
#' @note The vector of responses must match the structure indicated in the
#'   example, i.e., a named vector answering prompts in the following order:
#'   participant seated; large muscles contracting; slow contractions;
#'   contractions slowed by resistance; activity is ambulatory; ambulation is
#'   slow enough to be considered light activity rather than moderate or
#'   vigorous.
#'
#' @examples
#' prompt_responses <- structure(c("yes", "no", NA, NA, NA, NA),
#'     .Dim = c(6L, 1L), .Dimnames = list(c("seated",
#'       "large_muscles_moving", "slow", "slowed_by_resistance",
#'       "ambulation", "light_walking"),
#'     "1"))
#'
#' Observation:::tree_intensity_manual(prompt_responses)
#'
tree_intensity_manual <- function(prompt_responses) {
  # prompt_responses <-
  # apply(all_data[2 ,tree_names], 1, function(x) x)

  stopifnot(
    names(prompt_responses) == c(
      "seated",
      "large_muscles_moving",
      "slow",
      "slowed_by_resistance",
      "ambulation",
      "light_walking"
    )
  )
  if (all.equal(as.vector(prompt_responses),
    c("yes", "yes", "yes", "yes", NA, NA)) == TRUE) return("Light/Moderate")

  if (all.equal(as.vector(prompt_responses),
    c("yes", "yes", "yes", "no", NA, NA)) == TRUE) return("Sedentary/Light")

  if (all.equal(as.vector(prompt_responses),
    c("yes", "yes", "no", NA, NA, NA)) == TRUE) return("Indeterminate")

  if (all.equal(as.vector(prompt_responses),
    c("yes", "no", NA, NA, NA, NA)) == TRUE) return("Sedentary")

  if (all.equal(as.vector(prompt_responses),
    c("no", "yes", "yes", "yes", NA, NA)) == TRUE) return("Light/Moderate")

  if (all.equal(as.vector(prompt_responses),
    c("no", "yes", "yes", "no", NA, NA)) == TRUE) return("Light")

  if (all.equal(as.vector(prompt_responses),
    c("no", "yes", "no", NA, "yes", "yes")) == TRUE) return("Light")

  if (all.equal(as.vector(prompt_responses),
    c("no", "yes", "no", NA, "yes", "no")) == TRUE) return("MVPA")

  if (all.equal(as.vector(prompt_responses),
    c("no", "yes", "no", NA, "no", NA)) == TRUE) return("Light/Moderate")

  if (all.equal(as.vector(prompt_responses),
    c("no", "no", NA, NA, NA, NA)) == TRUE) return("Light")

  # Default
  return("Indeterminate")
}
