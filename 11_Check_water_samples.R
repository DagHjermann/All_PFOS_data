
library(dplyr)
library(purrr)
library(sp)
# library(rgdal)
library(leaflet)

#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
#            Where are the chemical water sample data sampled?
# ---------------------------------------------------------------------------------
#
# Information for XPANDORA application
# - part 1 is for PFAS
# - part 2 is for HG
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

#
# Functions for filling out missing LONGITUDE, LATITUDE
#

#
# Function 1. To use for rows with X, Y and EPSG value 
#
# Meant to be run using a given epsg_value (projection)
# Picks out the rows with that value, and fills out LONGITUDE/LATITUDE
# To be used with map_dfr() - making one data set per epsg_value, and then joining them
#    together
#
get_longlat <- function(epsg_value, data, xvar = "X", yvar = "Y"){
  crs_longlat <- "+init=epsg:4326"  # longitude/latitude projection
  sel_rows <- data$EPSG_SYS %in% epsg_value
  if (epsg_value != 4326){
    result <- data[sel_rows,]
    crs <- paste0("+init=epsg:", epsg_value)
    dat_spatial <- SpatialPoints(result[, c(xvar, yvar)], proj4string = CRS(crs))
    dat_spatial_longlat <- spTransform(dat_spatial, CRS(crs_longlat))
    result$LONGITUDE <- dat_spatial_longlat@coords[,1]
    result$LATITUDE <- dat_spatial_longlat@coords[,2]
  } else {
    result <- data[sel_rows,]
    result$LONGITUDE <- result[["X"]]
    result$LATITUDE <- result[["Y"]]
  }
  result
}

#
# Function 2
# - uses get_longlat for rows with X, Y and EPSG value
# - uses the original data for rows with LONGITUDE, LATITUDE
#
fill_out_longlat <- function(data){
  bind_rows(
    # 1. Rows with X, Y and EPSG value
    df_coord %>%
      filter(!is.na(EPSG_SYS)) %>%
      pull(EPSG_SYS) %>%
      unique() %>%
      map_dfr(get_longlat, data = df_coord),
    df_coord %>%
      filter(is.na(EPSG_SYS))
  )
}

#
# 1. PFAS
#   Starting with df_values_wat from script 01 ----
#
# Use script 01 to download these again - it's fast   
#

head(df_values_wat, 3)

df_samples <- get_nivabase_selection(
  "*",
  "WATER_SAMPLES", 
  "WATER_SAMPLE_ID",
  unique(df_values_wat$WATER_SAMPLE_ID))

df_stations <- get_nivabase_selection(
  "*",
  "STATIONS", 
  "STATION_ID",
  unique(df_samples$STATION_ID))

# Get coordinates
# - note: both long-lat and UTM
df_coord <- get_nivabase_selection(
  "*",
  "NIVA_GEOMETRY.SAMPLE_POINTS",  table_literal = TRUE,
  "SAMPLE_POINT_ID",
  unique(df_stations$GEOM_REF_ID))

df_coord_longlat <- fill_out_longlat(df_coord)


leaflet() %>%
  addTiles() %>%
  addMarkers(lng = df_coord_longlat$LONGITUDE, lat = df_coord_longlat$LATITUDE,
             popup = df_coord_longlat$ENTERED_DATE)

#
#  
# 2. HG ----
#


# get_nivabase_data("select * from NIVADATABASE.METHOD_DEFINITIONS where rownum < 4" )
df_method <- get_nivabase_data("select METHOD_ID, NAME, UNIT, LABORATORY, MATRIX, CAS, IUPAC from NIVADATABASE.METHOD_DEFINITIONS")

grep("kvikk", df_method$NAME, ignore.case = T, value = TRUE)
sel1 <- grepl("kvikk", df_method$NAME, ignore.case = T) 
df_method$NAME[sel1]

grep("HG", df_method$NAME, ignore.case = F, value = TRUE)
sel2a <- grepl("HG", df_method$NAME, ignore.case = F)
sel2b <- grepl("HCHG", df_method$NAME, ignore.case = F)
sel2 <- sel2a & !sel2b
df_method$NAME[sel2]

vars <- "METHOD_ID, WATER_SAMPLE_ID, VALUE, FLAG1, FLAG2, DETECTION_LIMIT, UNCERTAINTY, QUANTIFICATION_LIMIT"
df_values_wat_hg <- get_nivabase_selection(vars,
                                        "WATER_CHEMISTRY_VALUES", 
                                        "METHOD_ID",
                                        df_method$METHOD_ID[sel1 | sel2])
nrow(df_values_wat_hg) # 4357

# 
# NOTE: the rest of the procedure is identical to code in (1), 
#   except 1 line marked CHANGED 
#
df_samples <- get_nivabase_selection(
  "*",
  "WATER_SAMPLES", 
  "WATER_SAMPLE_ID",
  unique(df_values_wat_hg$WATER_SAMPLE_ID))    # CHANGED

df_stations <- get_nivabase_selection(
  "*",
  "STATIONS", 
  "STATION_ID",
  unique(df_samples$STATION_ID))

# Get coordinates
# - note: both long-lat and UTM
df_coord <- get_nivabase_selection(
  "*",
  "NIVA_GEOMETRY.SAMPLE_POINTS",  table_literal = TRUE,
  "SAMPLE_POINT_ID",
  unique(df_stations$GEOM_REF_ID))

df_coord_longlat <- fill_out_longlat(df_coord)


# Show data on a dynamic map (in web browser, or in RStudio)
leaflet() %>%
  addTiles() %>%
  addMarkers(lng = df_coord_longlat$LONGITUDE, lat = df_coord_longlat$LATITUDE,
             popup = df_coord_longlat$ENTERED_DATE)



