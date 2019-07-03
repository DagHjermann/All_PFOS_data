
#
# Conclusion (see part 'Same example from all tables'): 
#   1) cannot get info from WILAB samples easily from the stacked Excel data
#   2) Even if we could, it would not be that easy to get tissue, body weight etc.
#   3) Next step: get this from MILKYS Access database (marine fish only, obviously...)
#

#
# Libraries ----
#

library(niRvana)
library(ggplot2)

#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# Get number of WILAB + LABWARE per year ----
# Not needed for the rest of the script (and result is saved below)
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

# Get number of WILAB "test" per year
fn1 <- function(yr){
  old.o <- options(useFancyQuotes = FALSE)
  string <- paste0("select count(*) from WILAB.TEST where TESTNO like ", sQuote(paste0(yr, "%")))
  options(old.o)
  tibble(Year = yr, N = get_nivabase_data(string)[[1]])
}
# fn1(2002)
wilab_n_per_year <- 1995:2018 %>% purrr::map_df(fn1)

# 
# get_nivabase_data("select * from NIVADATABASE.LABWARE_CHECK_SAMPLE where rownum < 4")
fn2 <- function(yr){
  old.o <- options(useFancyQuotes = FALSE)
  string <- paste0("select count(*) from NIVADATABASE.LABWARE_CHECK_SAMPLE where TEXT_ID like ", sQuote(paste0("NR-", yr, "%")))
  options(old.o)
  tibble(Year = yr, N = get_nivabase_data(string)[[1]])
}
# fn2(2015)
labware_n_per_year <- 2010:2018 %>% purrr::map_df(fn2)

# Combine
samples_per_year <- bind_rows(
  data.frame(Base = "WILAB", wilab_n_per_year, stringsAsFactors = FALSE),
  data.frame(Base = "Labware", labware_n_per_year, stringsAsFactors = FALSE)
)

ggplot(samples_per_year, aes(Year, N, color = Base)) + geom_line() + geom_point()
# saveRDS(samples_per_year, file = "data/03_samples_per_year.rds")


#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# Data from Merete ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

dat <- readxl::read_excel("Input_data/001 PFAS stacked data table.xlsx", guess_max = 11000)
# A few errors in the 'PFASlength' variable
dat$LIMS %>% head(100)
tab <- table(dat$LIMS)
length(tab)  # 2809
samplecodes <- names(tab)

table(substr(samplecodes, 4, 7), nchar(samplecodes)) 
#        8  12  13  14  15  17  19  20  22  23  25
# 1993   0   0   2   0   0   0   0   0   0   0   0
# 2004   0   0   1   0   0   0   0   0   0   0   0
# 2005   0   0   4   0   0   0   0   0   0   0   0
# 2006   0   0  15   0   0   0   0   0   0   0   0
# 2007   0   0  10   0   0   0   0   0   0   0   0
# 2009   0   0 219   0   0   0   0   0   0   0   0
# 2010   0   0 162   0   0   0   0   0   0   0   0
# 2011   0   0 226   0   0   0   0   0   0   0   0
# 2012   0   0  66  10   0   0   0   0   0   0   0
# 2013   0   0   0 206  59   0   0   0   0   0   0  # to here, all WILAB
# 2014   0   0   0 248  31  15   0   0   0   0   0  # mostly WILAB
# 2015   0  34 115 113   0   0   0   0   0   0   1  # from here, almost only Labware
# 2016   0   0 161 146   0   0   1   3   1   3   0
# 2017   0  58 216 181   0   0   0   0   0   0   0
# 2018   1  27 462  12   0   0   0   0   0   0   0

# Species vs Year
table(substr(dat$LIMS,4,7), addNA(dat$Species))

# Species info (yes/no) vs year
table(substr(dat$LIMS,4,7), !is.na(dat$Species))
# 1) Lots of samples lacking Species in 2018 - try to get those
# 2) Lots of cod throughout (especially from 2009) - check MILKYS Access database? 

# 3a) Re: 1 above: Almost all 2018 data have 13 characters, especially if they lack Species
sel <- substr(dat$LIMS,4,7) == "2018"
table(nchar(dat$LIMS[sel]), !is.na(dat$Species[sel])) 
# Check sample numbers
sel2 <- nchar(dat$LIMS) == 13
range(as.numeric(substr(dat$LIMS[sel & sel2], 9, 13))) # 7846 - 14492

# 3b) Re: 1 above: Almost all 2018 data have 13 characters, especially if they lack Species
sel <- substr(dat$LIMS,4,7) == "2017"
table(nchar(dat$LIMS[sel]), !is.na(dat$Species[sel])) 
# Check sample numbers
sel2 <- nchar(dat$LIMS) == 13
range(as.numeric(substr(dat$LIMS[sel & sel2], 9, 13))) # 6288- 12663


#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# WILAB ----
# A bit of look at the data
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

get_nivabase_data("select * from WILAB.TEST where rownum < 4")
get_nivabase_data("select * from WILAB.TESTIN where rownum < 4")

get_nivabase_data("select count(*) from WILAB.TEST")    # 247000  
get_nivabase_data("select count(*) from WILAB.TESTIN")  # 2 million

#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# WILAB, check codes ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

# TEST
wilab_2014_id <- get_nivabase_data("select TESTNO, ACCOUNT, CONTPERS, MARKING, FIRM, X9 from WILAB.TEST where TESTNO like '2014%'")
nrow(wilab_2014_id) # 16298

# Sample ID numbers
tab1 <- table(wilab_2014_id$TESTNO)
length(tab1) # 2952
tab1 %>% head(50)
table(nchar(names(tab1)))  # always 10
range(as.numeric(substr(names(tab1),6,10)))  # numbers from 0 to 2952 
plot(as.numeric(substr(names(tab1),6,10)))

# Different columns
table(wilab_2014_id$ACCOUNT) %>% length() # 293
table(wilab_2014_id$CONTPERS) %>% length() # 190
table(wilab_2014_id$CONTPERS) %>% sort() %>% rev() %>% head(20)
table(wilab_2014_id$MARKING) %>% length() # 6241
table(wilab_2014_id$X9) %>% length() # 1230

# TESTIN
wilab_2014_id2 <- get_nivabase_data("select TESTNO from WILAB.TESTIN where TESTNO like '2014%'")
nrow(wilab_2014_id2) # 120037
tab2 <- table(wilab_2014_id2$TESTNO)
length(tab2) # 2924

# TEST + TESTIN, Milkys example (FIRM = MILKYS)
wilab_test_example <- get_nivabase_data("select * from WILAB.TEST where TESTNO = '2014-00053'")
wilab_testin_example <- get_nivabase_data("select * from WILAB.TESTIN where TESTNO = '2014-00053'")
View(wilab_test_example)     # 18 lines, one per fish
View(wilab_testin_example)   # 54 lines, three per fish (Hg, dry weight and OMK)

# TESTIN, PFAS (note : all years!)
wilab_testin_pfos <- get_nivabase_data("select * from WILAB.TESTIN where ANALYS like 'PFOS%'")
nrow(wilab_testin_pfos)  # 3611
table(wilab_testin_pfos$MARKING)
wilab_testin_pfos %>% xtabs(~substr(TESTNO,1,4), .)  # 2009 - 2013 only
wilab_testin_pfos %>% filter(grepl("36B", MARKING)) %>% View()
wilab_testin_pfos %>% filter(grepl("36B", MARKING)) %>% xtabs(~substr(TESTNO,1,4), .)  # 2009 - 2013 only
wilab_testin_pfos %>% filter(grepl("36B", MARKING)) %>% xtabs(~INDEXT, .)  # Tissue?
wilab_testin_pfos %>% filter(grepl("36B", MARKING)) %>% xtabs(~TESTTYPE, .)  # Tissue?

#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# Stacked data, check codes ----
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o

# Stacked data, 2014
sel <- substr(dat$LIMS,4,7) == "2014"
table(nchar(dat$LIMS[sel]), addNA(dat$Species[sel]))  # 14, 15 and 17 characters; all cod and all NA are 14 
sel_14 <- nchar(dat$LIMS) == 14
sel_15 <- nchar(dat$LIMS) == 15
sel_17 <- nchar(dat$LIMS) == 17

# Examples
dat$LIMS[sel & sel_14] %>% head(17) # "NR-2014-2307-1" "NR-2014-2307-1" "NR-2014-2307-1" "NR-2014-2307-1" 
dat$LIMS[sel & sel_15] %>% head(17) # "NR-2014-2307-10" "NR-2014-2307-10" "NR-2014-2307-10" "NR-2014-2307-10"
dat$LIMS[sel & sel_17] %>% head(17) # "NR-2014-14-2069-1" "NR-2014-14-2069-1" "NR-2014-14-2069-1" "NR-2014-14-2069-1"

# Extract 'main' numbers
no_14 <- substr(dat$LIMS[sel & sel_14], 9, 12)
table(no_14)
no_15 <- substr(dat$LIMS[sel & sel_15], 9, 12)
table(no_15)
no_17 <- substr(dat$LIMS[sel & sel_17], 12, 15)
table(no_17)


#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o
#
# Same example from all tables ----
# TESTIN - the cod from 36B - 3 pooled liver samples and more muscle samples
#
#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o#o


testin_example <- wilab_testin_pfos %>% filter(TESTNO == "2013-02901" & ANALYS %in% "PFOS-B")
testin_example %>% select(TESTNO, SERIALNO, ANALYS, MARKING, TESTTYPE,  MEANFL)
#        TESTNO SERIALNO ANALYS                           MARKING TESTTYPE MEANFL
# 1  2013-02901        2 PFOS-B                   36B F<e6>rder 2   OMK-20   0.12
# 2  2013-02901        4 PFOS-B                   36B F<e6>rder 4   OMK-20   1.02
# 3  2013-02901        5 PFOS-B                   36B F<e6>rder 5   OMK-20   0.37
# 4  2013-02901        8 PFOS-B                   36B F<e6>rder 8   OMK-20   0.99
# 5  2013-02901        9 PFOS-B                   36B F<e6>rder 9   OMK-20   0.35
# 6  2013-02901       11 PFOS-B                  36B F<e6>rder 11   OMK-20   0.19
# 7  2013-02901       14 PFOS-B                  36B F<e6>rder 14   OMK-20   0.56
# 8  2013-02901       16 PFOS-B    36B F<e6>rder 1,3,6,7,10,13,15   OMK-11   1.58
# 9  2013-02901       17 PFOS-B 36B F<e6>rde 16,17,18,19,20,21,22   OMK-11   1.83
# 10 2013-02901       18 PFOS-B               36B F<e6>rder 23-29   OMK-11   1.99

# Same example from TEST
test_example <- get_nivabase_data("select * from WILAB.TEST where TESTNO like '2013-02901'")
View(test_example)
test_example %>% select(TESTNO, SERIALNO, MARKING, DESCRIPT, X5, X9)
TESTNO                           MARKING SERIALNO           DESCRIPT       X5              X9
# 1  2013-02901                   36B F<e6>rder 1        1              OMK20 20140215 13;0361;I;01;LI
# 2  2013-02901                   36B F<e6>rder 2        2              OMK20 20140215 13;0361;I;02;LI
# 3  2013-02901                   36B F<e6>rder 3        3              OMK20 20140215 13;0361;I;03;LI
# 4  2013-02901                   36B F<e6>rder 4        4              OMK20 20140215 13;0361;I;04;LI
# 5  2013-02901                   36B F<e6>rder 5        5              OMK20 20140215 13;0361;I;05;LI
# 6  2013-02901                   36B F<e6>rder 6        6              OMK20 20140215 13;0361;I;06;LI
# 7  2013-02901                   36B F<e6>rder 7        7              OMK20 20140215 13;0361;I;07;LI
# 8  2013-02901                   36B F<e6>rder 8        8              OMK20 20140215 13;0361;I;08;LI
# 9  2013-02901                   36B F<e6>rder 9        9              OMK20 20140215 13;0361;I;09;LI
# 10 2013-02901                  36B F<e6>rder 10       10              OMK20 20140215 13;0361;I;10;LI
# 11 2013-02901                  36B F<e6>rder 11       11              OMK20 20140215 13;0361;I;11;LI
# 12 2013-02901                  36B F<e6>rder 12       12              OMK20 20140215 13;0361;I;12;LI
# 13 2013-02901                  36B F<e6>rder 13       13              OMK20 20140215 13;0361;I;13;LI
# 14 2013-02901                  36B F<e6>rder 14       14              OMK20 20140215 13;0361;I;14;LI
# 15 2013-02901                  36B F<e6>rder 15       15              OMK20 20140215 13;0361;I;15;LI
# 16 2013-02901    36B F<e6>rder 1,3,6,7,10,13,15       16 OMK12 Lever pakke1 20140215 13;0361;B;30;LI
# 17 2013-02901 36B F<e6>rde 16,17,18,19,20,21,22       17 OMK12 Lever pakke1 20140215 13;0361;B;31;LI
# 18 2013-02901               36B F<e6>rder 23-29       18 OMK12 Lever pakke1 20140215 13;0361;B;32;LI

# X9 is probably info that goes into the MILKYS Access database (SEQNO etc.)

# Find same example in the stacked data, 2013
sel <- with(dat, substr(LIMS,4,7) == "2013" & Species %in% "Gadus morhua" & Description %in% "36B" & PFAS %in% "PFOS")
sum(sel)
View(dat[sel, ])
dat[sel,] %>% select(Description, Project, LIMS, Matrix_orig, Matrix, Species, Organ_orig, Organ, Label_original, PFAS, Data)
#   Description Project LIMS           Matrix_orig Matrix Species      Organ_orig Organ Label_original PFAS  Data               
# 1 36B         MilKys  NR-2013-224178 Biota       biota  Gadus morhua NA         NA    PFOS           PFOS  1.8300000000000001 
# 2 36B         MilKys  NR-2013-224179 Biota       biota  Gadus morhua NA         NA    PFOS           PFOS  1.99               
# 3 36B         MilKys  NR-2013-224226 Biota       biota  Gadus morhua NA         NA    PFOS           PFOS  1.5800000000000001 
# 4 36B         MilKys  NR-2013-222276 Biota       biota  Gadus morhua NA         NA    PFOS           PFOS  0.56000000000000005
# 5 36B         MilKys  NR-2013-222914 Biota       biota  Gadus morhua NA         NA    PFOS           PFOS  0.34999999999999998
# 6 36B         MilKys  NR-2013-222949 Biota       biota  Gadus morhua NA         NA    PFOS           PFOS  0.19               
# 7 36B         MilKys  NR-2013-223001 Biota       biota  Gadus morhua NA         NA    PFOS           PFOS  0.98999999999999999
# 8 36B         MilKys  NR-2013-223004 Biota       biota  Gadus morhua NA         NA    PFOS           PFOS  0.37               
# 9 36B         MilKys  NR-2013-223005 Biota       biota  Gadus morhua NA         NA    PFOS           PFOS  1.02               
#10 36B         MilKys  NR-2013-223007 Biota       biota  Gadus morhua NA         NA    PFOS           PFOS  0.12  

# Note that the measurements fits with the numbers in TEST 
# Also noto: Organ is NA but can be "inferred" from the WILAB tables above 
# BUT: No field that links to "2013-02901" or any other info in the WILAB data

# Next step



#
# OLD STUFF ----
#




#
# Labware: Check 14 character long codes in 2017 ----
# See above: not really that relevant
#

# Get all 2017 labware IDs
labware_2017_id <- get_nivabase_data("select TEXT_ID from NIVADATABASE.LABWARE_CHECK_SAMPLE where TEXT_ID like 'NR-2017%'")
table(nchar(labware_2017_id$TEXT_ID))  # all are 13
x <- as.numeric(substr(labware_2017_id$TEXT_ID, 9, 13))
table(table(x)) # 1
plot(x)
plot(sort(x))
sort(x) %>% head()
range(x) 1 - 13520
labware_2017_id$TEXT_ID[x == 1]
test <- get_nivabase_data("select * from NIVADATABASE.LABWARE_CHECK_SAMPLE where TEXT_ID like 'NR-2017-0000%'")

# All that *ends with* 01:
# test2 <- get_nivabase_data("select * from NIVADATABASE.LABWARE_CHECK_SAMPLE where reverse(TEXT_ID) like '10%'")

# Get samplecodes from Excel sheet
sel <- substr(samplecodes, 4, 7) == "2017" & nchar(samplecodes) == 14; sum(sel)
samplecodes[sel]
x <- as.numeric(substr(samplecodes[sel], 9, 13))

labware_2017_id %>% tail()

test <- get_nivabase_selection(
  "TEXT_ID,PROSJEKT,SAMPLE_TYPE,SAMPLED_DATE,DESCRIPTION,AQUAMONITOR_ID,AQUAMONITOR_CODE,AQUAMONITOR_NAME,SPECIES,TISSUE,BIOTA_SAMPLENO",
  "LABWARE_CHECK_SAMPLE",
  "TEXT_ID",
  samplecodes[sel],
  values_are_text = TRUE)
# 0 observations




#
# OLDER STUFF ----
#



# all_tables <- get_nivabase_data("select TABLE_NAME,NUM_ROWS from ALL_TABLES where OWNER = 'NIVADATABASE'")   

# Explore 
all_tables <- get_nivabase_data("select OWNER,TABLE_NAME,NUM_ROWS from ALL_TABLES")   
View(all_tables)

table(all_tables$OWNER)


xtabs(~TABLE_NAME, subset(all_tables, OWNER == "WILAB"))

get_nivabase_data("select * from WILAB.ANALYS where rownum < 6")
get_nivabase_data("select * from WILAB.VIEWINNSYNTESTIN_AQMON where rownum < 4")

get_nivabase_data("select * from WILAB.TEST where rownum < 4")
get_nivabase_data("select * from WILAB.TESTIN where rownum < 4")

get_nivabase_data("select count(*) from WILAB.TEST")    # 247000
get_nivabase_data("select count(*) from WILAB.TESTIN")  # 2 million
get_nivabase_data("select count(*) from WILAB.VIEWINNSYNTESTIN_AQMON")   # 504 000

get_nivabase_data("select TABLE_NAME from ALL_TAB_COLUMNS where OWNER = 'WILAB' and column_name = 'ANALYS'")  
get_nivabase_data("select TABLE_NAME from ALL_TAB_COLUMNS where OWNER = 'WILAB' and column_name = 'TESTNO'")  



get_nivabase_data()    # 247000

