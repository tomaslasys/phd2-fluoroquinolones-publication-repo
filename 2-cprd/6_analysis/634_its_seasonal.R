
source("4_functions/run_my_functions.R")
source("4_functions/its_functions_seasonal.R")

################################################################################

excluded = c("intervention")

selected_pgap = 30

################################################################################

ts_all <- readRDS("./3_clean_data/ts_groups.rds") %>% 
  left_join(const$rmms, by = "eventdate") %>% 
  filter(permissible_gap == selected_pgap) %>% 
  rename(atc_name = drug_class_name) %>% 
  mutate(month = as.factor(month(eventdate))) %>% 
  filter(rx_type == "incident")

rm(selected_pgap)

################################################################################

all_tables <- tibble()
all_its_tables <- tibble()

################################################################################

low_counts <- ts_all %>% 
  group_by(atc_name, rx_type) %>%
  mutate(pass = n <= const$min_num_required) %>% 
  summarize(low_counts_perc = 100*sum(pass)/n(), 
            n = sum(n)) %>% 
  ungroup() %>% 
  arrange(atc_name)

products <- low_counts %>% 
  filter(low_counts_perc < 10) %>% 
  distinct(atc_name) %>% 
  pull()

excluded_products <- ts_all %>% 
  distinct(atc_name) %>% 
  filter(!(atc_name %in% products)) %>% 
  pull(atc_name)

rx_types <- ts_all %>% 
  distinct(rx_type) %>% 
  pull()

################################################################################
temp_data <- its_loop(const$permissible_gaps, products, rx_types, ts_all)

all_its_tables <- temp_data$all_its_tables

all_tables <- temp_data$all_tables

################################################################################

all_its_tables <- all_its_tables %>% 
  arrange(rx_type, atc_name) %>% 
  select(eventdate, atc_name, rx_type, permissible_gap, n_adj, fit, lwr, upr) %>% 
  mutate(database = const$database)

all_tables <- all_tables %>% 
  mutate(database = const$database)

################################################################################

analysis = "groups_seasonal"

directory2 <- paste0("./7_output/", 
                     analysis, 
                     ".RDS")

list(all_its_tables, 
     all_tables,
     low_counts) %>% 
  saveRDS(directory2)

