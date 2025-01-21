
source("4_functions/run_my_functions.R")
source("4_functions/ts_calculator.R")

################################################################################

atc_codes <- fread("./0_lookup/atc_index.csv") %>% 
  filter(grepl("^J01", atc_code))

denominator <- readRDS("2_interim_data/denominator.RDS")
denominator <- denominator$all

################################################################################

rf_file <- paste0("./2_interim_data/tx_risk_factors_pg30.rds")

risk_factors <- readRDS(rf_file) %>% 
  select(-rf_group) %>%
  ungroup() %>% 
  distinct()


file2read <- paste0("./2_interim_data/rx_indexed_pg30.rds")

rx_data <- readRDS(file2read) %>%
  ungroup() %>% # needed to remove patid
  select(patid, tx_episode, eventdate, atc_code, rx_type) %>% 
  left_join(risk_factors, 
            by = "tx_episode", 
            relationship = "many-to-many") %>% 
  ungroup() 

ts_risk <- rx_data %>% 
  select(tx_episode, eventdate, atc_code, rx_type, rf_group = rf_subgroup) %>% 
  ts_calculator() %>% 
  mutate(permissible_gap = 30) %>% 
  left_join(atc_codes, by = "atc_code") %>% 
  group_by(eventdate, drug_class_name, rx_type, permissible_gap, rf_group) %>% 
  summarise(n = sum(n)) %>% 
  left_join(denominator, by = "eventdate") %>% 
  mutate(n_adj = n*const$units/denom) %>% 
  select(-denom)

################################################################################

ts_risk %>% 
  filter(drug_class_name == "Fluoroquinolones") %>% 
  ggplot(aes(eventdate, n)) +
  geom_line() +
  facet_grid(rf_group~rx_type)


saveRDS(ts_risk, 
        "./3_clean_data/ts_risk.rds")
