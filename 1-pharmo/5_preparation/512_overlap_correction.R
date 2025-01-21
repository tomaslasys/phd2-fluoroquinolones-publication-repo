
source("4_functions/run_my_functions.R")

# loading data #################################################################

rx_J01 <- 
  read_rds("./2_interim_data/rx_J01_with_duration.RDS")

################################################################################

rx1 <- rx_J01 %>% 
  head(10000) %>%
  arrange(patid, atc_code, eventdate) %>% 
  mutate(eventdate1 = eventdate, 
         rx_end1 = rx_end_date) %>% 
  group_by(patid, atc_code) %>% 
  mutate(lag_atc = 
           as.numeric(eventdate) - 
           as.numeric(data.table::shift(rx_end_date,  
                                        type = "lag"))) %>% 
  ungroup()


ids_with_overlaps <- rx1 %>%
  filter(lag_atc < 0 & !is.na(lag_atc)) %>% 
  distinct(patid)

rx_adjusted <- rx1 %>% 
  anti_join(ids_with_overlaps, by = "patid")

cycle <-0

while(nrow(ids_with_overlaps) > 0){
  
  tic()
  
  rx1 <- rx1 %>% 
    semi_join(ids_with_overlaps, by = "patid") %>% 
    mutate(
      eventdate1 = if_else(
        lag_atc < 0, 
        eventdate1 - lag_atc,
        eventdate), 
      rx_end1 = if_else(
        lag_atc < 0, 
        rx_end1 - lag_atc,
        rx_end1)) %>% 
    mutate(lag_atc = 
             as.numeric(eventdate1) - 
             as.numeric(data.table::shift(rx_end1,  
                                          type = "lag")), 
           lag_atc = if_else(
             eventdate1 > eventdate + 90, 
             0, 
             lag_atc))
  
  ids_with_overlaps <- rx1 %>%
    filter(lag_atc < 0 & !is.na(lag_atc)) %>% 
    distinct(patid)
  
  rx_adjusted1 <- rx1 %>% 
    anti_join(ids_with_overlaps, by = "patid")
  
  rx_adjusted <- rx_adjusted %>% 
    bind_rows(rx_adjusted1)
  
  cycle = cycle + 1
  
  print(paste("              CYCLE =", cycle))
  print(paste("n pts with overlaps =", nrow(ids_with_overlaps)))

  toc()
}


# adding rx lag information
rx_J01_adjusted <- rx_adjusted %>%
  ungroup() %>% 
  arrange(patid, eventdate, atc_code) %>%
  group_by(patid) %>%
  mutate(lag_rx = 
           as.numeric(eventdate) - 
           as.numeric(data.table::shift(rx_end_date,  type = "lag"))) %>% 
  mutate(rx_lag = if_else(lag_atc < lag_rx & !is.na(lag_atc), 
                          lag_atc, 
                          lag_rx))

rx_J01_adjusted <- rx_J01_adjusted %>% 
  select(patid, eventdate, atc_code, rx_duration, rx_end_date = rx_end1, lag_rx = rx_lag)

# saving the updated data ######################################################

write_rds(rx_J01_adjusted,
          "./2_interim_data/rx_J01_corrected_overlaps1.RDS")

