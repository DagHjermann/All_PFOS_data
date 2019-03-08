
#
# Based on 'C:\Data\seksjon 318\get-fresh-temp\01_Explore_temp_data.Rmd'
#

library(dplyr)
library(niRvana)
library(purrr)
library(ggplot2)
library(lubridate)   # year()

# improved set_credentials
library(svDialogs)
source("01_niRvana_improved_set_credentials.R")

## End(Not run)


# Input your NIVAbasen username/password
set_credentials()

# List of PFAS compounds
# Gotten by mail from Merete Grung 7.3.2019
df_oecd <- openxlsx::read.xlsx("Input_data/Q 122 PFAS_NIVA_Analyses_OECDlist.xlsx")


# Synonyms (gotten from Merete)
X <- c("ip-PFNS", "PFNS",
       " PFHpA", "PFHpA",
       " PFPA", "PFPA",
       " meFOSAA", "meFOSAA",
       " meFOASAA", "meFOASAA",
       "PFUdA", "PFUnDA",
       "PFUdS", "PFUnS",
       "et-FOSAA", "etFOSAA",
       "et-PFOSA", "etFOSA",
       "et-PFOSE", "etFOSE",
       "me-FOASAA", "meFOASAA",
       "me-FOSAA", "meFOSAA",
       "me-PFOSA", "meFOSA",
       "me-PFOSE", "meFOSE",
       "meFPeSA", "mePeSA",
       "mePFBSA", "meFBSA",
       " 4:2 F53B", "4:2 F53B",
       " 6:2 F53B", "6:2 F53B")
synonyms <- matrix(X, ncol = 2, byrow = TRUE)
synonyms <- tibble(PARAM_variant = synonyms[,1], PARAM = synonyms[,1])



#
# NOTE: From here you may skip 1, 2, 3 and go straight to 4C
#

#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# 1. Get all methods and seach for perfluor compounds ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

# get_nivabase_data("select * from NIVADATABASE.METHOD_DEFINITIONS where rownum < 4" )
df_method <- get_nivabase_data("select METHOD_ID, NAME, UNIT, LABORATORY, MATRIX, CAS, IUPAC from NIVADATABASE.METHOD_DEFINITIONS")

# Check OECD list
df_method$NAME %in% df_oecd$Short.name %>% sum()  # 290
df_oecd$Short.name %in% df_method$NAME %>% sum()  # 30

grep("^PF", df_method$NAME, value = TRUE)
grep("PF", df_method$NAME, value = TRUE)

sel1 <- grepl("^PF", df_method$NAME)        # include
sel2 <- grepl("PF", df_method$NAME)         # include? check using sel3 and sel4
sel3 <- grepl("perfluor", df_method$NAME, ignore.case = TRUE)  # include
sel4 <- grepl("PFOS", df_method$NAME, ignore.case = FALSE) |   # include
  grepl("PFAS", df_method$NAME, ignore.case = FALSE)         
sel4 <- grepl("PFOS", df_method$NAME, ignore.case = FALSE) |   # include
  grepl("PFAS", df_method$NAME, ignore.case = FALSE)       
sel5 <- grepl("FTOH", df_method$NAME, ignore.case = FALSE)  |  # include
  grepl("FTS", df_method$NAME, ignore.case = FALSE)  |       
  grepl("F53B", df_method$NAME, ignore.case = FALSE)  |       
  grepl("PAP", df_method$NAME, ignore.case = FALSE)
sel6 <- grepl("N-Me", df_method$NAME, ignore.case = FALSE, fixed = TRUE) |
  grepl("N-Et", df_method$NAME, ignore.case = FALSE, fixed = TRUE)
sel7 <- grepl("FOSA", df_method$NAME, ignore.case = FALSE, fixed = TRUE)
sel8 <- grepl("^me", df_method$NAME, ignore.case = FALSE)  # include - "me-FOSAA", "me-FOASAA" ++
sel99 <- grepl("ICPF", df_method$NAME, fixed = TRUE) |     # exclude
  grepl("PO4PF", df_method$NAME) | 
  grepl("TOTPF", df_method$NAME) | 
  grepl("SHPO4PF", df_method$NAME) | 
  grepl("AOX-PFI", df_method$NAME) | 
  grepl("DPF-B", df_method$NAME) | 
  grepl("BPF", df_method$NAME)  |   # bisphenol F
  grepl("methyl mercury", df_method$NAME)
sum(sel1)  # 352
sum(sel2)  # 603
sum(sel3)  # 188

# Check sel5
df_method$NAME[sel5 & !sel2 & !sel3]
df_method$NAME[sel6 & !sel2 & !sel3]
df_method$NAME[sel7 & !sel2 & !sel3]
df_method$NAME[sel8 & !sel2 & !sel3 & !sel99]
# df_method[sel5,]

# df_method[sel2 & !sel1,]
# df_method[sel2 & !sel1 & !sel3,]
df_method[sel2 & !sel1 & !sel3 & !sel4 & !sel99,]  # "doubt cases" to include, see below



# 
# We include the following also:
#
# METHOD_ID                              NAME        UNIT   LABORATORY
# 9387      26215 7H-dodekafluorheptansyre (HPFHpA)     NG_P_KG NIVA_LABWARE
# 9397      26225   Sum PFC forbindelser ekskl. LOQ     NG_P_KG NIVA_LABWARE  # Perfluorinated compounds (PFC)
# 9402      26230    Sum PFC forbindelser inkl. LOQ     NG_P_KG NIVA_LABWARE
# 9408      26236 7H-dodekafluorheptansyre (HPFHpA)     UG_P_KG NIVA_LABWARE
# 9413      26241    Sum PFC forbindelser inkl. LOQ     UG_P_KG NIVA_LABWARE
# 9437      25824    Sum PFC forbindelser inkl. LOQ     UG_P_KG NIVA_LABWARE
# 9620      26253    Sum PFC forbindelser inkl. LOQ      NG_P_G NIVA_LABWARE
# 9629      26262   Sum PFC forbindelser ekskl. LOQ      NG_P_G NIVA_LABWARE
# 9639      26272 7H-dodekafluorheptansyre (HPFHpA)      NG_P_G NIVA_LABWARE
# 10983     27819                           ip-PFNS ng/g (w.w.)         NIVA  # Sodium perfluoro-7-methyloctanesulfonate.
# 11144     28134                           ip-PFNS       ng/ml         NIVA
# 11500     27975                           ip-PFNS ng/g (d.w.)         NIVA
# 11606     28081                           ip-PFNS        ng/L         NIVA
# 12118     33080 7H-dodekafluorheptansyre (HPFHpA)    UG_KG_TS NIVA_LABWARE

# To include in total:
# BAsically, this is all "perfluor" plus all "PF" except "ICPF","PO4PF","TOTPF", "SHPO4PF", "AOX-PFI", "DPF-B", "BPF"
sel_final <- (sel1 | sel2 | sel3 | sel4 | sel5 | sel6 | sel7 | sel8) & !sel99
sum(sel_final)  # 694

# Check those NOT yet selected against OECD list
sel_x <- df_method$NAME[!sel_final] %in% df_oecd$Short.name
names_x <- df_method$NAME[!sel_final][sel_x]
sum(sel_x)  # 0

# PArameter names
paramnames <- df_method$NAME[sel_final] %>% unique()
length(paramnames) # 145

# Only 30 names are found in the OECD list
table(paramnames %in% df_oecd$Short.name)
# FALSE  TRUE 
#  115    30 

# OECD list names not found in NIVAbasen 
sel_lacking <- !df_oecd$Short.name %in% paramnames
sum(sel_lacking)  # 59
df_oecd$Short.name[sel_lacking]
# df_oecd[sel_lacking, 1:5] %>% View()

# [1] "PFPrA"         "PFUnDA"        "PFPeDA"        "PFHpDA"        "PFPrS"         "PFUnDS"        "PFTrDS"        "PFTeDS"       
# [9] "ipPFNS"        "br-PFOS"       "8-ClPFOS"      "N-MeFOSA"      "N-EtFOSA"      "PFOSE"         "N-MeFOSE"      "N-EtFOSE"     
# [17] "FOSAA"         "N-MeFOSAA"     "N-EtFOSAA"     "6:2FTS"        "6:2 53B"       "PFBPA"         "PFHxPA"        "PFPOA"        
# [25] "PFDPA"         "6:2 PAP"       "8:2 PAP"       "6:2 diPAP"     "8:2 diPAP"     "6:2/8:2 diPAP" "10:2 diPAP"    "6:2 FTCA"     
# [33] "8:2 FTCA"      "10:2 FTCA"     "6:2 FTUCA"     "8:2 FTUCA"     "10:2 FTUCA"    "PFBSA"         "PFPeSA"        "PFHxSA"       
# [41] "PFHpSA"        "N-MeFBSA"      "N-MeFPeSA"     "N-MeFHxSA"     "N-MeFHpSA"     "N-EtFBSA"      "N-EtFPeSA"     "N-EtFHxSA"    
# [49] "N-EtFHpSA"     "N-MeFBSE"      "N-MeFPeSE"     "N-MeFHxSE"     "N-MeFHpSE"     "N-EtFBSE"      "N-EtFPeSE"     "N-EtFHxSE"    
# [57] "N-EtFHpSE"     "Gen X"         "ADONA" 

#
# Checking some of those not found:
#
sel <- (!sel_final & grepl("FOSA", df_method$NAME, ignore.case = FALSE, fixed = TRUE))
sum(sel)
df_method$NAME[sel]

sel <- (!sel_final & grepl("FTCA", df_method$NAME, ignore.case = FALSE, fixed = TRUE))
sum(sel)

sel <- (!sel_final & grepl("FTUCA", df_method$NAME, ignore.case = FALSE, fixed = TRUE))
sum(sel)

sel <- (!sel_final & grepl("unda", df_method$NAME, ignore.case = TRUE))
sum(sel)
df_method$NAME[sel]

sel <- (!sel_final & grepl("pfud", df_method$NAME, ignore.case = TRUE))
sum(sel)  
df_method$NAME[sel]
sel <- (grepl("pfud", df_method$NAME, ignore.case = TRUE))
sum(sel)  
df_method$NAME[sel]  # "PFUdA" already included - is equal to "PFUnDA"

sel <- (!sel_final & grepl("meFPeSA", df_method$NAME, ignore.case = TRUE))
sum(sel)

sel <- (!sel_final & grepl("mePFBSA", df_method$NAME, ignore.case = TRUE))
sum(sel)

sel <- (!sel_final & grepl("^me", df_method$NAME, ignore.case = FALSE))
sum(sel)
df_method$NAME[sel]  # "me-FOSAA etc.

sel <- (!sel_final & grepl("n-et", df_method$NAME, ignore.case = TRUE))
sum(sel)
df_method$NAME[sel]

sel <- (!sel_final & grepl("n-me", df_method$NAME, ignore.case = TRUE))
sum(sel)
df_method$NAME[sel]

sel <- (!sel_final & grepl("undecanoic", df_method$NAME, ignore.case = TRUE))
sum(sel)

#o#o#o#o#o#o#o#o#o#o
# Save
#o#o#o#o#o#o#o#o#o#o

df_method_sel <- df_method[sel_final,]
openxlsx::write.xlsx(df_method_sel, "Data/01_methods_pfas.xlsx")

#o#o#o#o#o#o#o#o#o#o
# For readaing saved data: 
# df_method_sel <- openxlsx::read.xlsx("Data/01_methods_pfas.xlsx")
# paramnames <- df_method_sel$NAME %>% unique()
#o#o#o#o#o#o#o#o#o#o

# Check dublettes 1
table(table(df_method_sel$NAME))
table(table(df_method_sel$METHOD_ID))

# Check dublettes 2
df_method_sel %>%
  count(NAME, UNIT) %>%
  pull(n) %>% table()
df_method_sel %>%
  count(NAME, UNIT, LABORATORY, MATRIX) %>%
  pull(n) %>% table()


#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# 2. Check WC_PARAMETER_DEFINITIONS (not necessary) ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

# Not necessary. Just the long names
df_param_meth <- get_nivabase_selection("PARAMETER_ID, METHOD_ID",
                                        "WC_PARAMETERS_METHODS", 
                                        "METHOD_ID",
                                        df_method$METHOD_ID[sel])
nrow(df_param_meth)  # 53

df_param_def <- get_nivabase_selection("PARAMETER_ID, NAME",
                                       "WC_PARAMETER_DEFINITIONS", 
                                       "PARAMETER_ID",
                                       df_param_meth$PARAMETER_ID)
nrow(df_param_def)  # 21
# df_param_def

#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# 3. Get names of tables with chemical results (those with METHOD_ID) (not necessary) ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

get_nivabase_data("select TABLE_NAME from ALL_TAB_COLUMNS where OWNER = 'NIVADATABASE' and column_name = 'METHOD_ID'")  
# WATER_CHEMISTRY_VALUES
# BIOTA_CHEMISTRY_VALUES
# SEDIMENT_CHEMISTRY_VALUES
# SEWAGE_CHEMISTRY_VALUES

#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# 4. Get value data ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

# Check column names
get_nivabase_data("select * from NIVADATABASE.WATER_CHEMISTRY_VALUES where rownum < 4" )
get_nivabase_data("select * from NIVADATABASE.BIOTA_CHEMISTRY_VALUES where rownum < 4" )
get_nivabase_data("select * from NIVADATABASE.SEDIMENT_CHEMISTRY_VALUES where rownum < 4" )
get_nivabase_data("select * from NIVADATABASE.SEWAGE_CHEMISTRY_VALUES where rownum < 4" )
get_nivabase_data("select * from NIVADATABASE.BIOTA_SAMPLES where rownum < 4" )

vars <- "METHOD_ID, WATER_SAMPLE_ID, VALUE, FLAG1, FLAG2, DETECTION_LIMIT, UNCERTAINTY, QUANTIFICATION_LIMIT"
df_values_wat <- get_nivabase_selection(vars,
                                        "WATER_CHEMISTRY_VALUES", 
                                        "METHOD_ID",
                                        df_method_sel$METHOD_ID)
nrow(df_values_wat) # 876


# Get data, biota

# Get chemical measurements (a couple of minutes)
vars <- "METHOD_ID, SAMPLE_ID, VALUE, FLAG1, FLAG2, DETECTION_LIMIT, UNCERTAINTY, QUANTIFICATION_LIMIT"
df_values_bio <- get_nivabase_selection(vars,
                                        "BIOTA_CHEMISTRY_VALUES", 
                                        "METHOD_ID",
                                        df_method_sel$METHOD_ID)
nrow(df_values_bio) # 34518

# Get data, sediment
vars <- "METHOD_ID, SLICE_ID, MATRIX, FRACTION_SIZE, VALUE, FLAG1, FLAG2, DETECTION_LIMIT, UNCERTAINTY, QUANTIFICATION_LIMIT"
df_values_sed <- get_nivabase_selection(vars,
                                        "SEDIMENT_CHEMISTRY_VALUES",
                                        "METHOD_ID",
                                        df_method_sel$METHOD_ID)
nrow(df_values_sed) # 3152



# Get data, sewage
vars <- "METHOD_ID, SAMPLE_ID, VALUE, FLAG1, FLAG2"
df_values_sew <- get_nivabase_selection(vars,
                                        "SEWAGE_CHEMISTRY_VALUES", 
                                        "METHOD_ID",
                                        df_method_sel$METHOD_ID)
nrow(df_values_sew) # 0

#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# 4B. Save value data ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

saveRDS(df_values_wat, "Data/01_df_values_wat.rds")
saveRDS(df_values_bio, "Data/01_df_values_bio.rds")
saveRDS(df_values_sed, "Data/01_df_values_sed.rds")


#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# 4C. Read saved data, if you skipped re-downloading them... ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

if (!exists("df_values_wat"))
  df_values_wat <- readRDS("Data/01_df_values_wat.rds")
if (!exists("df_values_bio"))
  df_values_bio <- readRDS("Data/01_df_values_bio.rds")
if (!exists("df_values_sed"))
  df_values_sed <- readRDS("Data/01_df_values_sed.rds")

#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# 5. Biota data - add station and individual data ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

df_samples <- get_nivabase_selection("SAMPLE_ID, SPECIES_ID, TISSUE_ID, STATION_ID, SAMPLE_DATE, SAMPLE_NO, REPNO",
                                     "BIOTA_SAMPLES", 
                                     "SAMPLE_ID",
                                     unique(df_values_bio$SAMPLE_ID)) %>%
  rename(STATION_ID_sample = STATION_ID)   # We normally use STATION_ID from the SPECIMEN table, but save this also
nrow(df_samples) # 2917
# head(df_samples)

df_tissuetypes <- get_nivabase_selection("TISSUE_ID, TISSUE_NAME",
                                         "BIOTA_TISSUE_TYPES", 
                                         "TISSUE_ID",
                                         unique(df_samples$TISSUE_ID))
df_samples <- left_join(df_samples, df_tissuetypes, by = "TISSUE_ID")
  

df_samples_specimens <- get_nivabase_selection("SAMPLE_ID, SPECIMEN_ID",
                                     "BIOTA_SAMPLES_SPECIMENS", 
                                     "SAMPLE_ID",
                                     unique(df_values_bio$SAMPLE_ID))
nrow(df_samples_specimens) # 3552

df_specimens <- get_nivabase_selection("SPECIMEN_ID, STATION_ID, DATE_CAUGHT, TAXONOMY_CODE_ID",
                                       "BIOTA_SINGLE_SPECIMENS", 
                                       "SPECIMEN_ID",
                                       unique(df_samples_specimens$SPECIMEN_ID))
nrow(df_specimens) # 2786

df_taxoncodes <- get_nivabase_selection("TAXONOMY_CODE_ID, CODE, NAME",
                                        "TAXONOMY_CODES", 
                                        "TAXONOMY_CODE_ID",
                                         unique(df_specimens$TAXONOMY_CODE_ID)) %>%
  rename(LATIN_NAME = NAME)

nrow(df_taxoncodes) # 34

df_project_station <- get_nivabase_selection("STATION_ID, STATION_CODE, STATION_NAME, PROJECT_ID",
                                             "PROJECTS_STATIONS", 
                                             "STATION_ID",
                                              unique(df_specimens$STATION_ID))
nrow(df_project_station)  # 306
xtabs(~PROJECT_ID, df_project_station)  # MILKYS = 3699

# Check shows that there is more than one staion/project comb. per saample
check <- df_specimens %>%
  left_join(df_samples_specimens, by = "SPECIMEN_ID") %>%
  left_join(df_taxoncodes, by = "TAXONOMY_CODE_ID") %>%
  left_join(df_project_station, by = "STATION_ID") %>%
  filter(SAMPLE_ID %in% 14238)
head(check, 10)

#
# Make data of specimen and station info (one line per sample), MILKYS data
#

df_specimens_milkys <- df_specimens %>%
  left_join(df_samples_specimens, by = "SPECIMEN_ID") %>%
  left_join(df_taxoncodes, by = "TAXONOMY_CODE_ID") %>%
  left_join(df_project_station, by = "STATION_ID") %>%
  filter(PROJECT_ID %in% 3699) %>%
  group_by(SAMPLE_ID) %>%
  mutate(N_specimens = n()) %>%
  summarize_all(list(~paste(unique(.), collapse = ","))) %>% # Sum up all unique values separated by comma
  mutate(N_specimens = as.numeric(N_specimens))
  
head(df_specimens_milkys)
nrow(df_specimens_milkys)  # 1375

#
# Put it all together, Milkys data
#
pfas_bio_milkys <- df_values_bio %>%
  left_join(df_samples %>% select(SAMPLE_ID, TISSUE_NAME, REPNO), by = "SAMPLE_ID") %>%
  left_join(df_method_sel %>% rename(PARAM = NAME), by = "METHOD_ID") %>%
  left_join(df_specimens_milkys, by = "SAMPLE_ID") %>%
  filter(!is.na(SPECIMEN_ID)) %>%
  mutate(YEAR = year(DATE_CAUGHT))
nrow(df_values_bio)    # 34518
nrow(pfas_bio_milkys)  # 13317

#
# Fix concentrations 
#
x <- pfas_bio_milkys$VALUE
table(substr(x,1,1))
table(substr(x,2,2))
# Test:
sub(",", ".", x) %>% as.numeric() %>% is.na() %>% sum()
pfas_bio_milkys$VALUE <- sub(",", ".", x) %>% as.numeric()

# Check
sel <- substr(x,1,1) == ","
head(x[sel]); head(pfas_bio_milkys$VALUE[sel])
sel <- substr(x,2,2) == ","
head(x[sel]); head(pfas_bio_milkys$VALUE[sel])

# Fix other numeric variables
pfas_bio_milkys$QUANTIFICATION_LIMIT <- sub(",", ".", pfas_bio_milkys$QUANTIFICATION_LIMIT) %>% as.numeric()
pfas_bio_milkys$STATION_ID <- as.numeric(pfas_bio_milkys$STATION_ID)
pfas_bio_milkys$TAXONOMY_CODE_ID <- as.numeric(pfas_bio_milkys$TAXONOMY_CODE_ID)
pfas_bio_milkys$PROJECT_ID <- as.numeric(pfas_bio_milkys$PROJECT_ID)

# percent_missing
percent_missing <- apply(is.na(pfas_bio_milkys), 2, mean)*100
round(percent_missing, 1)

#
# Add PARAM2
# Made by 1) extracting names within parantheses and 2) remove "-B" at end
#

x <- unique(pfas_bio_milkys$PARAM)
df_param2 <- tibble(PARAM = x, PARAM2 = x)

# 1) extracting names within parantheses
result <- stringr::str_match(x, "\\((.+)\\)")   # result: "180"
sel <- !is.na(result[,2])
df_param2$PARAM2[sel] <- result[sel, 2]
# 2) remove "-B" at end
x <- unique(pfas_bio_milkys$PARAM)
result <- sub("\\-B$", "", x)
sel <- x != result
df_param2$PARAM2[sel] <- result[sel]

pfas_bio_milkys <- pfas_bio_milkys %>% left_join(df_param2)

# Check
# pfas_bio_milkys %>% filter(PARAM %in% "PFOSA-B") %>% head(2)

#
# Save
#
colnames(pfas_bio_milkys) %>% dput()
openxlsx::write.xlsx(
  pfas_bio_milkys %>% 
    select(PARAM,PARAM2,CAS,IUPAC,UNIT,VALUE,FLAG1,FLAG2,
           LATIN_NAME, CODE, MATRIX, STATION_CODE,STATION_NAME, 
           N_specimens, DATE_CAUGHT, YEAR,
           DETECTION_LIMIT, UNCERTAINTY,QUANTIFICATION_LIMIT, LABORATORY,
           METHOD_ID,SAMPLE_ID, STATION_ID, TAXONOMY_CODE_ID, PROJECT_ID), 
  "Data/01_pfas_bio_milkys.xlsx")


#
# No of PFAS
#
df_samp_all <- df_values_bio %>% count(SAMPLE_ID) %>% arrange(desc(n))
df_samp_milkys <- pfas_bio_milkys %>% count(SAMPLE_ID) %>% arrange(desc(n))

ggplot(df_samp_all, aes(x = n)) +
  geom_histogram(binwidth = 4) +
  labs(x = "Number of PFAS compunds", y = "Number of samples", title = "Number of PFAS compounds, all data")

ggplot(df_samp_milkys, aes(x = n)) +
  geom_histogram(binwidth = 4) +
  labs(x = "Number of PFAS compunds", y = "Number of samples", title = "Number of PFAS compounds, Milkys data")

#
# Types of PFAS
#

unique(pfas_bio_milkys$PARAM)
xtabs(~PARAM, pfas_bio_milkys)





