
# Load necessary libraries
library(ggplot2)
library(dplyr)
library(stringr)
library(ggrepel)
library(lubridate)
library(grid)

################################################################################

text_size <- 2.6
col_intensity <- 0.25
offset <- 0

################################################################################

# Define the data
data <- data.frame(
  time = as.Date(c('2018-10-04', '2018-11-15', '2019-02-14', '2019-03-11', '2019-03-21', 
                   '2019-03-29', '2020-09-28', '2020-10-29', '2020-10-29', '2020-12-02')),
  event = c("EMA's PRAC recommends restrictions on use of fluoroquinolone and quinolone antibiotics",
            "EMA's CHMP accepts PRAC's recommendations and forwards to EC",
            "EC issues a binding decision for RMMs targeting Quinsar",
            "EC issues a binding decision for RMMs targeting other quinolone and fluoroquinolone antibiotics",
            "DHPC issued in the UK",
            "DHPC issued in the Netherlands",
            "PRAC recommends to amend product information for fluoroquinolones",
            "DHPC issued by EMA", 
            "DHPC issued in the Netherlands",
            "DHPC issued in the UK")
)

################################################################################

add_date_to_event <- function(event, date) {
  formatted_date <- format(date, "%d %B %Y")
  formatted_date <- gsub("^0", "", formatted_date)  # Remove leading zero
  event_wrapped <- str_wrap(event, width = 60)
  formatted_date <- paste0("(", formatted_date, ")")
  paste(event_wrapped, formatted_date, sep = "\n")
}
  
################################################################################

data <- data %>%
    mutate(event_wrapped = mapply(add_date_to_event, event, time))

new_first_date <- floor_date(min(data$time) - 60, "month")
new_last_date <- floor_date(max(data$time) + 360, "month")

mid_dates <- seq(new_first_date + month(2), new_last_date, by = "2 months") %>% 
  ymd() %>% 
  as.Date() + days(14)

# Sort data by time
data <- data %>%
  arrange(time)

# Create a sequence of dummy y-values for labeling
data$y_pos <- c(18, 15, 12, 8, 5, 2,  
                14, 11, 8, 5)

# Define the start and end dates for the rectangles
rmm1start <- as.Date("2018-10-04")
rmm1end <- as.Date("2019-03-29")
rmm2start <- as.Date("2020-09-28")
rmm2end <- as.Date("2020-10-29")
rmm3start <- as.Date("2020-12-02")
rmm3end <- as.Date("2020-12-02")

# each start has to be floored and each end has to be ceiled
rmm1start <- floor_date(rmm1start, "month")
rmm1end <- ceiling_date(rmm1end, "month")
rmm2start <- floor_date(rmm2start, "month")
rmm2end <- ceiling_date(rmm2end, "month")
rmm3start <- floor_date(rmm3start, "month")
rmm3end <- ceiling_date(rmm3end, "month")

# Plot the data ################################################################

pl <- ggplot(data, aes(x = time, y = y_pos)) +
  
  geom_segment(aes(x = time, 
                   xend = time, 
                   y = 0.1, 
                   yend = y_pos),
               linetype = "dotted", 
               color = "red", 
               linewidth = 0.4) +
  annotate("rect", 
           xmin = rmm1start, 
           xmax = rmm1end, 
           ymin = -8, 
           ymax = 0, 
           fill = "red", 
           alpha = col_intensity) +
  
  #annotation in the middle of the rectangle rmm1
  annotate("text",
           x = rmm1start + (rmm1end - rmm1start) / 2,
           y = -4,
           label = "2018/19\nRMMs\n (UK and NL)",
           color = "black",
           size = text_size,
           hjust = 0.5,
           vjust = 0.5) +
  # add the same annotations with 6 months offset
  annotate("rect", 
           xmin = rmm1end, 
           xmax = rmm1end + months(6), 
           ymin = -8, 
           ymax = 0, 
           fill = "grey", 
           alpha = col_intensity) +
  #annotation in the middle of the rectangle rmm1
  annotate("text",
           x = rmm1end + months(3),
           y = -4,
           label = "lag period",
           color = "black",
           size = text_size,
           hjust = 0.5,
           vjust = 0.5) +
  # add the same annotations with 6 months offset
  annotate("rect", 
           xmin = rmm2start, 
           xmax = rmm2end, 
           ymin = -4, 
           ymax = 0, 
           fill = "red", 
           alpha = col_intensity) +
  #annotation in the middle of the rectangle rmm2
  annotate("text",
           x = rmm2start + (rmm2end - rmm2start) / 2,
           y = -2,
           label = "2020\nRMMs \n(NL)",
           color = "black",
           size = text_size,
           hjust = 0.5,
           vjust = 0.5) +
  # add the same annotations with 6 months offset
  annotate("rect", 
           xmin = rmm2end, 
           xmax = rmm2end + months(6), 
           ymin = -4, 
           ymax = 0, 
           fill = "grey", 
           alpha = col_intensity) +
  #annotation in the middle of the rectangle rmm2
  annotate("text",
           x = rmm2end + months(3),
           y = -2,
           label = "lag period",
           color = "black",
           size = text_size,
           hjust = 0.5,
           vjust = 0.5) +
  # add the same annotations with 6 months offset
  annotate("rect", 
           xmin = rmm3start - offset, 
           xmax = rmm3end + offset, 
           ymin = -8, 
           ymax = -4, 
           fill = "red", 
           alpha = col_intensity) +
  annotate("text",
           x = rmm3start + (rmm3end - rmm3start) / 2,
           y = -6,
           label = "2020\nRMMs\n(UK)",
           color = "black",
           size = text_size,
           hjust = 0.5,
           vjust = 0.5) +
  # add the same annotations with 6 months offset
  annotate("rect", 
           xmin = rmm3end + offset, 
           xmax = rmm3end + months(6), 
           ymin = -8, 
           ymax = -4, 
           fill = "grey", 
           alpha = col_intensity) +
  annotate("text",
           x = rmm3end + months(3),
           y = -6,
           label = "lag period",
           color = "black",
           size = text_size,
           hjust = 0.5,
           vjust = 0.5) +
  geom_segment(aes(x = new_first_date, y = 0, xend = new_last_date , yend = 0),
               arrow = arrow(length = unit(0.3, "cm")),
               color = "black",
               linewidth = 1) +

    geom_label(
    aes(x = time,
        y = y_pos, 
        label = event_wrapped),
    fill = "red",
    color = "black", 
    size = text_size, 
    label.size = 0.01,
    hjust = 0,
    vjust = 0,
    nudge_x = 0, 
    nudge_y = 0, 
    alpha = col_intensity) +
    # geom_point(
    #          size = 2, 
    #          color = "red") +
  # coord_cartesian(ylim=c(0, -1)) +
  
  theme_minimal() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        # panel.grid.major.x = element_line(color = "grey80", linetype = "dotted"),
        axis.line.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.title.y = element_blank(),
        text = element_text(size = 8)) +
  labs(title = element_blank(),
       x = "Time", 
       y = element_blank()) +
  ylim(-8, 21) +
  scale_x_date(date_labels = "%b\n %Y", 
               breaks = mid_dates,
               limits = c(new_first_date, new_last_date)) +
  # guides(x = "axis_truncated") +
  theme(axis.line = element_line(color = "black", size = 0.05), 
        axis.ticks = element_line(color = "black", size = 0.05), 
        plot.background = element_rect(fill = "white", color = NA))

pl

################################################################################

# save svg file
ggsave("./output/svg/m_fig1_rmm_timeline.svg",
       pl,
       device = "svg",
       width = 7.4,
       height = 5)

source("./functions/svg_to_png.R")
