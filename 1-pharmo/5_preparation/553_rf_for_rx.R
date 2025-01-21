
source("4_functions/run_my_functions.R")

# uploading data ###############################################################

risk_factors <- 
  readRDS("./2_interim_data/risk_factors.rds") 

tx_info_files_list <- list.files("./2_interim_data/", 
                                 pattern = "tx_info_pg",
                                 full.names = TRUE)
file_dir <- tx_info_files_list[3]




rf_aorta <- tibble(rf_group = c("aortic aneurysm", "aortic valve disorder",
              "cerebrovascular diseases", "dislipidemia",
              "dissection of aorta", "hypertension",
              "ischemic heart disease", "prior lipid lowering medication use",
              "tobacco use"), 
              rf_subgroup = "aortic")

rf_tendon <- tibble(rf_group = c("renal impairment", "solid organ transplant",
               "tendinitis", "tendon rupture",
               "tobacco use", "concomitant glucocorticoid use"), 
               rf_subgroup = "tendon")

risk_factors <- risk_factors %>% 
  filter(dx_group %in% rf_aorta$rf_group | dx_group %in% rf_tendon$rf_group)

rf_C10 <- readRDS("./2_interim_data/rf_C10.rds") %>% 
  mutate(rf_group = "prior lipid lowering medication use")

rf_H02 <- readRDS("./2_interim_data/rf_H02.rds") %>% 
  mutate(rf_group = "concomitant glucocorticoid use") %>% 
  rename(enddate = end)

rf_grouping <- tibble(
  rf_group = "none", 
  rf_subgroup = "none") %>% 
  bind_rows(rf_aorta) %>% 
  bind_rows(rf_tendon)

distinct(risk_factors, dx_group) %>% 
  semi_join(rf_grouping, by = c("dx_group" = "rf_group"))

rm(rf_aorta, rf_tendon)

################################################################################

for(file_dir in tx_info_files_list){
  
  tx_start <- readRDS(file_dir) %>%
    ungroup() %>% 
    select(tx_episode,
           start, 
           end) %>% 
    mutate(patid = gsub(pattern = "-.*", 
                        replacement = "", 
                        tx_episode))
  
  tx_all_rfs <- tx_start %>% 
    semi_join(risk_factors, by = "patid") %>% 
    left_join(risk_factors, by = "patid", relationship = "many-to-many") %>% 
    filter(dx_date <= start) %>% 
    ungroup() %>% 
    select(tx_episode, rf_group = dx_group) %>% 
    distinct()
  
  tx_C10 <- tx_start %>% 
    right_join(rf_C10, by = "patid", relationship = "many-to-many") %>% 
    filter(eventdate <= start) %>% 
    select(tx_episode, rf_group) %>% 
    distinct()
  
  tx_H02 <- tx_start %>% 
    right_join(rf_H02, by = "patid", relationship = "many-to-many") %>% 
    filter(eventdate <= end & enddate >= start) %>% 
    select(tx_episode, rf_group) %>% 
    distinct()
  
  tx_all_rfs <- tx_all_rfs %>% 
    bind_rows(tx_C10) %>% 
    bind_rows(tx_H02) %>% 
    distinct()
  
  tx_no_rfs <- tx_start %>% 
    anti_join(tx_all_rfs, by = "tx_episode") %>% 
    mutate(rf_group = "none") %>% 
    select(tx_episode, rf_group) %>% 
    distinct()
  
  # check
  nrow(tx_no_rfs) + nrow(tx_all_rfs %>% distinct(tx_episode)) == nrow(tx_start)
  
  tx_risk_factors <- tx_all_rfs %>% 
    bind_rows(tx_no_rfs) %>%
    left_join(rf_grouping, by = "rf_group", relationship = "many-to-many")

  directory <- gsub("tx_info_pg", "tx_risk_factors_pg", file_dir)
  
  saveRDS(tx_risk_factors, 
          directory)
}

