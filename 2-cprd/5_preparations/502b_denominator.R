
source("4_functions/run_my_functions.R")
library(haven)

################################################################################


pt_counts <- read_sas("./2_interim_data/pt_counts_monthly.sas7bdat") %>% 
  select(-yob) %>%
  filter(!(gender == 3))
  

temp_year <- pt_counts %>% 
  distinct(eventdate = date1) %>% 
  mutate(days = days_in_month(eventdate), 
         year = year(eventdate)) %>% 
  group_by(year) %>% 
  mutate(year = sum(days)) %>% 
  mutate(pt = days/year) %>% 
  ungroup() %>% 
  select(eventdate, pt)

################################################################################

pt_all <- pt_counts %>% 
  rename(eventdate = date1) %>% 
  group_by(eventdate) %>% 
  summarise(n = sum(n)) %>% 
  left_join(temp_year, by = "eventdate") %>% 
  ungroup() %>% 
  mutate(denom = n*pt) %>% 
  select(-pt)%>% 
  select(-n)

################################################################################

pt_sex <- pt_counts %>% 
  rename(eventdate = date1) %>% 
  group_by(eventdate, sex = gender) %>%
  filter(!(sex == 3)) %>% 
  summarise(n = sum(n)) %>% 
  left_join(temp_year, by = "eventdate") %>% 
  ungroup() %>% 
  mutate(denom = n*pt) %>% 
  select(-pt)%>% 
  select(-n)

################################################################################

pt_age <- pt_counts %>% 
  rename(eventdate = date1) %>%
  left_join(const$age_groups, by = "age") %>% 
  group_by(eventdate, age_group) %>%
  summarise(n = sum(n)) %>% 
  left_join(temp_year, by = "eventdate") %>% 
  ungroup() %>% 
  mutate(denom = n*pt) %>% 
  select(-pt)%>% 
  select(-n)

################################################################################

pt_age_simplified <- pt_counts %>% 
  rename(eventdate = date1) %>%
  left_join(const$age_groups_simplified, by = "age") %>% 
  group_by(eventdate, age_group_simplified) %>%
  summarise(n = sum(n)) %>% 
  left_join(temp_year, by = "eventdate") %>% 
  ungroup() %>% 
  mutate(denom = n*pt) %>% 
  select(-pt) %>% 
  select(-n)


################################################################################

# check
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


rm(pt_all,
   pt_age,
   pt_age_simplified,
   pt_sex,
   denominator)
