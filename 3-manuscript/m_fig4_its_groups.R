
source("./functions/400_constants.R")
source("./functions/its_plot_functions.R")

################################################################################

pharmo <- readRDS("./1-pharmo/7_output/groups_main.rds")
cprd <- readRDS("./2-cprd/7_output/groups_main.rds")   

################################################################################

ts_merged <- pharmo[1] %>% 
  bind_rows(cprd[1]) %>% 
  filter(permissible_gap == 30)

ts_merged %>% 
  ungroup() %>% 
  group_by(rx_type) %>%
  summarise(n = sum(n_adj))

################################################################################

ranks_pharmo <- ts_merged %>% 
  filter(database == "PHARMO-NL") %>% 
  group_by(atc_name) %>% 
  summarise(n = mean(n_adj)) %>%
  arrange(desc(n)) %>% 
  mutate(rank = row_number())

ranks_cprd <- ts_merged %>% 
  filter(database == "CPRD-UK") %>% 
  group_by(atc_name) %>% 
  summarise(n = mean(n_adj)) %>%
  arrange(desc(n))  %>% 
  mutate(rank = row_number())

ranks <- ranks_pharmo %>% 
  full_join(ranks_cprd, by = "atc_name", suffix = c("_pharmo", "_cprd")) %>% 
  arrange(desc(n_pharmo), desc(n_cprd)) 

top5 <- ranks %>% 
  mutate(rank = (rank_pharmo + rank_cprd)/2) %>% 
  filter(rank <= 5) %>%
  mutate(n = n_pharmo + n_cprd) %>%
  arrange(desc(n)) %>%
  pull(atc_name)

################################################################################  

plot_top5 <- ts_merged %>%
  filter(rx_type == "incident") %>%
  filter(atc_name %in% top5) %>%
  mutate(facet_var = factor(atc_name, levels = top5)) %>%
  group_by(facet_var) %>% 
  mutate(max_y = max(n_adj)) %>% 
  arrange(facet_var) %>% 
  plot_both()

plot_top5

################################################################################

ggsave("./output/svg/m_fig4_plot.svg",
       plot_top5,
       device = "svg",
       width = 7.2,
       height = 9)

source("./functions/svg_to_png.R")

