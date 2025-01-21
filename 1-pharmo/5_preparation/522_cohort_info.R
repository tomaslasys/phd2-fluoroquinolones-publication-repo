
source("4_functions/run_my_functions.R")

patids <- readRDS( 
        "./2_interim_data/rx_selected.rds") %>% 
  distinct(patid)
  

cohort_info <- readRDS("./1_raw_data/renamed/demographics.RDS") %>% 
  semi_join(patids, by = "patid") %>% 
  select(-c(cohort1, cohort2))


saveRDS(cohort_info, 
        "./2_interim_data/cohort_info.rds")




