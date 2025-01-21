
source("./functions/400_constants.R")
source("./functions/its_plot_functions.R")

################################################################################

pharmo <- readRDS("./1-pharmo/7_output/fq_main.rds")
cprd <- readRDS("./2-cprd/7_output/fq_main.rds")

################################################################################

models <- pharmo[2] %>% 
  bind_rows(cprd[2]) %>% 
  filter(permissible_gap == 30) %>% 
  filter(drug == "any fluoroquinolone") %>% 
  ungroup() %>% 
  mutate(rx_type = factor(rx_type, 
                          levels = c("incident", "add-on", "continued"),
                          labels = c("incident use", "add-on use","continued use"))) %>% 
  mutate(database = factor(database, 
                           levels = c("CPRD-UK", "PHARMO-NL"),
                           labels = c("CPRD-UK", "PHARMO NL"))) %>% 
  arrange(database, rx_type)

colnames(models)

tab_order <- c("drug",
               "database", 
               "rx_type",
               "(Intercept)", 
               "time", 
               "rmm1",
               "time_after_rmm1", 
               "rmm2", 
               "time_after_rmm2")

models <- models[tab_order]

tab_names <- c("Medicinal product",
               "Database", 
               "Type of use",
               "(Intercept)[95% CI]", 
               "Slope before RMMs[95% CI]", 
               "Step after 2018/19 RMMs [95% CI]",
               "Slope change after 2018/19 RMMs[95% CI]", 
               "Step change after 2020[95% CI]", 
               "Slope change after 2020[95% CI]")

names(models) <- tab_names

################################################################################

writexl::write_xlsx(models, "./output/xlsx/m_tab3.xlsx")
