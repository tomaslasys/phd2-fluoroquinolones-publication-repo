
source("./functions/400_constants.R")

fq_nl <- readRDS("./1-pharmo/7_output/fq_main.rds") 
fq_uk <- readRDS("./2-cprd/7_output/fq_main.rds")


models_fq <- fq_nl[2] %>% 
  bind_rows(fq_uk[2]) %>%
  mutate(rx_type = factor(rx_type, 
                          levels = c("incident", "add-on", "continued"))) %>%
  filter(!(drug == "any fluoroquinolone")) %>%
  # filter(rx_type == "incident") %>%
  arrange(database, drug, rx_type) %>% 
  select( permissible_gap,
          database, 
          drug,
          rx_type, 
         "Database" = "database",
         "Drug class" = "drug",
         "(Intercept)[95% CI]" = "(Intercept)",
         "Slope before RMMs[95% CI]" = "time",
         "Step change after 2018/19 RMMs [95% CI]" = "rmm1",
         "Slope change after 2018/19 RMMs[95% CI]" = "time_after_rmm1",
         "Step change after 2020 RMMs [95% CI]" = "rmm2",
         "Slope change after 2020 RMMs[95% CI]" = "time_after_rmm2"
  )

rm(fq_nl, fq_uk)




groups_nl <- readRDS("./1-pharmo/7_output/groups_main.rds")
groups_uk <- readRDS("./2-cprd/7_output/groups_main.rds")

models_groups <- groups_nl[2] %>% 
  bind_rows(groups_uk[2]) %>%
  filter(rx_type == "incident") %>%
  filter(permissible_gap == 30) %>%
  filter(!(drug == "Fluoroquinolones")) %>%
  mutate(rx_type = factor(rx_type, 
                          levels = c("incident", "add-on", "continued"))) %>%
  arrange(database, drug, rx_type) %>% 
  select( permissible_gap,
          database, 
          drug,
          rx_type,
         "Database" = "database",
         "Drug class" = "drug",
         "(Intercept)[95% CI]" = "(Intercept)",
         "Slope before RMMs[95% CI]" = "time",
         "Step change after 2018/19 RMMs [95% CI]" = "rmm1",
         "Slope change after 2018/19 RMMs[95% CI]" = "time_after_rmm1",
         "Step change after 2020 RMMs [95% CI]" = "rmm2",
         "Slope change after 2020 RMMs[95% CI]" = "time_after_rmm2"
  )



# save models in an excel file

models <- list(
  "Fluoroquinolones" = models_fq,
  "Groups" = models_groups
)

writexl::write_xlsx(models, "./output/xlsx/s_main.xlsx")
