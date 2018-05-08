#' Collect and Process Physical Activity Direct Observation Data
#'
#' This provides a free and easy way to document and annotate physical activity
#' behaviors using direct observation.
#'
#' @section Core functions:
#'
#' \code{\link{data_collection_program}}
#'
#' \code{\link{compendium_reference}}
#'
#' @examples
#' \dontrun{
#' # Note: `Observation` functions accept further arguments that are passed to
#' # functions from the `svDialogs` package. Doing so may improve your
#' # experience using the `Observation` package. See the package vignette for
#' # more information.
#'
#' data(example_data)
#' compendium_reference(example_data)
#'
#' observation_data <- data_collection_program()
#' full_data <- compendium_reference(observation_data)
#' }
#'
#' @section Associated References:
#' Hibbing PR, Ellingson LD, Dixon PM, & Welk GJ (2018). Adapted Sojourn Models
#' to Estimate Activity Intensity in Youth: A Suite of Tools. \emph{Medicine and
#' Science in Sports and Exercise}. 50(4), 846-854.
#' doi:10.1249/MSS.0000000000001486.
#'
#' @docType package
#' @name Observation
NULL

#' @import svDialogs AGread
NULL

#' @importFrom stats sd
NULL
