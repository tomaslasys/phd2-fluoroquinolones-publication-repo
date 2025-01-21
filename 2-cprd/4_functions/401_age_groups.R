
age_levels <- c("<2 years", 
                "2 to <12 years",
                "12 to <19 years",
                "19 to <30 years",
                "30 to <40 years",
                "40 to <50 years",
                "50 to <60 years",
                "60 to <70 years",
                "70 to <80 years",
                "80 years and older")

assign_age_group <- function(age) {
  case_when(
    age < 2 ~ "<2 years",
    age < 12 ~ "2 to <12 years",
    age < 19 ~ "12 to <19 years",
    age < 30 ~ "19 to <30 years",
    age < 40 ~ "30 to <40 years",
    age < 50 ~ "40 to <50 years",
    age < 60 ~ "50 to <60 years",
    age < 70 ~ "60 to <70 years",
    age < 80 ~ "70 to <80 years",
    TRUE ~ "80 years and older")}

const$age_groups <- tibble(age = 1:130) %>% 
  mutate(age_group = assign_age_group(age)) %>% 
  mutate(age_group = factor(age_group,
                            levels = age_levels,
                            ordered = TRUE))

################################################################################

age_levels <- c("<19 years",
                "19 to <60 years",
                "60 years and older")

assign_age_group <- function(age) {
  case_when(
    age < 19 ~ "<19 years",
    age < 60 ~ "19 to <60 years",
    TRUE ~ "60 years and older")}

const$age_groups_simplified <- tibble(age = 1:130) %>% 
  mutate(age_group_simplified = assign_age_group(age)) %>% 
  mutate(age_group_simplified = factor(age_group_simplified,
                            levels = age_levels,
                            ordered = TRUE))

################################################################################

rm(age_levels)
rm(assign_age_group)
