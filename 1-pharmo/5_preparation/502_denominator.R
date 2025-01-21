
source("4_functions/run_my_functions.R")

library(readxl)

################################################################################

pt_all <- read_xlsx("./1_raw_data/PHARMO_GP_denominator.xlsx", sheet = 3) %>% 
  as_tibble() %>% 
  select(2:3) %>% 
  rename(eventdate = 1,
         denom = 2) %>% 
  mutate(eventdate = as.Date(eventdate), 
         days = days_in_month(eventdate), 
         year = year(eventdate)) %>% 
  group_by(year) %>% 
  mutate(year = sum(days)) %>% 
  ungroup() %>% 
  mutate(denom = denom*days/year) %>% 
  select(-c(days, year))

################################################################################

pt_sex <- read_xlsx("./1_raw_data/PHARMO_GP_denominator.xlsx", sheet = 3) %>% 
  as_tibble() %>% 
  select(2, 4:5) %>% 
  rename(eventdate = 1, 
         M = 2, 
         V = 3) %>% 
  pivot_longer(cols = c(M, V)) %>% 
  rename(sex = name, 
         denom = value) %>% 
  mutate(eventdate = as.Date(eventdate), 
         days = days_in_month(eventdate), 
         year = year(eventdate)) %>% 
  group_by(year, sex) %>% 
  mutate(year = sum(days)) %>% 
  ungroup() %>% 
  mutate(denom = denom*days/year) %>% 
  select(-c(days, year))

################################################################################

pt_age <- read_xlsx("./1_raw_data/PHARMO_GP_denominator.xlsx", sheet = 3) %>% 
  as_tibble() %>% 
  select(2, 6:16) %>% 
  rename(eventdate = 1) %>% 
  mutate(`80 and older`  = `80 to < 90 years of age` + `90 and older`) %>% 
  select(-c(`80 to < 90 years of age` , `90 and older`)) %>% 
  pivot_longer(cols = c(2:11)) %>% 
  rename(age_group= name, 
         denom = value) %>% 
  mutate(age_group = gsub(" of age$", "", age_group)) %>% 
  mutate(age_group = gsub("< ", "<", age_group)) %>% 
  mutate(age_group = gsub("80 and older", "80 years and older", age_group)) %>% 
  mutate(eventdate = as.Date(eventdate), 
         days = days_in_month(eventdate), 
         year = year(eventdate)) %>% 
  group_by(year, age_group) %>% 
  mutate(year = sum(days)) %>% 
  ungroup() %>% 
  mutate(denom = denom*days/year) %>% 
  select(-c(days, year))

################################################################################

age_key <- const$age_groups %>% 
  left_join(const$age_groups_simplified, by = "age") %>% 
  select(-age) %>% 
  distinct()

pt_age_simplified <- pt_age %>% 
  left_join(age_key, by = "age_group") %>% 
  select(-age_group) %>% 
  group_by(eventdate, age_group_simplified) %>% 
  summarise(denom = sum(denom))

rm(age_key)


################################################################################
# checks
sum(pt_age$denom)
sum(pt_all$denom)
sum(pt_sex$denom)
sum(pt_age_simplified$denom)

################################################################################

denominator <- list(all = pt_all, 
                    age = pt_age,
                    sex = pt_sex, 
                    age_simplified = pt_age_simplified)

################################################################################
saveRDS(denominator,
        "./2_interim_data/denominator.RDS")

rm(pt_all)
rm(pt_age)
rm(pt_age_simplified)
rm(pt_sex)
rm(denominator)

