#' Collect Direct Observation Data
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
        dlgInput(message = 'Record the start time of the event. Press enter for current time.',
          default = Sys.time())$res

      if(length(new_timestamp)==0) new_timestamp <- ''
      timestamps <- c(timestamps, new_timestamp)

      new_activity <-
        dlgInput(message = paste('Enter label for activity',
          length(timestamps)))$res

      if(length(new_activity)==0) new_activity   <- ''
      activities <- c(activities, new_activity)

      descriptions <- rbind(descriptions, tree.intensity())

      pauser <-
        dlgInput(message = 'Press Enter when the next activity begins. Press cancel to quit.',
          default = 'Enter for next activity. Cancel to quit')$res
      n                                          <- n+1
      if(length(pauser)==0) {
        finish <-
          if(n>1) {
            c(get.minofday.rat(timestamps[2:length(timestamps)]),
              get.minofday.rat(Sys.time()))
          } else {
          ''
          }
        break
      }

    }

    # Cleanup

    diff_s <-
      if (n > 1){
        (finish - get.minofday.rat(timestamps)) * 60
      } else{
      ''
      }

    backup_timestamps <-
      get.minofday.rat(ifelse(timestamps == '',
        auto_timestamps, timestamps))

    backup_finish <-
      if (n>1) {
      c(backup_timestamps[2:length(backup_timestamps)],
        finish[length(finish)])
      } else {
        ''
      }

    backup_diff_s <- (backup_finish - backup_timestamps)*60

    minofday <-
      get.minofday.rat(ifelse(timestamps=='',
        auto_timestamps, timestamps))

    dayofyear <-
      get.dayofyear(ifelse(timestamps=='',
        auto_timestamps, timestamps))


    data <-
      data.frame(User_Timestamp = timestamps,
        Auto_Timestamp = auto_timestamps,
        dayofyear = dayofyear,
        minofday = minofday,
        Activity = activities,
        duration_s = diff_s,
        auto_duration_s = backup_diff_s,
        stringsAsFactors = FALSE)

    data <- cbind(data,descriptions)

    return(data)
    }

### FUNCTIONS CALLED BY PROGRAM

  get.dayofyear <- function(date, format = '%Y-%m-%d %H:%M:%S'){
    as.integer(strftime(as.POSIXlt(date, format = format), format = '%j'))}

  get.minofday.rat <- function(date, format = '%Y-%m-%d %H:%M:%S'){
    as.integer(strftime(as.POSIXlt(date, format = format), format = '%H'))*60 +
      as.integer(strftime(as.POSIXlt(date, format = format), format = '%M')) +
      as.integer(strftime(as.POSIXlt(date, format = format), format = '%S'))/60
  }

  tree.intensity <- function(){

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

      #-----------------------------------------------------------------------------------#

      seated               <- dlgMessage('Seated?','yesnocancel',)$res
      if(seated=='cancel') break

      #-----------------------------------------------------------------------------------#

      large_muscles_moving <- dlgMessage('Large Muscles Contracting?','yesnocancel')$res

      if(large_muscles_moving=='cancel')                                      break
      if(seated=='yes'&large_muscles_moving=='no') {Intensity <- 'Sedentary' ; break}
      if(seated=='no'&large_muscles_moving=='no')  {Intensity <- 'Light'     ; break}

      #-----------------------------------------------------------------------------------#

      slow                 <- dlgMessage('Slow?','yesnocancel')$res

      if(slow=='cancel')                                                       break
      if(seated=='yes'&large_muscles_moving=='yes'&slow=='no')                 break

      #-----------------------------------------------------------------------------------#
      if(slow=='yes'){
      slowed_by_resistance <- dlgMessage('Slowed by resistance?','yesnocancel')$res

      if(slowed_by_resistance=='cancel')                                       break
      if(seated=='yes'&large_muscles_moving=='yes'&slow=='yes'&
           slowed_by_resistance=='no')       {Intensity <- 'Sedentary/Light' ; break}
      if(seated=='yes'&large_muscles_moving=='yes'&slow=='yes'&
           slowed_by_resistance=='yes')      {Intensity <- 'Light/Moderate'  ; break}
      if(seated=='no'&large_muscles_moving=='yes'&slow=='yes'&
           slowed_by_resistance=='no')       {Intensity <- 'Light'           ; break}
      if(seated=='no'&large_muscles_moving=='yes'&slow=='yes'&
           slowed_by_resistance=='yes')      {Intensity <- 'Light/Moderate'  ; break}
      }

      #-----------------------------------------------------------------------------------#

      ambulation           <- dlgMessage('Ambulation?','yesnocancel')$res

      if(ambulation=='cancel')                                                break
      if(seated=='no'&large_muscles_moving=='yes'&slow=='no'&
           ambulation=='no')                 {Intensity <- 'Light/Moderate'  ; break}

      #-----------------------------------------------------------------------------------#

      light_walking        <- dlgMessage('Walking speed resembles pacing?','yesnocancel')$res
      if(light_walking=='no')                {Intensity <- 'MVPA'            ; break}
      if(light_walking=='yes')               {Intensity <- 'Light'           ; break}
      break
    }


    latest_description <- data.frame(Tree_Intensity = Intensity, seated, large_muscles_moving,slow,slowed_by_resistance,ambulation,light_walking, stringsAsFactors = F)
    if(length(which(latest_description=='cancel'))!=0) latest_description[,match('cancel',latest_description):length(latest_description)] <- NA
    return(latest_description)}





compendium.reference <- function(data){

### Load and code
    load('2011 Compendium.RData', globalenv())

    agegroup_setting = dlgMessage('Will you be coding for kids?', 'yesno')$res
    category_setting = dlgMessage('Will you be coding with MVPA as one category?', 'yesno')$res

    breaks        = c(0, 1.5, 3, 6, Inf)
    childbreaks   = c(0, 2,   4, 6, Inf)

    if(category_setting=='yes'){
      breaks      = breaks[-4]
      childbreaks = childbreaks[-4]
    }

    labels         = c('Sedentary', 'Light', 'Moderate','Vigorous')
    threecatlabels = c('Sedentary', 'Light', 'MVPA')

    compendium$Intensity <- cut(compendium$METS, breaks = if(agegroup_setting=='yes') childbreaks    else breaks,
                                labels = if(category_setting=='yes') threecatlabels else labels,
                                right = FALSE)

    levels = levels(compendium$Intensity)

    data$Tree_Intensity <- gsub('Moderate', 'MVPA', data$Tree_Intensity)  # Move these to the actual program
    data$Tree_Intensity <- gsub('Vigorous', 'MVPA', data$Tree_Intensity)

    compendium <- compendium[with(compendium, order(Intensity, Activity)),]

### Is this the first time the data are being coded?
    firstloop    <- TRUE
    if(sum(grepl('Final_Intensity' , names(data)))>0){
      firstloop  <- FALSE
      completed  <- data$Final_Intensity %in% levels
      oldentries <- data[completed, ]
      data       <- data[!completed, ]
    }

### Find possible matches based on Activity description
    correct_intensity <- data$Tree_Intensity %in% levels

    incorrect_entries   <- strsplit(data$Activity[!correct_intensity], ' ')
    incorrect_entries   <- lapply(incorrect_entries, function(x) gsub('ing','',x))
    incorrect_entries   <- lapply(incorrect_entries, function(x) gsub('ed','',x))

    incorrect_entries   <- lapply(incorrect_entries, function(x){
      matches <- unlist(lapply(x, function(y){
        which(grepl(y, compendium$Activity, ignore.case = T))}))

      test <- if(sum(matches)==0) compendium else compendium[matches,]
      return(test)
    }
    ) ### This returns a data frame for each observation partition with a short list of
    ### possible corresponding compendium activities based solely on primitive string matching

### Append tree intensity and original entry to each entry in the aforementioned list
    incorrect_intensities <- data$Tree_Intensity[!correct_intensity]
    if(category_setting!='yes'){
      incorrect_intensities <- gsub('MVPA','Moderate Vigorous', incorrect_intensities)
    }

    incorrect_activities  <- data$Activity[!correct_intensity]

    incorrect_entries     <- mapply(function(x,y) {x$Tree_Intensity <- rep(incorrect_intensities[y], nrow(x))
                                                   x$Original_Entry <- rep(incorrect_activities[y], nrow(x))
                                                   return(x)},
                                    x = incorrect_entries, y = seq_along(incorrect_intensities),SIMPLIFY = F)

    ### This is just a convoluted indexing call that gets a copy of the original tree
    ### intensity and the user-inputted activity description for every potential match
    ### from the compendium.

### Remove possibilities outside the tree-designated range
    incorrect_entries <- lapply(incorrect_entries, function(x) {
      qualifies <- sapply(x$Intensity,
                          function(y) grepl(y, x$Tree_Intensity[1],
                                            ignore.case = T))
      x         <- if(x$Tree_Intensity[1]!='Indeterminate') x[qualifies,] else x
      return(x)
    }
    ) ### This is another sadly convoluted step. It just cleans up instances where the
    ### tree said light/MVPA but a potential match with a sedentary activity was found

### If all compendium possibilities are the same, set to that; otherwise, get help
    incorrect_entries <- comp.lookup(incorrect_entries, Levels = levels, Compendium = compendium)


### Pull it all together
    incorrect_entries <- do.call(rbind, incorrect_entries)
    data$Final_Intensity <- data$Tree_Intensity   ### Initialize to tree value. Then we'll correct the ones that are wrong.

    data$Final_Intensity <- mapply(
      function(x,y){
        y <-  ifelse(x %in% incorrect_entries$Original_Entry,
                     as.character(incorrect_entries$Final_Intensity[match(x, incorrect_entries$Original_Entry)]),
                     y)
        return(y)
      },
      x = data$Activity, y = data$Final_Intensity)
rm(compendium, envir = globalenv())

  if(!firstloop){
    data <- rbind(oldentries, data)
  }

data$Final_Intensity <- factor(data$Final_Intensity, levels = levels)
dlgMessage('Done Coding.', 'ok')
return(data[order(data$Auto_Timestamp),])
}

  #*******************************************************************************************#
  #*******************************************************************************************#
  #*******************************************************************************************#

### Helper function for activity coding process


comp.lookup <- function(incorrect_entries, Levels, Compendium = compendium){
  lapply(incorrect_entries, function(z){
                              keep <- 0
                              if(nrow(z)>1) keep <- sd(as.numeric(z$Intensity))

                              if(keep==0){
                                z$Final_Intensity <- z$Intensity
                              } else{
                                title <- paste('Select closest match for: ', toupper(z$Original_Entry[1]),'. Press cancel if no matches are given.', sep = '')
                                Activity <- dlgList(with(z, paste('Rating:',Intensity,'\n  ',METS,'METs\n  ',Activity)),
                                                    title = title)$res

                                if(length(Activity)==0){
                                  qualifies <- sapply(Compendium$Intensity,
                                                      function(y) {
                                                                   grepl(y, z$Tree_Intensity[1], ignore.case = T) |
                                                                     z$Tree_Intensity[1]=='Indeterminate'})

                                  Activity <- dlgList(paste('Rating:',Compendium$Intensity[qualifies],'\n',
                                                            Compendium$METS[qualifies], 'METs\n',
                                                            Compendium$Activity[qualifies]),
                                                      title = 'You pressed cancel. Please select match from whole list.')$res}

                                if(length(Activity)==0){message(paste('No reference value selected for ',toupper(z$Original_Entry[1]), '. Returning original tree form.', sep = ''))
                                                        z$Final_Intensity <- z$Tree_Intensity}

                                if(length(Activity)!=0){
                                  comp_intensity <- unlist(strsplit(Activity, '\n'))
                                  comp_intensity <- comp_intensity[which(grepl('Rating',comp_intensity, ignore.case = T))]
                                  comp_intensity <- Levels[which(sapply(Levels, function(z) grepl(z, comp_intensity, ignore.case = T)))]

                                  z$Final_Intensity <- comp_intensity}
                              }

              return(z[1,])
            }
    )
}
