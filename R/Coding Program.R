#Note: To use this file, make sure RStudio was not already opened before
#you opened this file (Coding Program.R). If you enter getwd() into the
#console (bottom left pane) it should print out the folder where this
#file is stored. If not, close RStudio and re-open this file.

### Individual Trial
  rm(list=ls())
  source('Direct Observation Program and Functions.R')
  package.manager()
  
  id <- dlgInput(message = 'Enter the participant ID', default = '000')$res
  
  data <- data_collection_program()
  data$id <- id ; data <- data[,c('id',setdiff(names(data),'id'))]
 
### Make Compendium corrections to undecided activity intensities
  test <- compendium.reference(data)  # Safest to test the data under a
                                      #different name, then re-name when success
                                      #is demonstrated.

  #test <- compendium.reference(test)  # This is for if you need to re-code anything
  data <- test
  
  #destination <- choose.dir(caption = 'Select the folder to save data in')
  ## ^^^ This is an easy way to save somewhere besides the folder you started in
  destination = getwd()
  assign(id, data)
  save(list = id, file = file.path(destination, paste(id,'RData', sep = '.')))

### Append All Data (if you already have other DO files saved in the foler
  # that you want to combine with this one)
  rm(list=ls())
  
  #datadir <- choose.dir(caption = 'Select folder where data are stored')
  #^^ Again, an easy way to choose where the script should be looking for
  #DO files
  datadir <- getwd()
  files <- list.files(datadir, full.names = T, pattern = '.RData')
  files <- files[!grepl('Compendium', files)]
  invisible(lapply(files, function(x) {load(x, globalenv())}))

  observations <- ls()[!ls()%in%c('datadir','files')]
  total <- do.call(rbind, lapply(observations, get))
  #destination <- choose.dir(caption = 'Select the folder to save aggregated data in')
  #^^ One more time with the easy way to pick a folder to save in.
  destination <- getwd()
  save(total, file = file.path(destination, 'Direct Observation TOTAL.RData'))
  write.csv(total, file = file.path(destination, 'Direct Observation TOTAL.csv'), row.names = F)
  #^^ I recommend installing the data.table package and using data.table::fwrite()
  #instead of read.csv. It's much faster, but I didn't build it in to this
  #version of the code...