
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#
# SEE 71 ('Data from Merete' for updated stuff!  
#
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-

#
# Based on 'C:\Data\seksjon 318\get-fresh-temp\01_Explore_temp_data.Rmd'
#
library(dplyr)
library(niRvana)
library(purrr)
library(ggplot2)
library(lubridate)   # year()

# Input your NIVAbasen username/password
set_credentials()

# From selected records in LABWARE_CHECK_SAMPLE, check data in Merete's dataset
get_matrix_species <- function(df_nivabasen){
  limscodes <- df_nivabasen %>% 
    pull(TEXT_ID)
  dat %>%
    filter(LIMS %in% limscodes) %>%
    count(Matrix_orig, Species)
}

# From selected records in LABWARE_CHECK_SAMPLE, change LIMS code to 12 characters and check data
#   in Merete's dataset
get_matrix_species_12char <- function(df_nivabasen){
  limscodes <- df_nivabasen %>% 
    mutate(TEXT_ID_12 = paste0(substr(TEXT_ID, 1, 8), substr(TEXT_ID, 10, 13))) %>%
    pull(TEXT_ID_12)
  dat %>%
    filter(LIMS %in% limscodes) %>%
    count(Matrix_orig, Species)
}

## End(Not run)



# Data from Merete Grung
dat <- readxl::read_excel("Input_data/001 PFAS stacked data table.xlsx", guess_max = 11000)
# A few errors in the 'PFASlength' variable
dat$LIMS %>% head(100)
tab <- table(dat$LIMS)
length(tab)
limscodes <- names(tab)


# Test
# df_check <- get_nivabase_data("select * from NIVADATABASE.LABWARE_CHECK_SAMPLE where ACCOUNT_NUMBER in (426,427,650,658)")
# head(df_check, 3)
# df_check$TEXT_ID %>% head(100)

#
# Check codes ----
#

# Format of limscodes - should be 13 characters long
table(nchar(limscodes)) 
# 8   12   13   14   15   17   19   20   22   23   25 
# 1  119 1659  916   90   15    1    3    1    3    1 

#
# . 13 characters - don't need to be changed ----
#
x <- limscodes[nchar(limscodes) == 13]
head(x, 50)
limscodes_13char <- x
length(limscodes_13char)

df_check_list <- list(1:500, 501:1000, 1001:1500, 1501:length(limscodes_13char)) %>%
  map(~get_nivabase_selection(
    "TEXT_ID,PROSJEKT,SAMPLE_TYPE,SAMPLED_DATE,DESCRIPTION,AQUAMONITOR_ID,AQUAMONITOR_CODE,AQUAMONITOR_NAME,SPECIES,TISSUE,BIOTA_SAMPLENO",
    "LABWARE_CHECK_SAMPLE",
    "TEXT_ID",
    limscodes_13char[.],
    values_are_text = TRUE))
df_check <- bind_rows(df_check_list)
nrow(df_check) # 953
df_check %>%
  count(SAMPLE_TYPE, SPECIES)
#  SAMPLE_TYPE   SPECIES                 n
#  1 AVL<d8>PSVANN NA                      2
#  2 BIOTA         Clupea harengus        12
#  3 BIOTA         Coregonus albula       20
#  4 BIOTA         Coregonus lavaretus    43
#  5 BIOTA         Esox lucius            17
#  6 BIOTA         Euphausiacea indet     12
#  7 BIOTA         Gadus morhua           60
#  8 BIOTA         Ikke angitt            66
#  9 BIOTA         Larus argentatus      120
# 10 BIOTA         Mysis relicta           9

get_matrix_species(df_check %>% filter(SPECIES %in% "Larus argentatus"))     # Bird, gråmåke, måke
get_matrix_species(df_check %>% filter(SPECIES %in% "Gadus morhua"))         # Gadus morhua
get_matrix_species(df_check %>% filter(SPECIES %in% "Coregonus lavaretus"))  # Fish, sik
get_matrix_species(df_check %>% filter(SPECIES %in% "Coregonus albula"))     # Biota, species not given
get_matrix_species(df_check %>% filter(SPECIES %in% "Esox lucius"))          # Fish
get_matrix_species(df_check %>% filter(SPECIES %in% "Mysis relicta"))        # Biota, Mysis or species not given


#
# . 12 characters - insert zero ----
#
x <- limscodes[nchar(limscodes) == 12]
x %>% head(30)
limscodes_12to13 <- paste0(substr(x, 1, 8), "0", substr(x, 9, 12))
limscodes_12to13 %>% head(30)

df_check <- get_nivabase_selection(
  "TEXT_ID,PROSJEKT,SAMPLE_TYPE,SAMPLED_DATE,DESCRIPTION,AQUAMONITOR_ID,AQUAMONITOR_CODE,AQUAMONITOR_NAME,SPECIES,TISSUE,BIOTA_SAMPLENO",
  "LABWARE_CHECK_SAMPLE",
  "TEXT_ID",
  limscodes_12to13,
  values_are_text = TRUE)
nrow(df_check) # 116
df_check %>%
  count(SAMPLE_TYPE, SPECIES)
#   SAMPLE_TYPE SPECIES               n
# 1 BIOTA       Ikke angitt          30
# 2 BIOTA       Osmerus eperlanus     2
# 3 BIOTA       Salmo trutta          2
# 4 FERSKVANN   NA                    8
# 5 SJ<d8>VANN  NA                   74


get_matrix_species_12char(df_check %>% filter(SPECIES %in% "Ikke angitt"))  # Måke
get_matrix_species_12char(df_check %>% filter(SPECIES %in% "Osmerus eperlanus"))  # Ørret (mistaken from krøkle?)
get_matrix_species_12char(df_check %>% filter(SAMPLE_TYPE %in% "Ferskvann"))  # no hits
get_matrix_species_12char(df_check %>% filter(SAMPLE_TYPE %in% "SJ<d8>VANN"))  # grevling, trost, jord....


#
# . 14 characters ----
# two types: "NR-2014-2307-8" and "NR-2012-223253"
#
x <- limscodes[nchar(limscodes) == 14 & substr(limscodes,13,13) == "-"] 
x %>% head(30)
x <- limscodes[nchar(limscodes) == 14 & substr(limscodes,13,13) != "-"] 
x %>% head(30)


#
# . 14 characters, type a ----
# "NR-2014-2307-8"
#
x <- limscodes[nchar(limscodes) == 14 & substr(limscodes,13,13) == "-"] 
x %>% head(30)
limscodes_14to13 <- paste0(substr(x, 1, 12), substr(x, 14, 14))
limscodes_14to13 %>% head(30)

df_check <- get_nivabase_selection(
  "TEXT_ID,PROSJEKT,SAMPLE_TYPE,SAMPLED_DATE,DESCRIPTION,AQUAMONITOR_ID,AQUAMONITOR_CODE,AQUAMONITOR_NAME,SPECIES,TISSUE,BIOTA_SAMPLENO",
  "LABWARE_CHECK_SAMPLE",
  "TEXT_ID",
  limscodes_14to13,
  values_are_text = TRUE)
nrow(df_check) # 0
# HMMMMMM......

#
# . 14 characters, type b ----
# "NR-2012-223253"
#
x <- limscodes[nchar(limscodes) == 14 & substr(limscodes,13,13) != "-"] 
x %>% head(30)
# What to do???

# 15 characters - one type: "NR-2013-2118-10"
x <- limscodes[nchar(limscodes) == 15 & substr(limscodes,13,13) == "-"] 
head(x, 50)
# limscodes_14char_a <- ...



df_check <- get_nivabase_data("select * from NIVADATABASE.LABWARE_CHECK_SAMPLE where ACCOUNT_NUMBER in (426,427,650,658)")
head(df_check, 3)
# df_check$TEXT_ID %>% head(100)

# GOTTEN THIS FAR - TRY TO FIX 14 and CHARACTER LIMS ABOVE BEFORE CONTINUING

#
# Testing
#
df_labware <- get_nivabase_selection(
  "TEXT_ID,PROSJEKT,SAMPLE_TYPE,SAMPLED_DATE,DESCRIPTION,AQUAMONITOR_ID,AQUAMONITOR_CODE,AQUAMONITOR_NAME,SPECIES,TISSUE,BIOTA_SAMPLENO",
  "LABWARE_CHECK_SAMPLE",
  "TEXT_ID",
  limscodes_13char,
  values_are_text = TRUE)
nrow(df_labware) # 953

df_labware <- get_nivabase_selection(
  "TEXT_ID,PROSJEKT,SAMPLE_TYPE,SAMPLED_DATE,DESCRIPTION,AQUAMONITOR_ID,AQUAMONITOR_CODE,AQUAMONITOR_NAME,SPECIES,TISSUE,BIOTA_SAMPLENO",
  "LABWARE_CHECK_SAMPLE",
  "TEXT_ID",
  limscodes_12char,
  values_are_text = TRUE)
nrow(df_labware) # 116




xtabs(~SPECIES, df_labware)
xtabs(~TEXT_ID, df_labware)

