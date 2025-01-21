
source("4_functions/run_my_functions.R")
library(haven)

################################################################################

atc_index <- fread("./0_lookup/atc_index.csv")

file2read <- paste0("./2_interim_data/tx_incident_pg30.sas7bdat")
rx_indexed <- read_sas(file2read)

file2read <- paste0("./2_interim_data/tx_risk_factors.sas7bdat")
tx_risk_factors <- read_sas(file2read)

file2read <- paste0("./2_interim_data/tx_indications.sas7bdat")
tx_indications <- read_sas(file2read)

tx_info <- read_sas("./2_interim_data/tx_info_pg30.sas7bdat")

################################################################################

s00_n_tx_episodes <- tx_info %>% 
  ungroup() %>% 
  summarise(n = n()) %>% 
  mutate(variable = "n of treatment episodes")

s01_n_rx <- tx_info %>% 
  # head() %>% 
  ungroup() %>%
  summarise(n = sum(n_rx)) %>% 
  mutate(variable = "n of prescriptions")

temp <- tx_info %>%
  ungroup() %>%
  group_by(patid) %>% 
  summarise(n = n())

summary(temp$n)

s01_tx_per_pt <- unclass(summary(temp$n)) %>%
  as.data.frame() %>%
  rename(n = ".") %>% 
  mutate(variable = "treatment episodes per patient",
         description = rownames(.)) 

s02_n_rx_per_tx <- tx_info %>% 
  ungroup() %>% 
  group_by(n_rx) %>% 
  summarise(n = n(), percent = n*100/nrow(tx_info)) %>% 
  rename(variable = n_rx) %>% 
  head(1) %>% 
  mutate(variable = "single prescription during treatment episode") %>% 
  mutate(description = " ")

s03_n_rx <- unclass(summary(tx_info$n_rx)) %>%
  as.data.frame() %>% 
  rename(n = ".") %>% 
  mutate(variable = "n of prescriptions per treatment episode",
         description = rownames(.))

s04_n_atc <- unclass(summary(tx_info$n_atc)) %>%
  as.data.frame() %>% 
  rename(n = ".") %>% 
  mutate(variable = "n of products per treatment episode",
         description = rownames(.))

rx1 <- rx_indexed %>% 
  group_by(atc_code) %>% 
  summarise(n = n()) %>% 
  left_join(atc_index, by = "atc_code") %>% 
  ungroup() %>% 
  group_by(drug_class_name) %>% 
  summarise(n = sum(n), percent = n*100/nrow(tx_info)) %>% 
  arrange(desc(n)) %>% 
  mutate(variable = "Drug class used to start treatment episode") %>% 
  rename(description = drug_class_name)

rxs <- rx1$description[1:10]

s29_first_ab <- rx1 %>% 
  mutate(description = if_else(!(description %in% rxs), 
                        "Other antibiotics", 
                        description)) %>% 
  group_by(variable, description) %>% 
  summarise(n = sum(n), percent = sum(percent)) %>%   
  arrange(ifelse(description == "other", Inf, -n)) %>% 
  mutate(main = TRUE)


s3a <- tx_info %>% 
  distinct(tx_episode) %>% 
  anti_join(tx_indications, by = "tx_episode") %>% 
  mutate(concept = "Unknown")

s3 <- tx_indications %>% 
  bind_rows(s3a) %>% 
  group_by(dx_group = concept) %>% 
  summarise(n = n(), percent = n*100/nrow(tx_info)) %>% 
  rename(description = dx_group) %>% 
  mutate(variable = "Diagnosis at episode start") %>% 
  arrange(desc(n))


dxs <- s3$description[1:6]  


s3_indications <- s3 %>% 
  mutate(description = if_else(!(description %in% dxs), 
                               "other", 
                               description)) %>% 
  group_by(variable, description) %>% 
  summarise(n = sum(n), percent = n*100/nrow(tx_info)) %>%   
  arrange(ifelse(description == "other", Inf,
                 ifelse(description == "unknown", Inf, -n))) %>% 
  mutate(description = if_else(description == "UNKNOWN", "Unknown", description),
         main = TRUE) 



s3_indications1 <- s3 %>% 
  arrange(ifelse(description == "other", Inf,
                 ifelse(description == "UKNOWN", Inf, -n))) %>% 
  mutate(description = if_else(description == "UKNOWN", "Unknown", description))

s31_multiple <- tx_indications %>% 
  ungroup() %>% 
  group_by(tx_episode) %>%  
  filter(n() > 1) %>% 
  distinct(tx_episode) %>% 
  ungroup() %>% 
  summarise(n = n(), percent = n*100/nrow(tx_info)) %>% 
  mutate(variable = "Diagnosis at episode start",
         description = "Mutliple diagnoses")

s4_rf <- tx_risk_factors %>% 
  ungroup() %>% 
  group_by(rf_group = concept) %>% 
  summarise(n = n(), 
            percent = n*100/nrow(tx_info)) %>% 
  mutate(variable = "Risk factors") %>% 
  rename(description = rf_group) 

s4_rf <- s4_rf %>% 
  mutate(description = case_when(
    description == "prior lipid lowering medication us" ~ "prior lipid lowering medication use",
    description == "prior tobacco use" ~ "tobacco use",
    description == "aortic dissection" ~ "dissection of aorta",
    TRUE ~ description
  ))

s5_rfs <- tx_risk_factors %>% 
  ungroup() %>%
  distinct(tx_episode, rf_group = rf_subgroup) %>% 
  group_by(rf_group) %>% 
  summarise(n = n(), 
            percent = n*100/nrow(tx_info))%>% 
  mutate(variable = "Risk factors") %>% 
  rename(description = rf_group)

tx_summary <- list(
  n_tx_episodes = s00_n_tx_episodes,
  n_rx = s01_n_rx,
  tx_per_pt = s01_tx_per_pt,
  n_rx_per_tx = s02_n_rx_per_tx,
  n_rx_summary = s03_n_rx,
  n_atc_summary = s04_n_atc,
  rx = rx1,
  first_ab_summary = s29_first_ab,
  indications_summary = s3_indications,
  indications_full = s3_indications1,
  multiple_diagnoses = s31_multiple,
  risk_factor = s4_rf,
  risk_factors = s5_rfs
) 

tx_summary <- lapply(tx_summary, function(df) {
  df$database <- const$database
  return(df)
})

################################################################################

saveRDS(tx_summary, "./7_output/tx_summary.rds")


  
  
  
  


