

source("./functions/400_constants.R")

################################################################################

pharmo1 <- readRDS("./1-pharmo/7_output/groups_main.rds")

cprd1 <- readRDS("./2-cprd/7_output/groups_main.rds") 

fq <- pharmo1[1] %>%
  bind_rows(cprd1[1]) %>% 
  filter(atc_name == "Fluoroquinolones") %>% 
  filter(rx_type == "incident") 

all <- pharmo1[1] %>%
  bind_rows(cprd1[1]) %>% 
  filter(rx_type == "incident") %>%
  group_by(eventdate, database, rx_type, permissible_gap) %>% 
  summarise(n_adj = sum(n_adj)) %>% 
  mutate(atc_name = "All antibiotics")


ts_merged <- fq %>% 
  bind_rows(all) %>% 
  mutate(permissible_gap = as.factor(permissible_gap))


check <- ts_merged %>% 
  group_by(database, permissible_gap, atc_name) %>% 
  summarise(n = sum(n_adj))


################################################################################

library(ggh4x)

its_plot <- function(ts_data1, rmms){
  
  offset <- 28
  intensity <- 0.1
  text_size <- 2.5
  
  database <- ts_data1$database[1]
  
  plot1 <- ts_data1 %>%
    ggplot(aes(x = eventdate, y = n_adj, color = permissible_gap)) +
    
    geom_blank(aes(y = max_y)) +

    geom_line(size = 0.4) +

    geom_line(size = 0.5) +

    
    annotate(geom = "rect",
             fill = "gray",
             xmin =  rmms$start1 - offset,
             xmax = rmms$end1 %m+% months (6),
             ymin = -Inf,
             ymax = Inf,
             alpha = intensity) +
    
    geom_vline(xintercept = c(rmms$start1 - offset, 
                              rmms$end1 %m+% months (6)), 
               linetype = "dotted", 
               color = "red", 
               linewidth = 0.2) +
    
    annotate(geom = "text",
             x = rmms$start1 - offset, 
             y = 0, 
              label = "2018/19\nRMMs", 
              size = text_size, 
              hjust = -0.1, 
              vjust = -0.1) +
    
    annotate(geom = "text",
             x = rmms$start2 - offset, 
             y = 0, 
             label = "2020\nRMMs", 
             size = text_size, 
             hjust = -0.1, 
             vjust = -0.1) +
    
    annotate(geom = "rect",
             fill = "gray",
             xmin =  rmms$start2 - offset,
             xmax = rmms$end2 %m+% months (6),
             ymin = -Inf,
             ymax = Inf,
             alpha = intensity) +
    
    geom_vline(xintercept = c(rmms$start2 - offset, 
                              rmms$end2 %m+% months (6)), 
               linetype = "dotted", 
               color = "red", 
               linewidth = 0.2) +
    
    ylim(0, NA) + 
    
    theme_minimal() +
    
    labs(title = database,
         y = "monthly prescriptions per 10,000 person-years",
         x = "date") + 
    facet_wrap(facet_var ~ ., 
               ncol = 1, 
               scales = "free") +
    
    guides(x = "axis_truncated", y = "axis_truncated") +
    theme(legend.position = "bottom",
          panel.grid.major.x = element_blank(), 
          panel.grid.minor.x = element_blank(),
          panel.grid.minor.y = element_blank(),
          panel.grid.major.y = element_blank(),
          text = element_text(size = 10),
          plot.title = element_text(hjust = 0.5), 
          axis.line = element_line(color = "black", size = 0.05), 
          axis.ticks = element_line(color = "black", size = 0.05),
          axis.ticks.length = unit(0.1, "cm"))
  
  return(plot1)
  
}

plot_both <- function(ts_data){
  
  rmmsNL <- list()
  rmmsNL$start1 <- as.Date("2018-10-04") %>% 
    floor_date("month")
  rmmsNL$end1 <- as.Date("2019-03-29") %>% 
    ceiling_date("month")
  rmmsNL$start2 <- as.Date("2020-09-28") %>% 
    floor_date("month")
  rmmsNL$end2 <- as.Date("2020-10-29") %>% 
    ceiling_date("month")
  
  rmmsUK <- list()
  rmmsUK$start1 <- as.Date("2018-10-04")%>% 
    floor_date("month")
  rmmsUK$end1 <- as.Date("2019-03-29")%>% 
    ceiling_date("month")
  rmmsUK$start2 <- as.Date("2020-12-02") %>% 
    floor_date("month")
  rmmsUK$end2 <- as.Date("2020-12-02")%>% 
    ceiling_date("month")
  
  
  counts <- ts_data %>%
    ungroup() %>% 
    group_by(database) %>% 
    summarise(n = n_distinct(eventdate))
  
  p2width <- counts %>% 
    filter(database == "CPRD-UK") %>% 
    pull(n)
  
  p1width <- counts %>% 
    filter(database == "PHARMO-NL") %>% 
    pull(n)
  
  p <- p2width + p1width
  
  plot2 <- ts_data %>%
    filter(database == "CPRD-UK") %>%
    its_plot(rmmsUK) +
    theme(plot.margin = margin(5,
                               10,
                               5,
                               5, "points"))
  
  
  plot1 <- ts_data %>%
    filter(database == "PHARMO-NL") %>%
    its_plot(rmmsNL) +
    theme(plot.margin = margin(5,
                               5,
                               5,
                               5, "points"))
  
  joined_plots <- grid.arrange(plot2, 
                               plot1, 
                               ncol = 2, 
                               widths = c(p+p2width, p+p1width))
  
  return(joined_plots)
}

################################################################################
################################################################################

joined <- ts_merged %>% 
  mutate(facet_var = atc_name) %>% 
  group_by(facet_var) %>%
  mutate(max_y = max(n_adj)) %>% 
  plot_both()


################################################################################
################################################################################

ggsave("./output/svg/sfig_diff_gaps.svg",
       joined,
       device = "svg",
       width = 7.2,
       height = 7)


################################################################################

source("./functions/svg_to_png.R")
