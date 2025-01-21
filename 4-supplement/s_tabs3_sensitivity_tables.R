
source("./functions/400_constants.R")

fq_pg_nl <- readRDS("./1-pharmo/7_output/groups_main.rds") 
fq_pg_uk <- readRDS("./2-cprd/7_output/groups_main.rds")


models_pg <- fq_pg_nl[2] %>% 
  bind_rows(fq_pg_uk[2]) %>%
  mutate(rx_type = factor(rx_type, 
                          levels = c("incident", "add-on", "continued"))) %>%
  filter(drug == "Fluoroquinolones") %>% 
  arrange(database, rx_type, permissible_gap) %>% 
  select(drug,
         database, 
         rx_type,
         permissible_gap, 
         "Database" = "database",
         "Drug class" = "drug",
         "(Intercept)[95% CI]" = "(Intercept)",
         "Slope before RMMs[95% CI]" = "time",
         "Step change after 2018/19 RMMs [95% CI]" = "rmm1",
         "Slope change after 2018/19 RMMs[95% CI]" = "time_after_rmm1",
         "Step change after 2020 RMMs [95% CI]" = "rmm2",
         "Slope change after 2020 RMMs[95% CI]" = "time_after_rmm2"
  )



covid_nl <- readRDS("./1-pharmo/7_output/groups_covid.rds")
covid_uk <- readRDS("./2-cprd/7_output/groups_covid.rds")


models_covid <- covid_nl[2] %>% 
  bind_rows(covid_uk[2]) %>%
  mutate(rx_type = factor(rx_type, 
                          levels = c("incident", "add-on", "continued"))) %>%
  arrange(database, rx_type) %>% 
  filter(permissible_gap == 30) %>% 
  select(permissible_gap,
         lag,
         rx_type,
         database,
         drug,
         "Database" = "database",
         "Drug class" = "drug",
         "(Intercept)[95% CI]" = "(Intercept)",
         "Slope before RMMs[95% CI]" = "time",
         "Step change after 2018/19 RMMs [95% CI]" = "rmm1",
         "Slope change after 2018/19 RMMs[95% CI]" = "time_after_rmm1"
  ) %>%  
  filter(rx_type == "incident")

rm(covid_nl, covid_uk)

models_covid_fq <- models_covid %>% 
  filter(`Drug class` == "Fluoroquinolones")

models_covid_all <- models_covid %>% 
  filter(lag %in% c(0))




no_lag_nl <- readRDS("./1-pharmo/7_output/groups_lags.rds")
no_lag_uk <- readRDS("./2-cprd/7_output/groups_lags.rds")

models_lags <- no_lag_nl[2] %>%
  bind_rows(no_lag_uk[2]) %>%
  mutate(rx_type = factor(rx_type,
                          levels = c("incident", "add-on", "continued"))) %>%
  arrange(database, rx_type) %>%
  select(permissible_gap,
         lag,
         rx_type,
         database,
         drug,
         "Database" = "database",
         "Drug class" = "drug",
         "(Intercept)[95% CI]" = "(Intercept)",
         "Slope before RMMs[95% CI]" = "time",
         "Step change after 2018/19 RMMs [95% CI]" = "rmm1",
         "Slope change after 2018/19 RMMs[95% CI]" = "time_after_rmm1",
         "Step change after 2020 RMMs [95% CI]" = "rmm2",
         "Slope change after 2020 RMMs[95% CI]" = "time_after_rmm2"
  ) %>%
  filter(rx_type == "incident") %>%
  filter(permissible_gap == 30)

rm(no_lag_nl, no_lag_uk)

models_lags_fq <- models_lags %>% 
  filter(`Drug class` == "Fluoroquinolones")

models_lags_all <- models_lags %>% 
  filter(lag %in% c(0))



seasonal_nl <- readRDS("./1-pharmo/7_output/groups_seasonal.rds")
seasonal_uk <- readRDS("./2-cprd/7_output/groups_seasonal.rds")


models_seasonal <- seasonal_nl[2] %>% 
  bind_rows(seasonal_uk[2]) %>%
  mutate(rx_type = factor(rx_type, 
                          levels = c("incident", "add-on", "continued"))) %>%
  arrange(database, rx_type) %>% 
  select(permissible_gap, 
         rx_type,
         database,
         drug,
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


# save models in an excel file

models <- list(permissible_gaps = models_pg,
                covid_fq = models_covid_fq,
               covid_all = models_covid_all,
               lags_fq = models_lags_fq,
               lags_all = models_lags_all,
               seasonal = models_seasonal)

writexl::write_xlsx(models, "./output/xlsx/s_sensitivity.xlsx")

