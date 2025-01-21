# 
# 
source("./4_functions/run_my_functions.R")
# source("./4_functions/run_my_functions.R")
# 
library(haven)


atc_codes <- fread("./0_lookup/atc_index.csv")

denominator <- readRDS("./2_interim_data/denominator.RDS")

ts_all <- read_sas("./3_clean_data/ts_main.sas7bdat") 
  

temp <- ts_all %>% 
  group_by(permissible_gap) %>% 
  summarise(n = sum(n))



shell <- tibble(eventdate= unique(ts_all$eventdate)) %>%
  cross_join(tibble(atc_code = unique(ts_all$atc_code))) %>%
  cross_join(tibble(rx_type = unique(ts_all$rx_type))) %>%
  cross_join(tibble(permissible_gap = unique(ts_all$permissible_gap))) %>% 
  ungroup()

ts_individual <- shell %>%
  left_join(ts_all, by = c("eventdate", "atc_code", "rx_type", "permissible_gap" )) %>% 
  left_join(atc_codes, by = "atc_code") %>% 
  mutate(n = replace_na(n, 0)) %>% 
  group_by(eventdate, drug_class_name, atc_name, rx_type, permissible_gap) %>%
  summarise(n = sum(n)) %>% 
  left_join(denominator$all, by = "eventdate") %>%
  mutate(n_adj = n*const$units/denom) %>%
  select(-denom) %>% 
  ungroup()

ts_groups <- ts_individual %>%
  ungroup() %>%
  group_by(eventdate, drug_class_name, rx_type, permissible_gap) %>%
  summarise(n = sum(n),
            n_adj = sum(n_adj)) %>% 
  ungroup()

sum(ts_groups$n/4)
sum(ts_individual$n/4)

saveRDS(ts_groups, 
        "./3_clean_data/ts_groups.RDS")

saveRDS(ts_individual, 
        "./3_clean_data/ts_individual.RDS")

####################################################################################

shell <- tibble(eventdate= unique(ts_all$eventdate)) %>%
  cross_join(tibble(drug_class_name = unique(ts_groups$drug_class_name))) %>%
  cross_join(tibble(rx_type = unique(ts_all$rx_type))) %>%
  cross_join(tibble(age_group = const$age_groups$age_group)) %>% 
  ungroup() %>% 
  distinct()


ts_age <- read_sas("./3_clean_data/ts_age.sas7bdat") %>% 
  left_join(const$age_groups, by = "age") %>% 
  na.omit() %>% 
  left_join(atc_codes, by = "atc_code") %>% 
  group_by(eventdate, rx_type, age_group, drug_class_name) %>% 
  summarise(n = sum(n))  %>% 
  right_join(shell, by = c("eventdate", "drug_class_name", "rx_type", "age_group")) %>% 
  mutate(n = replace_na(n, 0)) %>% 
  ungroup() %>% 
  mutate(permissible_gap = 30) %>% 
  group_by(eventdate, drug_class_name, rx_type, age_group, permissible_gap) %>% 
  left_join(denominator$age, by = c("eventdate", "age_group")) %>% 
  mutate(n_adj = n*const$units/denom) %>%
  select(-denom) %>% 
  ungroup()

sum(ts_age$n)

saveRDS(ts_age, 
        "./3_clean_data/ts_age.RDS")





shell <- tibble(eventdate= unique(ts_all$eventdate)) %>%
  cross_join(tibble(drug_class_name = unique(ts_groups$drug_class_name))) %>%
  cross_join(tibble(rx_type = unique(ts_all$rx_type))) %>%
  cross_join(tibble(age_group_simplified = const$age_groups_simplified$age_group_simplified)) %>% 
  ungroup() %>% 
  distinct()


ts_age <- read_sas("./3_clean_data/ts_age.sas7bdat") %>% 
  left_join(const$age_groups_simplified, by = "age") %>% 
  na.omit() %>% 
  left_join(atc_codes, by = "atc_code") %>% 
  group_by(eventdate, rx_type, age_group_simplified, drug_class_name) %>% 
  summarise(n = sum(n))  %>% 
  right_join(shell, by = c("eventdate", "drug_class_name", "rx_type", "age_group_simplified")) %>% 
  mutate(n = replace_na(n, 0)) %>% 
  ungroup() %>% 
  mutate(permissible_gap = 30) %>% 
  group_by(eventdate, drug_class_name, rx_type, age_group_simplified, permissible_gap) %>% 
  left_join(denominator$age_simplified, by = c("eventdate", "age_group_simplified")) %>% 
  mutate(n_adj = n*const$units/denom) %>%
  select(-denom) %>% 
  ungroup()
sum(ts_age$n)

saveRDS(ts_age, 
        "./3_clean_data/ts_age_simplified.RDS")



shell <- tibble(eventdate= unique(ts_all$eventdate)) %>%
  cross_join(tibble(drug_class_name = unique(ts_groups$drug_class_name))) %>%
  cross_join(tibble(rx_type = unique(ts_all$rx_type))) %>%
  cross_join(tibble(sex = c(1 , 2))) %>% 
  ungroup() %>% 
  distinct() %>% 
  na.omit()


ts_sex <- read_sas("./3_clean_data/ts_sex.sas7bdat") %>% 
  na.omit() %>% 
  left_join(atc_codes, by = "atc_code") %>% 
  group_by(eventdate, rx_type, sex = gender, drug_class_name) %>% 
  summarise(n = sum(n))  %>% 
  right_join(shell, by = c("eventdate", "drug_class_name", "rx_type", "sex")) %>% 
  mutate(n = replace_na(n, 0)) %>% 
  ungroup() %>% 
  mutate(permissible_gap = 30) %>% 
  group_by(eventdate, drug_class_name, rx_type, sex, permissible_gap) %>% 
  left_join(denominator$sex, by = c("eventdate", "sex")) %>% 
  mutate(n_adj = n*const$units/denom) %>%
  select(-denom) %>% 
  ungroup()

sum(ts_sex$n)

saveRDS(ts_sex, 
        "./3_clean_data/ts_sex.RDS")





ts_fq_group <- ts_groups %>% 
  filter(drug_class_name == "Fluoroquinolones") %>% 
  group_by(eventdate, drug_class_name, rx_type, permissible_gap) %>% 
  summarise(n = sum(n),
            n_adj = sum(n_adj)) %>% 
  mutate(atc_name = "any fluoroquinolone")

ts_fq_individual <- ts_individual %>% 
  filter(drug_class_name == "Fluoroquinolones")

ts_fq <- ts_fq_group %>% 
  bind_rows(ts_fq_individual) %>% 
  ungroup() %>% 
  ungroup()

saveRDS(ts_fq, 
        "./3_clean_data/ts_fq.RDS")












shell <- tibble(eventdate= unique(ts_all$eventdate)) %>%
  cross_join(tibble(drug_class_name = unique(ts_groups$drug_class_name))) %>%
  cross_join(tibble(rx_type = unique(ts_all$rx_type))) %>%
  cross_join(tibble(sex = c(1 , 2))) %>% 
  ungroup() %>% 
  distinct() %>% 
  na.omit()


ts_dx <- read_sas("./3_clean_data/ts_dx.sas7bdat") %>% 
  na.omit() %>% 
  left_join(atc_codes, by = "atc_code") %>% 
  group_by(eventdate, rx_type, dx_group, drug_class_name) %>% 
  summarise(n = sum(n))  

shell <- tibble(eventdate= unique(ts_all$eventdate)) %>%
  cross_join(tibble(drug_class_name = unique(ts_groups$drug_class_name))) %>%
  cross_join(tibble(rx_type = unique(ts_all$rx_type))) %>%
  cross_join(tibble(dx_group = unique(ts_dx$dx_group))) %>% 
  ungroup() %>% 
  distinct() %>% 
  na.omit()



ts_dx1 <- ts_dx %>% 
  right_join(shell, by = c("eventdate", "drug_class_name", "rx_type", "dx_group")) %>% 
  mutate(n = replace_na(n, 0)) %>% 
  ungroup() %>% 
  mutate(permissible_gap = 30) %>% 
  group_by(eventdate, drug_class_name, rx_type, dx_group, permissible_gap) %>% 
  left_join(denominator$all, by = c("eventdate")) %>% 
  mutate(n_adj = n*const$units/denom) %>%
  select(-denom) %>% 
  ungroup()

saveRDS(ts_dx1, 
        "./3_clean_data/ts_indications.RDS")













ts_rf <- read_sas("./3_clean_data/ts_rf.sas7bdat") %>% 
  na.omit() %>% 
  left_join(atc_codes, by = "atc_code") %>% 
  group_by(eventdate, rx_type, rf_group = rf_subgroup, drug_class_name) %>% 
  summarise(n = sum(n))  

shell <- tibble(eventdate= unique(ts_all$eventdate)) %>%
  cross_join(tibble(drug_class_name = unique(ts_groups$drug_class_name))) %>%
  cross_join(tibble(rx_type = unique(ts_all$rx_type))) %>%
  cross_join(tibble(rf_group = unique(ts_rf$rf_group))) %>% 
  ungroup() %>% 
  distinct() %>% 
  na.omit()



ts_rf1 <- ts_rf %>% 
  right_join(shell, by = c("eventdate", "drug_class_name", "rx_type", "rf_group")) %>% 
  mutate(n = replace_na(n, 0)) %>% 
  ungroup() %>% 
  mutate(permissible_gap = 30) %>% 
  group_by(eventdate, drug_class_name, rx_type, rf_group, permissible_gap) %>% 
  left_join(denominator$all, by = c("eventdate")) %>% 
  mutate(n_adj = n*const$units/denom) %>%
  select(-denom) %>% 
  ungroup()

saveRDS(ts_rf1, 
        "./3_clean_data/ts_risk.RDS")







library(ggplot2)


temp <- ts_groups %>% 
  ungroup() %>% 
  group_by(eventdate, rx_type, permissible_gap) %>% 
  summarise(n_adj = sum(n_adj)) 

ggplot(temp, aes(x = eventdate, y = n_adj)) +
         geom_line() +
         facet_grid(rx_type~permissible_gap)







temp <- ts_groups %>% 
  ungroup() %>% 
  filter(rx_type == "incident" & permissible_gap == 30) %>% 
  group_by(drug_class_name) %>% 
  summarise(n = sum(n), percent = round(100*n/(10574681), 1))


temp1 <- temp %>% 
  arrange(desc(n)) %>% 
  tail(10) %>% 
  filter(drug_class_name != "Other antibacterials (J01XX)") %>% 
  summarise(n = sum(n), percent =round(100*n/(10574681), 1))








temp2 <- ts_dx %>% 
  filter(drug_class_name == "Fluoroquinolones") %>% 
  ungroup() %>% 
  group_by(dx_group) %>% 
  summarise(n = sum(n))
       

100*7235/sum(temp2$n)
100*141243/sum(temp2$n)



ts_sex %>% 
  filter(rx_type == "incident" & drug_class_name == "Fluoroquinolones") %>% 
  ungroup() %>% 
  group_by(sex) %>% 
  summarise(n = sum(n))



ts_age %>% 
  filter(rx_type == "incident" & drug_class_name == "Fluoroquinolones") %>% 
  ungroup() %>% 
  group_by(age_group_simplified) %>% 
  summarise(n = sum(n))



temp <-ts_rf %>% 
  filter(rx_type == "incident" & drug_class_name == "Fluoroquinolones") %>% 
  ungroup() %>% 
  group_by(rf_group) %>% 
  summarise(n = sum(n), perc = n*100/sum(temp2$n))



flowchart <- read_sas("./2_interim_data/flowchart.sas7bdat")

saveRDS(flowchart, "7_output/flowchart.rds")
