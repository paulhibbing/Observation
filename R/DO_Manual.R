#' Manually Consult the
#' \href{https://sites.google.com/site/compendiumofphysicalactivities/}{Compendium
#' of Physical Activities} to Encode Direct Observation Intensities
#'
#' @param obs_data A data frame outputted from
#'   \code{\link{data_collection_program_manual}}
#'
#'
#' @return A data frame fully annotated with intensity values
#' @keywords internal
compendium_reference_manual <- function(obs_data){
    return(NULL)
}

#' Helper Function for Manual Intensity Coding Process.
#'
#' Automatic method for looking up Compendium values to assign an intensity to
#' an activity.
#'
#' @param incorrect_entries A vector of activities that have not been correctly coded yet
#' @param Levels A vector of intensity levels from which to select
#' @param compendium A version compendium, passed from
#'   \code{compendium_reference_interactive}, that has been modified to reflect the
#'   intensity selections made in that function
#' @inheritParams data_collection_program_interactive
#'
#' @keywords internal
#'
comp_lookup_manual <- function(incorrect_entries, Levels, compendium, ...){
        return(NULL)
}
