# All_PFOS_data
First note: the name of this repo is wrong, it should be "All_PFAS" (PFAS is the collective name for PFOS, PFOSA and all the other perfluor compunds).  
This project is about collecting NIVA's PFAS data, for all years and all media (sediment, biota, water). The main input is an Excel file ("001 PFAS stacked data table.xlsx") put together by Merete Grung.  Making graphs etc. is mainly done by Merete and Bert, so the main output from these scripts is additional data added to the original input file.  
This includes  
* add species and tissue (called "Organ" in the excel file) where this is lacking  
* if possible also add fat, C13, and N15
* if possible also add length and weight for biota
  
Scripts:  
* "01_Get_chemical_data.R"
    - Getting PFAS data from Nivabase. Did this before I got the Excel file from Merete 
* "02_Read_stacked_datafile.R"
    - First script using the Excel file from Merete ("001 PFAS stacked data table.xlsx")
    - Did some exploration of the LIMS code (but this was not resolved until script 04)
* "03_WILAB_test.R"
    - Exploring the WILAB tables in Nivabase. This system was used through 2013 and most of 2014. 
    - Conclusion is that I did not find any field/variable in the WILAB tables that corresponds to the LIMS code in the Excel file, 
    so there is no way to couple these. 
    - Thus we should use the MILKYS Access database (for teh marien biota data at least)
* "04_Get_Labware_metadata.Rmd"
    - Here I was able to get species and tissue for *most* of the biota data from 2015 onwards  
    - Makes 'ver. 2' of the Excel files named 002, 003, 004
* "05_Add_Milkys_data.Rmd"
    - Add columns for dry weight, fat weight and fish length (based on Access database)
    - Makes 'ver. 3' of the Excel files named 002, 003, 004
