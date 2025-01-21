

source("./functions/400_constants.R")
source("./functions/its_plot_functions.R")

################################################################################


pharmo <- readRDS("./1-pharmo/7_output/groups_lags.rds")
cprd <- readRDS("./2-cprd/7_output/groups_lags.rds")   



ts_merged <- pharmo[1] %>% 
  bind_rows(cprd[1]) %>% 
  filter(permissible_gap == 30) %>% 
  filter(lag != 6) %>% 
  filter(atc_name == "Fluoroquinolones") %>% 
  filter(rx_type == "incident")

ts_merged %>% 
  ungroup() %>% 
  group_by(rx_type) %>%
  summarise(n = sum(n_adj))


################################################################################

plot_top5 <- ts_merged %>%
  filter(rx_type == "incident") %>%
  mutate(facet_var = factor(lag)) %>%
  group_by(facet_var) %>% 
  mutate(max_y = max(n_adj)) %>% 
  arrange(facet_var) %>% 
  plot_both()

plot_top5

ggsave("./output/svg/m_fig4_plot.svg",
       plot_top5,
       device = "svg",
       width = 7.2,
       height = 9)

source("./functions/svg_to_png.R")

