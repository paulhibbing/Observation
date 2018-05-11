#' Manually Encode Direct Observation Intensities by Cross-Referencing the
#' \href{https://sites.google.com/site/compendiumofphysicalactivities/}{Compendium
#' of Physical Activities}
#'
#' @param obs_data A data frame outputted from
#'   \code{\link{data_collection_program}} with
#'       \code{interactive = FALSE}
#'
#' @param kids A character scalar in \code{c("yes", "no")}:
#'   Should intensities be determined using youth cutoffs for
#'   light intensity (2 metabolic equivalents, not 1.5) and
#'   moderate intensity (4 metabolic equivalents, not 3)
#'   physical activity? Default is \code{"yes"}, with a warning
#'   that the value was not manually set.
#'
#' @param mvpa A character scalar in \code{c("yes", "no")}: Should
#'   moderate and vigorous physical activity be coded as a single
#'   category (i.e., MVPA)? Default is \code{"yes"}, with a
#'   warning that the value was not manually set.
#'
#' @return A list with three elements. The first (\code{data}) is the
#'   original data, where a \code{Final_Intensity} column has been
#'   populated to the extent possible, with "Indeterminate" listed for
#'   the other activities. The second element (\code{indeterminate}) is
#'   another list, which has one element for each activity in
#'   \code{data} with \code{Final_Intensity = "Indeterminate"}. The
#'   elements of \code{indeterminate} are named after the activity they
#'   represent, and the contents are a subset of the Compendium giving
#'   suggested matches for the activity, based on its description in
#'   \code{data}. The third element (\code{compendium}) gives the entire
#'   compendium, which can be manually cross-referenced for cases where
#'   the suggested matches in \code{indeterminate} do not give a suitable
#'   match.
#'
#' @examples
#' data(example_data)
#'
#' example_data_processed <-
#'  Observation:::compendium_reference(example_data, FALSE,
#'    kids = "yes", mvpa = "yes")
#'
#' if (interactive()) {
#'  View(example_data_processed$data)
#'  View(example_data_processed$indeterminate[[1]])
#'  View(example_data_processed$compendium)
#' }
#'
#' @family processing functions
#'
#' @keywords internal
manual_compendium_reference <- function(obs_data, kids = c("yes", "no"),
  mvpa = c("yes", "no")){

  fun_call <- deparse(sys.call(sys.parent()))

  if (!any(grepl("kids", fun_call))) {
    kids <- "yes"
    warning(
      paste("No value provided for argument `kids`.",
        "Defaulting to \"yes\".",
        "\n  See help(Observation:::manual_compendium_reference)",
        "for more info.")
    )
  }

  if (!any(grepl("mvpa", fun_call))) {
    mvpa <- "yes"
    warning(
      paste("No value provided for argument `mvpa`.",
        "Defaulting to \"yes\".",
        "\n  See help(Observation:::manual_compendium_reference)",
        "for more info.")
    )
  }

  stopifnot(length(kids) == 1, length(mvpa) == 1,
    kids %in% c("yes", "no"), mvpa %in% c("yes", "no"))

  # Use 1.51 and 2.01 because we will use cut(<args>, right = FALSE)
  breaks <- c(0, 1.51, 3, 6, Inf)
  childbreaks <- c(0, 2.01,   4, 6, Inf)

  if (mvpa=='yes') {
    breaks      = breaks[-4]
    childbreaks = childbreaks[-4]
  }

  labels <- c('Sedentary', 'Light', 'Moderate','Vigorous')
  threecatlabels <- c('Sedentary', 'Light', 'MVPA')

  compendium$Intensity <-
    cut(compendium$METS,
      breaks = if(kids=='yes') childbreaks    else breaks,
      labels = if(mvpa=='yes') threecatlabels else labels,
      right = FALSE)

  levels <- levels(compendium$Intensity)

  obs_data$Tree_Intensity <-
    gsub('Moderate', 'MVPA', obs_data$Tree_Intensity)

  obs_data$Tree_Intensity <-
    gsub('Vigorous', 'MVPA', obs_data$Tree_Intensity)

  compendium <-
    compendium[with(compendium, order(Intensity, Activity)),]

  ### Find possible matches based on Activity description
  correct_intensity <- obs_data$Tree_Intensity %in% levels
  obs_data$Final_Intensity <-
    ifelse(correct_intensity, obs_data$Tree_Intensity, "Indeterminate")

  incorrect_entries <- stats::setNames(
    strsplit(obs_data$Activity[!correct_intensity], ' '),
    obs_data$Activity[!correct_intensity]
  )
  incorrect_entries <-
    lapply(incorrect_entries, function(x) gsub('ing','',x))
  incorrect_entries <-
    lapply(incorrect_entries, function(x) gsub('ed','',x))

  incorrect_entries <-
    lapply(incorrect_entries, function(x){
      matches <- unlist(lapply(x, function(y){
        which(grepl(y, compendium$Activity, ignore.case = T))}))

      test <- if(sum(matches)==0) compendium else compendium[matches,]
      return(test)
    })
  ### This returns a data frame for each observation partition with a short
  ### list of possible corresponding compendium activities based solely on
  ### primitive string matching

  ### Append tree intensity and original entry to each entry in the
  ### aforementioned list
  incorrect_intensities <-
    obs_data$Tree_Intensity[!correct_intensity]
  if(mvpa!='yes'){
    incorrect_intensities <-
      gsub('MVPA','Moderate Vigorous', incorrect_intensities)
  }

  incorrect_activities <-
    obs_data$Activity[!correct_intensity]

  incorrect_entries <-
    mapply(
      function(x,y) {
        x$Tree_Intensity <-
          rep(incorrect_intensities[y], nrow(x))
        x$Original_Entry <-
          rep(incorrect_activities[y], nrow(x))
        return(x)},
      x = incorrect_entries,
      y = seq(incorrect_intensities),
      SIMPLIFY = F)

  ### Remove possibilities outside the tree-designated range
  incorrect_entries <-
    lapply(incorrect_entries, function(x) {
      qualifies <-
        sapply(x$Intensity,
          function(y) grepl(y, x$Tree_Intensity[1], ignore.case = T))

      x <-
        if(x$Tree_Intensity[1]!='Indeterminate') x[qualifies,] else x
      return(x)
    })
  ### This is another sadly convoluted step.
  ### It just cleans up instances where
  ### the tree said light/MVPA but a potential
  ### match with a sedentary activity was found

  ### If all compendium possibilities are the same,
  ### set to that; otherwise, get help
  incorrect_entries <-
    lapply(incorrect_entries,
      function(z) {
        z$Final_Intensity <-
          if (length(unique(z$Intensity)) == 1) {
            unique(z$Intensity)
          } else {
            "Indeterminate"
          }
        return(z)
      })

  ### Pull it all together
  obs_data$Final_Intensity <-
    sapply(seq(nrow(obs_data)),
      function(x) {
        activity <- obs_data$Activity[x]
        incorrect <-
          activity %in% names(incorrect_entries)
        if (incorrect) {
          unique(incorrect_entries[[activity]]$Final_Intensity)
        } else {
          obs_data$Final_Intensity[x]
        }
      })

  still_incorrect <-
    sapply(incorrect_entries,
      function(z) unique(z$Final_Intensity) == "Indeterminate")
  incorrect_entries <- incorrect_entries[still_incorrect]

  return(list(data = obs_data,
    indeterminate = incorrect_entries,
    compendium = compendium))
}
