
source("./4_functions/run_my_functions.R")

################################################################################

demographics <- readRDS("2_interim_data/cohort_info.rds")

gap = 30

rx_file <- paste0("./2_interim_data/rx_indexed_pg", gap, ".RDS")
rf_file <- paste0("./2_interim_data/tx_risk_factors_pg", gap, ".RDS")

rx_indexed <- readRDS(rx_file)

rf_at_index <- readRDS(rf_file) %>% 
  mutate(patid = gsub("-.*", "", tx_episode), 
         tx = gsub(".*-", "", tx_episode)) %>% 
  filter(tx == 1) %>% 
  select(patid, rf_group, rf_subgroup)

cohort <- rx_indexed %>%
  ungroup() %>%
  group_by(patid) %>%
  filter(eventdate == min(eventdate)) %>% 
  distinct(patid, eventdate) %>% 
  rename(index_date = eventdate) %>% 
  left_join(demographics, by = "patid") %>% 
  mutate(age = year(index_date) - yob, 
         lookback = as.numeric(index_date - crd)*12/365.25,
         followup = as.numeric(tod - index_date)*12/365.25) %>% 
  left_join(const$age_groups, by = "age") %>% 
  left_join(const$age_groups_simplified, by = "age")

################################################################################

s01_n_of_patients <- cohort %>% 
  ungroup() %>% 
  distinct(patid) %>% 
  summarise(n = n()) %>% 
  mutate(variable = "n of patients")

s02_sex <- cohort %>% 
  group_by(sex) %>% 
  summarise(n = n(), percent = n * 100 / nrow(cohort)) %>% 
  rename(description = sex) %>% 
  mutate(variable = "sex",
         description = case_when(
           description == "M" ~ "male", 
           description == "V" ~ "female"))

s03_age <- unclass(summary(cohort$age)) %>% 
  as.data.frame() %>% 
  rename(n = ".") %>% 
  mutate(variable = "Age",
         description = rownames(.)) 

s04_age_groups <- cohort %>% 
  group_by(age_group) %>% 
  summarise(age = min(age), n = n(), percent = n * 100 / nrow(cohort)) %>% 
  arrange(age) %>% 
  select(-age) %>% 
  rename(description = age_group) %>% 
  mutate(variable = "age groups") 

s04a_age_groups_simplified <- cohort %>% 
  group_by(age_group_simplified) %>% 
  summarise(age = min(age), n = n(), percent = n * 100 / nrow(cohort)) %>% 
  arrange(age) %>% 
  select(-age) %>% 
  rename(description = age_group_simplified) %>% 
  mutate(variable = "age groups simplified")

s05_entry_year <- cohort %>% 
  mutate(year = year(index_date)) %>% 
  group_by(year) %>% 
  summarise(n = n(), percent = n * 100 / nrow(cohort)) %>% 
  rename(description = year) %>% 
  mutate(variable = "entry year", 
         description = as.character(description))

s06_lookback <- unclass(summary(cohort$lookback)) %>% 
  as.data.frame() %>% 
  rename(n = ".") %>% 
  mutate(variable = "lookback window (in months)",
         description = rownames(.)) 

s07_followup <- unclass(summary(cohort$followup)) %>% 
  as.data.frame() %>% 
  rename(n = ".") %>% 
  mutate(variable = "follow-up (in months)",
         description = rownames(.))

s08_rf_at_index <- rf_at_index %>% 
  ungroup() %>% 
  select(patid, rf_group) %>% 
  distinct() %>% 
  group_by(rf_group) %>% 
  summarise(n = n(), percent = n * 100 / nrow(cohort)) %>% 
  rename(description = rf_group) %>% 
  mutate(variable = "risk factor") %>% 
  arrange(desc(n))

s08a_rfs_at_index <- rf_at_index %>% 
  ungroup() %>% 
  select(patid, rf_subgroup) %>% 
  distinct() %>% 
  group_by(rf_subgroup) %>% 
  summarise(n = n(), percent = n * 100 / nrow(cohort)) %>% 
  rename(description = rf_subgroup) %>% 
  mutate(variable = "risk factor group") 

################################################################################

index <- list(
  n_of_patients = s01_n_of_patients,
  sex = s02_sex,
  age = s03_age,
  age_groups = s04_age_groups,
  entry_year = s05_entry_year,
  lookback = s06_lookback,
  followup = s07_followup,
  rf_at_index = s08_rf_at_index,
  rfs_at_index = s08a_rfs_at_index)

index <- lapply(index, function(df) {
  df$database <- const$database
  return(df)
})
  
################################################################################

saveRDS(index , "./7_output/summary_index_pg30.RDS")

