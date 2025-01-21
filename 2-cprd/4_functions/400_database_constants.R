

# constants dependent on database(country)

# select parameters based on database
if(grepl("pharmo", 
         getwd(), 
         ignore.case = TRUE)) {
  
  const$database <- "PHARMO-NL"
  const$study_start <- as.Date("2014-01-01")
  const$study_end <- as.Date("2021-12-31")
  
  # RMMs 1 - NL
  const$rmm1_start <- as.Date("2018-10-04")
  const$rmm1_end <- as.Date("2019-03-29")
  
  
  # RMM2 - NL
  const$rmm2_start <- as.Date("2020-09-28")
  const$rmm2_end <- as.Date("2020-10-29")

  # COVID first case detected
  const$covid <- as.Date("2020-02-27")

} else {
    
  const$database <- "CPRD-UK"
  
  const$study_start <- as.Date("2014-01-01")
  const$study_end <- as.Date("2023-10-31")
  
  # RMMs 1 - UK
  const$rmm1_start <- as.Date("2018-10-04")
  const$rmm1_end <- as.Date("2019-03-29")

  # RMM2 - UK 
  const$rmm2_start <- as.Date("2020-12-02") 
  const$rmm2_end <- as.Date("2020-12-02")
  
  # COVID first case detected
  const$covid <- as.Date("2020-01-31") # in the UK 
  }


