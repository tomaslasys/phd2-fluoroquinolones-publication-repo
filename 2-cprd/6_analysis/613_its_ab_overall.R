
source("4_functions/run_my_functions.R")
source("4_functions/its_functions.R")

################################################################################

excluded = c("intervention", "lag")

################################################################################

ts_all <- readRDS("./3_clean_data/ts_groups.rds") %>% 
  mutate(atc_name = "All antibiotics") %>% 
  group_by(eventdate, atc_name, rx_type, permissible_gap) %>% 
  summarise(n = sum(n), 
            n_adj = sum(n_adj)) %>% 
  left_join(const$rmms, by = "eventdate") %>% 
  ungroup()


################################################################################

all_tables <- tibble()
all_its_tables <- tibble()

################################################################################

products <- ts_all %>%  
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
  arrange(rx_type, drug) %>% 
  mutate(database = const$database)

################################################################################

analysis = "all"

directory2 <- paste0("./7_output/", 
                     analysis, 
                     ".RDS")

list(all_its_tables, 
     all_tables) %>% 
  saveRDS(directory2)


