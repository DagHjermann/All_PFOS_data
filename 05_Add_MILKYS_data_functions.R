
X <- c(
  "ip-PFNS", "PFNS",
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
  " 6:2 F53B", "6:2 F53B",
  "PFUdA", "PFUnDA",
  "N-Et_FOSA", "N-EtFOSA",
  "N-Et_FOSE", "N-EtFOSE",
  "N-MeFOSA", "N-MeFOSA",
  "N-Me_FOSE", "N-MeFOSE",
  "PFDcA", "PFDA",
  "FPDcS", "PFDS",
  "PFPeA", "PFPA",
  "PFTA", "PFTeDA",
  "HPFHpA", "PFHpA",
  "PFDcS", "PFDS",
  "PFTS", "PFTeS",
  "PFTrA", "PFTrDA",
  "PFDoA", "PFDoDA",
  "PFTeA", "PFTeDA"   # Merete's data down to here
  )


df_synonyms <- matrix(X, ncol = 2, byrow = TRUE) %>% as.data.frame(stringsAsFactors = FALSE)
colnames(df_synonyms) <- c("param_orig", "param_standard")

# cemp_synonyms <- df_synonyms %>%
#   mutate(param = toupper(param_orig)) %>%
#   select(param, param_standard)

X <- c(
  "PFDCA","PFDA",
  "PFDcA","PFDA",
  "PFDCS","PFDS",
  "PFDcS","PFDS",
  "PFDOA",	"PFDoDA",
  "PFDODA", "PFDoDA",
  "PFUdA",	"PFUnDA",
  "PFHXA", "PFHxA",
  "PFHXS", "PFHxS",
  "PFHPA", "PFHpA"
)

cemp_synonyms <- matrix(X, ncol = 2, byrow = TRUE) %>% as.data.frame(stringsAsFactors = FALSE)
colnames(cemp_synonyms) <- c("param", "param_standard")

  

