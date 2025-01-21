
source("4_functions/run_my_functions.R")

################################################################################

rx_J01_adjusted <- read_rds("./2_interim_data/rx_J01_corrected_overlaps.RDS") 

demographics <- readRDS("./1_raw_data/renamed/demographics.RDS") %>% 
  filter(!(yob == 1900)) # value for invalid yob

################################################################################

rx_J01_adjusted  <- rx_J01_adjusted  %>% 
  mutate(lag_rx = replace_na(lag_rx, 99999), 
         lag_atc = replace_na(lag_atc, 99999))

################################################################################

flowchart0 <- data.frame(
  n_patid = length(unique(rx_J01_adjusted$patid)),
  n_rx    = nrow(rx_J01_adjusted)) %>% 
  mutate(rank = 1, 
         description = "all") %>% 
  select(rank, description, n_patid, n_rx)

################################################################################

rx_selected1 <- data.frame(eventdate = 
                        seq(const$study_start, const$study_end, by ="days")) %>% 
    left_join(rx_J01_adjusted, by = "eventdate")


flowchart1 <- data.frame(
  n_patid = length(unique(
    rx_selected1$patid)),
  n_rx    = nrow(
    rx_selected1)) %>% 
  mutate(rank = 2, 
         description = "in study period") %>% 
  select(rank, description, n_patid, n_rx)

rm(rx_J01_adjusted)

################################################################################

rx_selected2 <- rx_selected1 %>% 
  semi_join(demographics, by = "patid") %>% 
  left_join(demographics, by = "patid") %>% 
  select(-c(hosp_link, cohort1, cohort2)) 

flowchart2 <- data.frame(
  n_patid = length(unique(rx_selected2$patid)),
  n_rx    = nrow(rx_selected2)) %>% 
  mutate(rank = 3, 
         description = "with demographics") %>% 
  select(rank, description, n_patid, n_rx)

################################################################################

rx_selected3  <- rx_selected2  %>% 
  mutate(lookback = as.numeric(eventdate - crd)) %>% 
  filter(lookback > const$lookback_window)


flowchart3 <- data.frame(
  n_patid = length(unique(rx_selected3$patid)),
  n_rx    = nrow(rx_selected3)) %>% 
  mutate(rank = 4, 
         description = "with lookback") %>% 
  select(rank, description, n_patid, n_rx)

################################################################################

index_dates_pg30 <- rx_selected3 %>% 
  group_by(patid) %>% 
  filter(lag_rx > 30) %>% 
  summarise(index_date = min(eventdate)) %>% 
  distinct()

rx_selected4 <- rx_selected3 %>% 
  semi_join(index_dates_pg30, by = "patid") %>%
  left_join(index_dates_pg30, by = "patid") %>% 
  filter(eventdate >= index_date) %>% 
  arrange(patid, eventdate)

flowchart4 <- data.frame(
  n_patid = length(unique(rx_selected4$patid)),
  n_rx    = nrow(rx_selected4)) %>% 
  mutate(rank = 5, 
         description = "with drug free lookback") %>% 
  select(rank, description, n_patid, n_rx)

################################################################################

flowchart <- flowchart0 %>% 
  bind_rows(flowchart1) %>% 
  bind_rows(flowchart2) %>% 
  bind_rows(flowchart3) %>% 
  bind_rows(flowchart4) 

rm(flowchart0,
   flowchart1,
   flowchart2,
   flowchart3,
   flowchart4)

################################################################################

index_dates_pg7 <- rx_selected3 %>% 
  group_by(patid) %>% 
  filter(lag_rx > 7) %>% 
  summarise(index_date = min(eventdate)) %>% 
  distinct()

rx_selected5 <- rx_selected3 %>% 
  semi_join(index_dates_pg7, by = "patid") %>%
  left_join(index_dates_pg7, by = "patid") %>% 
  filter(eventdate >= index_date) %>% 
  arrange(patid, eventdate)

rx_selected <- rx_selected5 %>% 
  select(-c(yob, sex, crd, tod, index_date, lookback, rx_duration))

################################################################################

rm(rx_selected1,
   rx_selected2,
   rx_selected3,
   rx_selected4,
   rx_selected5)

################################################################################

write.table(flowchart, 
            "./7_output/flowchart.csv",
            row.names = FALSE)

saveRDS(index_dates_pg30, 
        "./2_interim_data/index_dates_pg30.rds")

saveRDS(index_dates_pg7, 
        "./2_interim_data/index_dates_pg7.rds")

saveRDS(rx_selected, 
        "./2_interim_data/rx_selected.rds")

rm(flowchart)
rm(index_dates_pg30)
rm(index_dates_pg7)
rm(rx_selected)
rm(demographics)

