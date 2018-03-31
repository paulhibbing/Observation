#' Collect direct observation data
#'
#' @return A data frame of observation data
#' @export
#'
#' @examples
#' \dontrun{
#' data_collection_program()
#' }
data_collection_program <- function(){

    # Initialize

    id <-
      dlgInput(message = 'Enter the participant ID', default = '000')$res
    timestamps      <- NULL
    activities      <- NULL
    descriptions    <- NULL
    auto_timestamps <- NULL
    n               <- 0

    # Main Loop

    repeat{
      auto_timestamps <-
        c(auto_timestamps, as.character(Sys.time()))

      new_timestamp <-
        dlgInput(
          message = 'Record the start time of the event.
            Press enter for current time.',
          default = Sys.time())$res

      if(length(new_timestamp)==0) new_timestamp <- ''
      timestamps <- c(timestamps, new_timestamp)

      new_activity <-
        dlgInput(
          message = paste('Enter label for activity',
            length(timestamps)))$res

      if(length(new_activity)==0) new_activity   <- ''
      activities <- c(activities, new_activity)

      descriptions <- rbind(descriptions, tree_intensity())

      pauser <-
        dlgInput(
          message = 'Press Enter when the next activity begins.
          Press cancel to quit.',
          default = 'Enter for next activity. Cancel to quit')$res

      n <- n+1

      if(length(pauser)==0) {
        finish <- Sys.time()
        #   if(n>1) {
        #     c(
        #       get_minute(timestamps[2:length(timestamps)],
        #         rational = TRUE),
              # get_minute(Sys.time(),
              #   rational = TRUE)
        #     )
        #   } else {
        #   ''
        #   }
        break
      }

    }

    # Cleanup

    diff_s <-
      as.numeric(diff.POSIXt(c(as.POSIXct(timestamps), finish)))
      # if (n > 1){
      #   (finish -
      #       get_minute(timestamps,
      #         rational = TRUE)) * 60
      # } else{
      # ''
      # }

    backup_timestamps <-
      # get_minute(
        ifelse(timestamps == '', auto_timestamps, timestamps)
        # rational = TRUE)

    backup_diff_s <- ##Previously named backup_finish
      as.numeric(diff.POSIXt(c(as.POSIXct(backup_timestamps), finish)))
      # if (n>1) {
      # c(backup_timestamps[2:length(backup_timestamps)],
      #   finish[length(finish)])
      # } else {
      #   ''
      # }

    # backup_diff_s <-
    #   abs((backup_finish - diff_s))#*60

    minofday <-
      get_minute(
        ifelse(timestamps=='', auto_timestamps, timestamps),
        rational = TRUE)

    dayofyear <-
      get_day_of_year(
        ifelse(timestamps=='', auto_timestamps, timestamps))

    all_data <-
      data.frame(User_Timestamp = timestamps,
        Auto_Timestamp = auto_timestamps,
        dayofyear = dayofyear,
        minofday = minofday,
        Activity = activities,
        duration_s = diff_s,
        auto_duration_s = backup_diff_s,
        stringsAsFactors = FALSE)

    all_data <- cbind(all_data,descriptions)

    all_data$id <- id
    all_data <- all_data[ ,c("id", setdiff(names(all_data), "id"))]
    return(all_data)
    }

### FUNCTIONS CALLED BY PROGRAM

#' Pre-classify activity intensity
#'
#' This is the decision tree to pre-classify intensity.
#' See the Figure at the end of Supplemental Document 3 from
#' \href{http://links.lww.com/MSS/B103}{Hibbing et al.
#' (2018, *Med Sci Sports Exerc*)}. NOTE: The link will download the document.
#'
#' @keywords internal
#'
tree_intensity <- function(){

    ## Initialize
    seated               <- 'cancel'
    large_muscles_moving <- 'cancel'
    slow                 <- 'cancel'
    slowed_by_resistance <- 'cancel'
    ambulation           <- 'cancel'
    light_walking        <- 'cancel'
    Intensity            <- 'Indeterminate'

    #### DECISION TREE ####
    repeat{

      seated <- dlgMessage('Seated?','yesnocancel')$res
      if(seated=='cancel') break

      large_muscles_moving <-
        dlgMessage('Large Muscles Contracting?','yesnocancel')$res

      if (large_muscles_moving=='cancel') break
      if (seated=='yes'&large_muscles_moving=='no') {
        Intensity <- 'Sedentary'
        break
      }

      if (seated=='no'&large_muscles_moving=='no') {
        Intensity <- 'Light'
        break
      }

      slow <-
        dlgMessage('Slow?','yesnocancel')$res

      if (slow=='cancel') break
      if (seated=='yes'&large_muscles_moving=='yes'&slow=='no') break

      if (slow=='yes') {
      slowed_by_resistance <-
        dlgMessage('Slowed by resistance?','yesnocancel')$res

      if(slowed_by_resistance=='cancel') break
      if(seated=='yes'&large_muscles_moving=='yes'&slow=='yes'&
           slowed_by_resistance=='no') {
        Intensity <- 'Sedentary/Light'
        break
      }
      if (seated=='yes'&large_muscles_moving=='yes'&slow=='yes'&
           slowed_by_resistance=='yes') {
        Intensity <- 'Light/Moderate'
        break
      }
      if (seated=='no'&large_muscles_moving=='yes'&slow=='yes'&
           slowed_by_resistance=='no') {
        Intensity <- 'Light'
        break
      }
      if (seated=='no'&large_muscles_moving=='yes'&slow=='yes'&
           slowed_by_resistance=='yes') {
        Intensity <- 'Light/Moderate'
        break
      }
      }

      ambulation <-
        dlgMessage('Ambulation?','yesnocancel')$res

      if (ambulation=='cancel') break
      if (seated=='no'&large_muscles_moving=='yes'&slow=='no'&
           ambulation=='no') {
        Intensity <- 'Light/Moderate'
        break
      }

      light_walking <-
        dlgMessage('Walking speed resembles pacing?','yesnocancel')$res
      if (light_walking=='no') {
        Intensity <- 'MVPA'
        break
      }
      if (light_walking=='yes') {
        Intensity <- 'Light'
        break
      }
      break
    }


    latest_description <-
      data.frame(
        Tree_Intensity = Intensity,
        seated,
        large_muscles_moving,
        slow,
        slowed_by_resistance,
        ambulation,
        light_walking,
        stringsAsFactors = F
      )

    if (length(which(latest_description=='cancel'))!=0) {
      latest_description[ ,match('cancel',
        latest_description):length(latest_description)] <- NA
    }
    return(latest_description)
  }

#' Consult
#' \href{https://sites.google.com/site/compendiumofphysicalactivities/}{Compendium
#' of Physical Activities} to Encode Direct Observation Intensities
#'
#' @param obs_data A data frame outputted from
#'   \code{\link{data_collection_program}}
#'
#' @return A data frame fully annotated with intensity values
#' @export
#'
#' @examples
#' \dontrun{
#' observation_data <- data_collection_program()
#' compendium_reference(observation_data)
#' }
compendium_reference <- function(obs_data){

    agegroup_setting <-
      dlgMessage('Will you be coding for kids?', 'yesno')$res
    category_setting <-
      dlgMessage('Will you be coding with MVPA as one category?', 'yesno')$res

    breaks <- c(0, 1.5, 3, 6, Inf)
    childbreaks <- c(0, 2,   4, 6, Inf)

    if(category_setting=='yes'){
      breaks      = breaks[-4]
      childbreaks = childbreaks[-4]
    }

    labels <- c('Sedentary', 'Light', 'Moderate','Vigorous')
    threecatlabels <- c('Sedentary', 'Light', 'MVPA')

    compendium$Intensity <-
      cut(compendium$METS,
        breaks = if(agegroup_setting=='yes') childbreaks    else breaks,
        labels = if(category_setting=='yes') threecatlabels else labels,
        right = FALSE)

    levels <- levels(compendium$Intensity)

    obs_data$Tree_Intensity <-
      gsub('Moderate', 'MVPA', obs_data$Tree_Intensity)

    obs_data$Tree_Intensity <-
      gsub('Vigorous', 'MVPA', obs_data$Tree_Intensity)

    compendium <-
      compendium[with(compendium, order(Intensity, Activity)),]

    ### Is this the first time the data are being coded?
    firstloop    <- TRUE
    if(sum(grepl('Final_Intensity' , names(obs_data)))>0){
      firstloop  <- FALSE
      completed  <- obs_data$Final_Intensity %in% levels
      oldentries <- obs_data[completed, ]
      obs_data       <- obs_data[!completed, ]
    }

    ### Find possible matches based on Activity description
    correct_intensity <- obs_data$Tree_Intensity %in% levels

    incorrect_entries <-
      strsplit(obs_data$Activity[!correct_intensity], ' ')
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

    ### Append tree intensity and original entry to each entry in the aforementioned list
    incorrect_intensities <-
      obs_data$Tree_Intensity[!correct_intensity]
    if(category_setting!='yes'){
      incorrect_intensities <- gsub('MVPA','Moderate Vigorous', incorrect_intensities)
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
        y = seq_along(incorrect_intensities),
        SIMPLIFY = F)

    ### This is just a convoluted indexing call that gets a copy of the original tree
    ### intensity and the user-inputted activity description for every potential match
    ### from the compendium.

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
    ### This is another sadly convoluted step. It just cleans up instances where the
    ### tree said light/MVPA but a potential match with a sedentary activity was found

    ### If all compendium possibilities are the same, set to that; otherwise, get help
    incorrect_entries <-
      comp_lookup(incorrect_entries,
        Levels = levels,
        compendium = compendium)

    ### Pull it all together
    incorrect_entries <-
      do.call(rbind, incorrect_entries)
    obs_data$Final_Intensity <-
      obs_data$Tree_Intensity
    ### Initialize to tree value. Then we'll correct the ones that are wrong.

    obs_data$Final_Intensity <- mapply(function(x, y) {
      y <-  ifelse(
        x %in% incorrect_entries$Original_Entry,
        as.character(
          incorrect_entries$Final_Intensity[match(x,
            incorrect_entries$Original_Entry)]
          ),
        y
      )
      return(y)
    },
      x = obs_data$Activity,
      y = obs_data$Final_Intensity)

  if(!firstloop){
    obs_data <- rbind(oldentries, obs_data)
  }

  obs_data$Final_Intensity <- factor(obs_data$Final_Intensity, levels = levels)
  dlgMessage('Done Coding.', 'ok')
  return(obs_data[order(obs_data$Auto_Timestamp),])
  }

#' Helper function for intensity coding process.
#'
#' Interface for looking up Compendium values to assign an intensity to an
#' activity.
#'
#' @param incorrect_entries A vector of activities that have not been correctly coded yet
#' @param Levels A vector of intensity levels from which to select
#' @param compendium A version compendium, passed from
#'   \code{compendium_reference}, that has been modified to reflect the
#'   intensity selections made in that function
#'
#' @keywords internal
#'
comp_lookup <- function(incorrect_entries, Levels, compendium){
  lapply(incorrect_entries,
    function(z){
      # z <- incorrect_entries[[1]]
    keep <- 0
    if(nrow(z)>1) keep <- sd(as.numeric(z$Intensity))
    if(keep==0){
      z$Final_Intensity <- z$Intensity
      } else{
        title <-
          paste('Select closest match for: ',
            toupper(z$Original_Entry[1]),
            '. Press cancel if no matches are given.',
            sep = '')
      Activity <-
        dlgList(with(z,
          paste('Rating:',
            Intensity,
            '\n  ',
            METS,'METs\n  ',
            Activity)),
            title = title)$res

      if(length(Activity)==0){
        qualifies <- sapply(compendium$Intensity,
          function(y) {
            grepl(y, z$Tree_Intensity[1], ignore.case = TRUE) |
            z$Tree_Intensity[1]=='Indeterminate'}
          )

        Activity <-
          dlgList(
            paste(
              'Rating:',
              compendium$Intensity[qualifies],
              '\n',
              compendium$METS[qualifies],
              'METs\n',
              compendium$Activity[qualifies]
            ),
            title = 'You pressed cancel. Please select match from whole list.'
          )$res
        }
      if (length(Activity)==0) {
        message(
          paste(
            'No reference value selected for ',
            toupper(z$Original_Entry[1]),
            '. Returning original tree form.',
            sep = ''
          )
        )
        z$Final_Intensity <-
          z$Tree_Intensity}

      if (length(Activity) != 0) {
        comp_intensity <- unlist(strsplit(Activity, '\n'))
        comp_intensity <-
          comp_intensity[which(grepl('Rating', comp_intensity, ignore.case = T))]
        comp_intensity <-
          Levels[which(sapply(Levels, function(z)
            grepl(z, comp_intensity, ignore.case = T)))]

        z$Final_Intensity <-
          comp_intensity
      }
      }

    return(z[1, ])
            }
    )
}
