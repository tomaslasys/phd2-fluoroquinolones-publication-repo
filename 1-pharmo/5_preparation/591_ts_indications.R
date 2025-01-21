
source("4_functions/run_my_functions.R")
source("4_functions/ts_calculator.R")

################################################################################

atc_codes <- fread("./0_lookup/atc_index.csv") %>% 
  filter(grepl("^J01", atc_code))

denominator <- readRDS("2_interim_data/denominator.RDS")
denominator <- denominator$all

################################################################################

dx_file <- paste0("./2_interim_data/tx_indications_pg30.rds")

dx <- readRDS(dx_file) %>% 
  ungroup() %>% 
  select(tx_episode, dx_group) %>% 
  distinct()

file2read <- paste0("./2_interim_data/rx_indexed_pg30.rds")

rx_data <- readRDS(file2read) 

#check
nrow(rx_data)

rx_data <- rx_data %>%
  ungroup() %>% # needed to remove patid
  select(patid, tx_episode, eventdate, atc_code, rx_type) %>% 
  left_join(dx, 
            by = "tx_episode", 
            relationship = "many-to-many") %>% 
  ungroup() 

#check
nrow(rx_data)

ts_dx <- rx_data %>% 
  select(tx_episode, eventdate, atc_code, rx_type, dx_group) %>% 
  ts_calculator() %>% 
  mutate(permissible_gap = 30) %>% 
  left_join(atc_codes, by = "atc_code") %>% 
  group_by(eventdate, drug_class_name, rx_type, permissible_gap, dx_group) %>% 
  summarise(n = sum(n)) %>% 
  left_join(denominator, by = "eventdate") %>% 
  mutate(n_adj = n*const$units/denom) %>% 
  select(-denom)


sum(ts_dx$n)

################################################################################

saveRDS(ts_dx, 
        "./3_clean_data/ts_indications.rds")





