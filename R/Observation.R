#' Collect and Process Direct Observation Data
#'
#' This provides a free and easy way to document and annotate physical activity
#' behaviors using direct observation
#'
#' @section Core functions:
#'
#' \code{\link{data_collection_program}}
#'
#' \code{\link{compendium_reference}}
#'
#' @examples
#' \dontrun{
#' observation_data <- data_collection_program()
#' full_data <- compendium_reference(observation_data)
#' }
#'
#' @section Associated References:
#' Hibbing PR, Ellingson LD, Dixon PM, & Welk GJ (2017). Adapted Sojourn Models 
#' to Estimate Activity Intensity in Youth: A Suite of Tools. \emph{Medicine and
#' Science in Sports and Exercise}. Advance online publication.
#' doi:10.1249/MSS.0000000000001486
#'
#' @docType package
#' @name Observation
NULL

#' @importFrom svDialogs dlgInput dlgMessage dlgList
NULL