
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
#            Where are the chemical water sample data sampled?
# ---------------------------------------------------------------------------------
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

#
# 1. Starting with df_values_wat from script 01 ----
#
# Download these again - much more data now than in saved files   
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

library(sp)
library(rgdal)

epsg_values <- unique(df_coord$EPSG_SYS)

get_longlat <- function(epsg_value, data, xvar = "X", yvar = "Y"){
  crs_longlat <- "+init=epsg:4326"
  sel_rows <- data$EPSG_SYS %in% epsg_value
  if (epsg_value != 4326){
    result <- data[sel_rows,]
    crs <- paste0("+init=epsg:", epsg_value)
    dat_spatial <- SpatialPoints(result[, c(xvar, yvar)], proj4string = CRS(crs))
    dat_spatial_longlat <- spTransform(dat_spatial, CRS(crs_longlat))
    result$Long <- dat_spatial_longlat@coords[,1]
    result$Lat <- dat_spatial_longlat@coords[,2]
  } else {
    result <- data[sel_rows,]
    result$Long <- result[["X"]]
    result$Lat <- result[["Y"]]
  }
  result
}

# Test
# get_longlat(32632, df_coord)
# get_longlat(32633, df_coord)
# get_longlat(4326, df_coord)

df_coord_longlat <- epsg_values %>%
  map_dfr(get_longlat, data = df_coord)


# Show data on a dynamic map (in web browser, or in RStudio)
library(leaflet)
leaflet() %>%
  addTiles() %>%
  addMarkers(lng = df_coord_longlat$Long, lat = df_coord_longlat$Lat,
             popup = df_coord_longlat$ENTERED_DATE)


