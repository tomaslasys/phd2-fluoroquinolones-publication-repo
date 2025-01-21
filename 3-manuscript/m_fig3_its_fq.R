
source("./functions/400_constants.R")
source("./functions/its_plot_functions.R")

################################################################################

pharmo <- readRDS("./1-pharmo/7_output/fq_main.rds")
cprd <- readRDS("./2-cprd/7_output/fq_main.rds") 

################################################################################

pharmo %>%
  ungroup() %>%
  group_by(rx_type) %>%
  summarise(n = sum(n_adj))


ts_merged <- pharmo[1] %>% 
  bind_rows(cprd[1]) %>% 
  mutate(rx_type = factor(rx_type, 
                          levels = c("incident", "add-on", "continued"),
                          labels = c("incident use", "add-on use","continued use")))

ts_merged %>% 
  ungroup() %>% 
  group_by(rx_type) %>%
  summarise(n = sum(n_adj))


ts_merged <- ts_merged %>% 
  filter(permissible_gap == 30) %>% 
  filter(atc_name == "any fluoroquinolone") %>% 
  ungroup() %>% 
  mutate(facet_var = rx_type) %>%
  group_by(facet_var) %>%
  mutate(max_y = max(n_adj))

################################################################################

ts_data <- ts_merged %>% 
  ungroup() %>% 
  mutate(facet_var = rx_type) %>%
  group_by(facet_var) %>%
  mutate(max_y = max(n_adj)) 

fig3 <- ts_data %>% 
  plot_both()

###############################################################################

ggsave("./output/svg/m_fig3_plot.svg",
       fig3,
       device = "svg",
       width = 7.2,
       height = 6.5, 
       units = "in")

source("./functions/svg_to_png.R")
