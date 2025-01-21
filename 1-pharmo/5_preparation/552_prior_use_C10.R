
source("4_functions/run_my_functions.R")

# Importing data ###############################################################

atc_codes <- fread("./0_lookup/atc_index.csv")

rx_C10 <- readRDS("./1_raw_data/renamed/rx_C10.RDS") 

rx_C10 <- rx_C10 %>% 
  select(patid, eventdate) %>% 
  distinct()

index_dates <- readRDS("~/phd2-pharmo/2_interim_data/index_dates_pg7.rds")

rx_C10_prior <- rx_C10 %>% 
  semi_join(index_dates, by = "patid") %>% 
  left_join(index_dates, by = "patid") %>% 
  group_by(patid) %>% 
  filter(eventdate <= index_date) %>% 
  filter(eventdate == max(eventdate))

rx_C10_post <- rx_C10 %>% 
  anti_join(rx_C10_prior, by = "patid") %>%   
  semi_join(index_dates, by = "patid") %>% 
  left_join(index_dates, by = "patid") %>% 
  group_by(patid) %>% 
  filter(eventdate > index_date) %>% 
  filter(eventdate == min(eventdate))

rf_C10 <- rx_C10_prior %>% 
  bind_rows(rx_C10_post) %>% 
  select(patid, eventdate)

################################################################################

saveRDS(rf_C10, 
        "./2_interim_data/rf_C10.RDS")
