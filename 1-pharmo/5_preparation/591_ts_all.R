
source("4_functions/run_my_functions.R")
source("4_functions/ts_calculator.R")

################################################################################

atc_codes <- fread("./0_lookup/atc_index.csv") %>% 
  filter(grepl("^J01", atc_code))

demographics <- readRDS("2_interim_data/cohort_info.RDS") %>% 
  select(patid, yob, sex)

denominator <- readRDS("2_interim_data/denominator.RDS")

################################################################################

ts_all_tables <- tibble()

gap = 30

for(gap in const$permissible_gaps){

  file2read <- paste0("./2_interim_data/rx_indexed_pg", 
                      gap, 
                      ".rds")
  
  rxfile <- readRDS(file2read)
  
  ts_table <- rxfile %>%
    ungroup() %>% # needed to remove patid
    select(tx_episode, eventdate, atc_code, rx_type) %>% 
    ungroup() %>% 
    ts_calculator() %>% 
    left_join(atc_codes, by = "atc_code") %>% 
    mutate(permissible_gap = gap)
  
  ts_all_tables <- ts_all_tables %>% 
    bind_rows(ts_table)
  
  print(paste0("TS data set with ",
               gap, 
               " days permissible gap generated"))
  
  print(nrow(rxfile))
  print(rxfile %>% ungroup() %>% distinct(patid) %>% nrow())
  
  rm(rxfile)
  rm(file2read)
  rm(ts_table)
  rm(gap)
  
}


check <- ts_all_tables %>% 
  filter(is.na(atc_name)) %>% 
  distinct(atc_code)

check <- ts_all_tables %>% 
  ungroup() %>% 
  group_by(permissible_gap) %>% 
  summarise(n = sum(n))

check

################################################################################

ts_groups <- ts_all_tables %>% 
  ungroup() %>% 
  group_by(eventdate, drug_class_name, rx_type, permissible_gap) %>% 
  summarize(n = sum(n)) %>% 
  ungroup() %>% 
  left_join(denominator$all, by = "eventdate") %>% 
  mutate(n_adj = n*const$units/denom) %>% 
  select(-denom)

check1 <- ts_groups %>% 
  ungroup() %>% 
  filter(drug_class_name == "Fluoroquinolones" ) %>% 
  group_by(permissible_gap) %>% 
  summarise(n = sum(n))

check1

saveRDS(ts_groups, 
        "./3_clean_data/ts_groups.rds")

################################################################################

ts_individual <- ts_all_tables %>% 
  ungroup() %>% 
  group_by(eventdate, drug_class_name, atc_name, rx_type, permissible_gap) %>% 
  summarize(n = sum(n)) %>% 
  ungroup()%>% 
  left_join(denominator$all, by = "eventdate") %>% 
  mutate(n_adj = n*const$units/denom) %>% 
  select(-denom)

check2 <- ts_groups %>% 
  ungroup() %>% 
  group_by(permissible_gap) %>% 
  summarise(n = sum(n))

check2

saveRDS(ts_individual, 
        "./3_clean_data/ts_individual.rds")

################################################################################

ts_fq_group <- ts_groups %>% 
  filter(drug_class_name == "Fluoroquinolones") %>% 
  mutate(atc_name = "any fluoroquinolone")

ts_fq_individual <- ts_individual %>% 
  filter(drug_class_name == "Fluoroquinolones")

ts_fq <- ts_fq_group %>% 
  bind_rows(ts_fq_individual)

saveRDS(ts_fq, 
        "./3_clean_data/ts_fq.rds")

################################################################################

gap = 30

rx_data <- readRDS("./2_interim_data/rx_indexed_pg30.rds") %>% 
  select(patid, tx_episode, eventdate, atc_code, rx_type) %>% 
  left_join(demographics, by = "patid") %>% 
  mutate(age = year(eventdate) - yob) %>% 
  select(-yob)

#check  
nrow(rx_data)

################################################################################
################################################################################

ts_age <- rx_data %>% 
  left_join(const$age_groups, by = "age") %>% 
  ungroup() %>% # needed to remove patid
  select(tx_episode, eventdate, atc_code, rx_type, age_group) %>% 
  ungroup() %>% 
  ts_calculator() %>% 
  left_join(atc_codes, by = "atc_code") %>% 
  mutate(permissible_gap = gap) %>% 
  ungroup() %>% 
  group_by(eventdate, drug_class_name, rx_type, age_group, permissible_gap) %>% 
  summarize(n = sum(n)) %>% 
  ungroup() %>% 
  left_join(denominator$age, by = c("eventdate", "age_group")) %>% 
  mutate(n_adj = n*const$units/denom) %>% 
  select(-denom)

#check 
sum(ts_age$n)
sum(ts_age$n_adj)

saveRDS(ts_age, 
        "./3_clean_data/ts_age.rds")

rm(ts_age)

################################################################################

ts_age_simplfied <- rx_data %>% 
  left_join(const$age_groups_simplified, by = "age") %>% 
  ungroup() %>% # needed to remove patid
  select(tx_episode, eventdate, atc_code, rx_type, age_group_simplified) %>% 
  ungroup() %>% 
  ts_calculator() %>% 
  left_join(atc_codes, by = "atc_code") %>% 
  mutate(permissible_gap = gap) %>% 
  ungroup() %>% 
  group_by(eventdate, drug_class_name, rx_type, age_group_simplified, permissible_gap) %>% 
  summarize(n = sum(n)) %>% 
  ungroup() %>% 
  left_join(denominator$age_simplified, by = c("eventdate", "age_group_simplified")) %>% 
  mutate(n_adj = n*const$units/denom) %>% 
  select(-denom)

#check 
sum(ts_age_simplfied$n)
sum(ts_age_simplfied$n_adj)

saveRDS(ts_age_simplfied, 
        "./3_clean_data/ts_age_simplified.rds")

rm(ts_age_simplfied)

################################################################################

ts_sex <- rx_data %>%
  ungroup() %>% # needed to remove patid
  select(tx_episode, eventdate, atc_code, rx_type, sex) %>% 
  ungroup() %>% 
  ts_calculator() %>% 
  left_join(atc_codes, by = "atc_code") %>% 
  mutate(permissible_gap = gap) %>% 
  group_by(eventdate, drug_class_name, rx_type, sex, permissible_gap) %>% 
  summarize(n = sum(n)) %>% 
  ungroup() %>% 
  left_join(denominator$sex, by = c("eventdate", "sex")) %>% 
  mutate(n_adj = n*const$units/denom) %>% 
  select(-denom)


sum(ts_sex$n)
sum(ts_sex$n_adj)

saveRDS(ts_sex, 
        "./3_clean_data/ts_sex.rds")

rm(ts_sex)

################################################################################

rm(ts_all_tables)
rm(ts_calculator)
