
source("4_functions/run_my_functions.R")

# Importing data ###############################################################

atc_codes <- fread("./0_lookup/atc_index.csv")

rx_H02 <- 
  read_rds("./1_raw_data/renamed/rx_H02.RDS")

################################################################################

duration_estimation <- function(rx){
  
  rx <- rx %>%
    mutate(rx_duration = ceiling(amount/daily_units)) %>%
    
    mutate(rx_duration = case_when(
      (is.na(rx_duration) | rx_duration == 0) & ddd > 0 ~ ceiling(amount/ddd),
      TRUE ~ rx_duration)) %>%
    
    mutate(rx_end_date = eventdate + rx_duration)
  
  return(rx)
}

################################################################################

rx_H02 <- rx_H02 %>% 
  filter(!(units == "G" | units == "MG")) %>% 
  mutate(ddd = case_when(
    label_descr == "HYDROCORTISON TABLET  5MG" ~ 2, 
    label_descr == "ACECORT TABLET FILMOMHULD 1" ~ 10,
    label_descr == "ACECORT 2MG TABLET ACE" ~ 5,
    label_descr == "ACECORT 1MG TABLET FILMOMH" ~ 10,
    label_descr == "ACECORT 10MG TABLET ACE" ~ 1,
    TRUE ~ ddd
  )) %>% 
  duration_estimation() %>% 
  mutate(rx_duration = if_else(rx_duration > 365, 365, rx_duration))


rf_H02 <- rx_H02 %>% 
  select(patid, eventdate, rx_duration) %>% 
  mutate(end = eventdate + rx_duration) %>% 
  select(-rx_duration)

################################################################################

saveRDS(rf_H02, 
        "./2_interim_data/rf_H02.RDS")




