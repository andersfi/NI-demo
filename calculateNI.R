####################################################
#
# Calculate NI - demo script
#
# 1. Download and parse data trough external function (func_download_and_parse)
# 2. Attach data to wanted administrative area using coordinates
# 3. Calculate NI indicator for that area - at moment using a bogus function for demo purpose
# 4. Attach the caculated NI indicator to "NI database", which for this demo purpose only is a 
# spatialPolygonDataframe with admin areas. 
# 5 Save this "database" as RDS file for use in visualization tool
#
#################################################################



# libraries
  packages.needed <- setdiff(
    c('sp','rmapshaper'),
    rownames(installed.packages())
  )
  if(length(packages.needed)) install.packages(packages.needed)
  
  # load libraries
  require("sp")
  require("rmapshaper")

# extarnal functions needed 
source("func_download_and_parse.R")

#........................................
# Get data
#........................................


# Download from datasets (character vector of dataset IPT adresses: 
datsets_to_load <- c(
    "http://data.nina.no:8080/ipt/archive.do?r=freshwater_lake_fish_inventory&v=1.1"
  )
  
outdata <- f_download_and_parse_dwc_a(datsets_to_load)

#................................................................................
# Filter data (here, just simple filtering of all records without lat/long info)
#..................................................................................
outdata <- outdata %>% filter(!is.na(decimalLatitude),!is.na(decimalLongitude)) # remove datapoint

#........................................
# Assign municipality to data 
# see http://www.maths.lancs.ac.uk/~rowlings/Teaching/UseR2012/cheatsheet.html
#........................................
crs.geo <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")  # geographical, datum WGS84
# read inn admin boarders for classification
munic_sp <- readRDS("NOR_adm2.rds")
county_sp <- readRDS("NOR_adm1.rds")
munic_sp <- spTransform(munic_sp,crs.geo)
county_sp <- spTransform(county_sp,crs.geo)
#plot(county_sp)

# make flattend out dwc-a a spatialPointDataframe
coords = cbind(outdata$decimalLongitude, outdata$decimalLatitude)
sp = SpatialPoints(coords)
dataout_spdf = SpatialPointsDataFrame(sp, outdata)
proj4string(dataout_spdf) <- crs.geo  # define projection 

# get county/muncipalityID of outdata
dataout_spdf@data$countyID <- (dataout_spdf %over% county_sp)$ID_1
dataout_spdf@data$municipalityID <- (dataout_spdf %over% munic_sp)$ID_2
dataout_spdf@data$municipality2 <- (dataout_spdf %over% munic_sp)$NAME_2

# back to dataframe
datainn <- as.data.frame(dataout_spdf)


# calculate index pr county
stable <- datainn %>% filter(populationTrend=="stable") %>% group_by(countyID) %>% summarize(stable=n())
increasing <- datainn %>% filter(populationTrend=="increasing") %>% group_by(countyID) %>% summarize(increasing=n())
decreasing <- datainn %>% filter(populationTrend=="decreasing") %>% group_by(countyID) %>% summarize(decreasing=n())
introduction <- datainn %>% filter(populationTrend=="introduction") %>% group_by(countyID) %>% summarize(introductions=n())
total <- datainn %>% filter(!is.na(populationTrend)) %>% group_by(countyID) %>% summarize(total = n())
dataused <- datainn %>% filter(!is.na(populationTrend)) %>% group_by(countyID) %>% 
  summarise(dataused=paste("http://www.gbif.org/occurrence/",gbifID, collapse="|",sep=""),
            occurrenceID=paste(occurrenceID, collapse="|",sep=""))

NI <- left_join(total,decreasing)
NI <- left_join(NI,introduction)
NI <- left_join(NI,increasing)
NI <- left_join(NI,stable)
NI <- left_join(NI,dataused)
NI[is.na(NI)] <- 0

NI <- NI %>% mutate(NI = 1 - (decreasing/total))
NImunic <- NI
NIcounty <- NI %>% mutate(ID_1=countyID)
county_sp2 <- merge(county_sp,NIcounty)

county_sp2 <- rmapshaper::ms_simplify(county_sp2,keep = 0.001)


saveRDS(county_sp2,"county_sp2.RDS")









