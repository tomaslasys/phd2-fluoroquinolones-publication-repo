
source("./functions/400_constants.R")

sex_nl <- readRDS("./1-pharmo/7_output/fq_sex.rds")
sex_uk <- readRDS("./2-cprd/7_output/fq_sex.rds")


models_sex <- sex_nl[2] %>% 
  bind_rows(sex_uk[2]) %>%
  mutate(sex = case_when(sex =="M" ~ "male",
                          sex == "V"~ "female", 
                         sex == "1" ~ "male", 
                         sex == "2" ~ "female",
                          TRUE ~ sex)) %>% 
  mutate(rx_type = factor(rx_type, 
                          levels = c("incident", "add-on", "continued"))) %>%
  arrange(database, rx_type, sex) %>% 
  select(permissible_gap, 
         drug,
         rx_type,
         database, 
         sex,
         "Database" = "database",
         "Drug class" = "drug",
         "(Intercept)[95% CI]" = "(Intercept)",
         "Slope before RMMs[95% CI]" = "time",
         "Step change after 2018/19 RMMs [95% CI]" = "rmm1",
         "Slope change after 2018/19 RMMs[95% CI]" = "time_after_rmm1",
         "Step change after 2020 RMMs [95% CI]" = "rmm2",
         "Slope change after 2020 RMMs[95% CI]" = "time_after_rmm2"
  ) %>%  
  filter(rx_type == "incident")
rm(sex_nl, sex_uk)




age_nl <- readRDS("./1-pharmo/7_output/fq_age.rds")
age_uk<- readRDS("./2-cprd/7_output/fq_age.rds")


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

models_age <- age_nl[2] %>% 
  bind_rows(age_uk[2]) %>%
  mutate(rx_type = factor(rx_type, 
                          levels = c("incident", "add-on", "continued"))) %>%
  mutate(age_group = factor(age_group,
                            levels = age_levels,
                            ordered = TRUE)) %>%
  arrange(database, rx_type, age_group) %>% 
  select(permissible_gap, 
         drug,
         rx_type,
         database, 
         age_group,
         "Database" = "database",
         "Drug class" = "drug",
         "(Intercept)[95% CI]" = "(Intercept)",
         "Slope before RMMs[95% CI]" = "time",
         "Step change after 2018/19 RMMs [95% CI]" = "rmm1",
         "Slope change after 2018/19 RMMs[95% CI]" = "time_after_rmm1",
         "Step change after 2020 RMMs [95% CI]" = "rmm2",
         "Slope change after 2020 RMMs[95% CI]" = "time_after_rmm2"
  ) %>%  
  filter(rx_type == "incident")
rm(age_nl, age_uk)




age_nl <- readRDS("./1-pharmo/7_output/fq_age_simplified.rds")
age_uk<- readRDS("./2-cprd/7_output/fq_age_simplified.rds")


age_levels <- c("<19 years",
                "19 to <60 years",
                "60 years and older")

models_age1 <- age_nl[2] %>% 
  bind_rows(age_uk[2]) %>%
  mutate(rx_type = factor(rx_type, 
                          levels = c("incident", "add-on", "continued"))) %>%
  mutate(age_group_simplified = factor(age_group_simplified,
                            levels = age_levels,
                            ordered = TRUE)) %>%
  arrange(database, rx_type, age_group_simplified) %>% 
  select(permissible_gap, 
         drug,
         rx_type,
         database, 
         age_group_simplified,
         "Database" = "database",
         "Drug class" = "drug",
         "(Intercept)[95% CI]" = "(Intercept)",
         "Slope before RMMs[95% CI]" = "time",
         "Step change after 2018/19 RMMs [95% CI]" = "rmm1",
         "Slope change after 2018/19 RMMs[95% CI]" = "time_after_rmm1",
         "Step change after 2020 RMMs [95% CI]" = "rmm2",
         "Slope change after 2020 RMMs[95% CI]" = "time_after_rmm2"
  ) %>%  
  filter(rx_type == "incident")
rm(age_nl, age_uk)





rf_nl <- readRDS("./1-pharmo/7_output/fq_risk_groups.rds")
rf_uk <- readRDS("./2-cprd/7_output/fq_risk_groups.rds")


rf_levels <- c("aortic", 
                "tendon",
                "none")

models_rf <- rf_nl[2] %>% 
  bind_rows(rf_uk[2]) %>%
  mutate(rf_group = factor(rf_group,
                            levels = rf_levels,
                            ordered = TRUE)) %>%
  arrange(database, rx_type, rf_group) %>% 
  select(permissible_gap, 
         drug,
         rx_type,
         database, 
         rf_group,
         "Database" = "database",
         "Drug class" = "drug",
         "(Intercept)[95% CI]" = "(Intercept)",
         "Slope before RMMs[95% CI]" = "time",
         "Step change after 2018/19 RMMs [95% CI]" = "rmm1",
         "Slope change after 2018/19 RMMs[95% CI]" = "time_after_rmm1",
         "Step change after 2020 RMMs [95% CI]" = "rmm2",
         "Slope change after 2020 RMMs[95% CI]" = "time_after_rmm2"
  )
rm(rf_nl, rf_uk)




dx_nl <- readRDS("./1-pharmo/7_output/fq_indications.rds")
dx_uk <- readRDS("./2-cprd/7_output/fq_indications.rds") 


dx_levels <- c("urinary tract infections", 
               "other", 
               "Unknown")

models_dxs <- dx_nl[2] %>% 
  bind_rows(dx_uk[2]) %>%
  mutate(dx_group = case_when(
    dx_group == "none" ~ "Unknown",
    TRUE ~ dx_group)) %>% 
  filter(dx_group %in% dx_levels) %>%
  mutate(rf_group = factor(dx_group,
                           levels = dx_levels,
                           ordered = TRUE)) %>%
  arrange(database, rx_type, rf_group) %>% 
  select(permissible_gap, 
         drug,
         rx_type,
         database, 
         dx_group,
         "Database" = "database",
         "Drug class" = "drug",
         "(Intercept)[95% CI]" = "(Intercept)",
         "Slope before RMMs[95% CI]" = "time",
         "Step change after 2018/19 RMMs [95% CI]" = "rmm1",
         "Slope change after 2018/19 RMMs[95% CI]" = "time_after_rmm1",
         "Step change after 2020 RMMs [95% CI]" = "rmm2",
         "Slope change after 2020 RMMs[95% CI]" = "time_after_rmm2"
  )

rm(dx_nl, dx_uk)




# save models in an excel file

models <- list(sex = models_sex, 
               age = models_age,
               age_simplified = models_age1,
               indications = models_dxs,
               risk_factors = models_rf)

writexl::write_xlsx(models, "./output/xlsx/s_covariates.xlsx")
