
source("./4_functions/run_my_functions.R")

library(haven)
################################################################################

gap = 30

rf_at_index <- read_sas("./2_interim_data/rf_at_index.sas7bdat") %>% 
  rename(rf_group = concept)

cohort <- read_sas("./2_interim_data/cohort_info.sas7bdat") %>% 
  left_join(const$age_groups, by = "age") %>% 
  left_join(const$age_groups_simplified, by = "age")

s00_n_of_patients <- cohort %>% 
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


index <- list(
  n_of_patients = s00_n_of_patients,
  # n_rx = s01_n_rx,
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

################################################################################

flowchart <- read_sas("./2_interim_data/flowchart.sas7bdat")

saveRDS(flowchart, 
        "./7_output/flowchart.rds")

