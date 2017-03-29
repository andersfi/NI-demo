######################################3
# Download and parse data
#
# Takes as input a vector of datasetIDs given as IPT DwC download links. 
# Output is a flattend out data.frame with values for the different DwC archives 
#
# Also resolves the GBIFid, this is at the moment done in a for loop out of laziness (very inneficent)
#
######################################

f_download_and_parse_dwc_a <- function(datsets_to_load){
  # libraries needed, install if missing 
  packages.needed <- setdiff(
    c('rgbif', 'finch', 'dplyr', 'tidyr','jsonlite','curl'),
    rownames(installed.packages())
  )
  if(length(packages.needed)) install.packages(packages.needed)
  
  # load libraries
  require("rgbif")
  require("dplyr")
  require("tidyr")
  require("jsonlite")
  require("curl")
  require("finch")

  # Download datasets and merge 
  occurrence <- data.frame(occurrenceID=character())
  event <- data.frame(eventID=character())
  measurementorfact <- data.frame(eventID=character())
  
  for(i in 1:length(datsets_to_load)){
    tmp <- tempfile()
    curl_download(datsets_to_load[i], tmp)
    archive_files <- unzip(tmp, files = "NULL", list = T) 
    unzip(tmp, list = F)
    if("occurrence.txt" %in% archive_files$Name ){
      occurrence_temp <- read.table("occurrence.txt",sep="\t",header = T, stringsAsFactors = FALSE) %>% select(-id)
      occurrence <- bind_rows(occurrence,occurrence_temp)
    }
    if("event.txt" %in% archive_files$Name ){
      event_temp <- read.table("event.txt",sep="\t",header = T, stringsAsFactors = FALSE) %>% select(-id)
      event <- bind_rows(event,event_temp)
    }
    if("measurementorfact.txt" %in% archive_files$Name ){
      measurementorfact_temp <- read.table("measurementorfact.txt",sep="\t",header = T, stringsAsFactors = FALSE) %>% 
        mutate(occurrenceID=id,measurementValue=as.character(measurementValue)) %>% select(-id)
      # mof_temp <- spread(data=measurementorfact_temp,key=measurementType,value=measurementValue)
      measurementorfact <- bind_rows(measurementorfact,measurementorfact_temp)
    }
    if("extendedmeasurementorfact.txt" %in% archive_files$Name ){
      measurementorfact_temp <- read.table("extendedmeasurementorfact.txt",sep="\t",header = T, stringsAsFactors = FALSE) %>% 
        mutate(eventID=id,measurementValue=as.character(measurementValue)) %>% select(-id)
      # mof_temp <- spread(data=measurementorfact_temp,key=measurementType,value=measurementValue)
      measurementorfact <- bind_rows(measurementorfact,measurementorfact_temp)
    }
  }
  
  # spread occurrence measurementandfacts (only intersted in mof's for occurrences in this example)
  measurementorfact_event <- measurementorfact %>% select(occurrenceID,measurementType,measurementValue) 
  mof_temp <- spread(data=measurementorfact_event,key=measurementType,value=measurementValue) # don't realy need to spread this example

  # join together occurrence and event
  outdata <- left_join(occurrence,event)
  outdata <- left_join(outdata,mof_temp)
  
  # attach gbifID to dataframe (using api call in for loop for now - innefficient)
  for(i in 1:dim(outdata)[1]){
  temp  <- try(fromJSON(paste("http://api.gbif.org/v1/occurrence/search?OCCURRENCE_ID=+",outdata$occurrenceID[i],sep=""))$results$key, silent = TRUE)
  if (!is.null(temp)){
    outdata$gbifID[i] <- temp
  } else {
    outdata$gbifID[i] <- NA
  }
  print("resolving:")
  print(i)
  }
  # 
  # # Temporary hack in wait for dataset to get indexed in GBIF
  # for(i in 1:dim(outdata)[1]){
  #   outdata$gbifID[i] <- fromJSON(paste("http://api.gbif.org/v1/occurrence/search?OCCURRENCE_ID=+","urn:uuid:1883389f-1537-4aa1-a7c3-3980930481c3",sep=""))$results$key
  # }
  
  
  return(outdata)
}

# test 
# datsets_to_load <- c("http://data.nina.no:8080/ipt/archive.do?r=freshwater_lake_fish_inventory&v=1.1")
# outdata <- f_download_and_parse_dwc_a(datsets_to_load)
# write.csv(outdata,"outdata.csv")
#get results from one record by occurrenceID and the GBIF AIP
#get_occurrenceID <- fromJSON(paste("http://api.gbif.org/v1/occurrence/search?OCCURRENCE_ID=+",outdata$occurrenceID[123],sep=""))$results$key
#paste("https://demo.gbif.org/occurrence/",get_occurrenceID$key,sep="")

