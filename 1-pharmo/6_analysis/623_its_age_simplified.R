
source("4_functions/run_my_functions.R")
source("4_functions/its_functions.R")

################################################################################

excluded = c("intervention", "lag")
selected_pgap = 30

################################################################################

ts_all <- readRDS("./3_clean_data/ts_age_simplified.rds") %>% 
  left_join(const$rmms, by = "eventdate") %>% 
  filter(permissible_gap == selected_pgap) %>% 
  rename(atc_name = drug_class_name) %>% 
  filter(atc_name == "Fluoroquinolones")

rm(selected_pgap)

################################################################################

low_counts <- ts_all %>%
  group_by(atc_name, rx_type, age_group_simplified) %>%
  mutate(pass = n <= const$min_num_required) %>%
  summarize(low_counts_perc = 100*sum(pass)/n(),
            n = sum(n)) %>%
  arrange(atc_name) %>% 
  ungroup()

products <- low_counts %>%
  filter(low_counts_perc < 10) %>%
  distinct(atc_name) %>%
  pull()

excluded_products <- ts_all %>%
  distinct(atc_name) %>%
  filter(!(atc_name %in% products)) %>%
  pull(atc_name)

################################################################################

rx_types <- ts_all %>% 
  distinct(rx_type) %>% 
  pull()

################################################################################

ts_all1 <- ts_all %>% 
  split(.$age_group_simplified)

temp_data <- lapply(ts_all1, function(x)its_loop(const$permissible_gaps, 
                                                 products, 
                                                 rx_types, 
                                                 x))

all_its_tables <- sapply(temp_data, function(x)x[1]) 
all_its_tables <- do.call(rbind, c(all_its_tables, make.row.names = FALSE))

all_tables <- sapply(temp_data, function(x)x[2]) 

names(all_tables) <- names(ts_all1)

all_tables <- lapply(names(all_tables), function(tbl_name) {
  tbl <- all_tables[[tbl_name]]
  tbl$age_group_simplified <- tbl_name  # Assign the parent table name
  return(tbl)
})

all_tables <- do.call(rbind, c(all_tables, make.row.names = FALSE))

################################################################################

all_its_tables <- all_its_tables %>% 
  arrange(rx_type, atc_name) %>% 
  select(eventdate, atc_name, rx_type, permissible_gap, n_adj, fit, lwr, upr,
         age_group_simplified) %>% 
  mutate(database = const$database)

all_tables <- all_tables %>% 
  arrange(rx_type, drug, 
          age_group_simplified) %>% 
  mutate(database = const$database)

################################################################################

analysis = "fq_age_simplified"

directory2 <- paste0("./7_output/", 
                     analysis, 
                     ".RDS")

list(all_its_tables, 
     all_tables,
     low_counts) %>% 
  saveRDS(directory2)




