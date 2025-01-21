
const$rmms <- seq(const$study_start, const$study_end, "month") %>% 
  as_tibble() %>% 
  rename(eventdate = value) %>% 
  mutate(rmm_period = case_when(
    eventdate < floor_date(const$rmm1_start, "month") ~ 1,
    eventdate >= floor_date(const$rmm1_start, "month") & 
      eventdate <= floor_date(const$rmm1_end, "month") ~ 2,
    eventdate < floor_date(const$rmm2_start, "month") & 
      eventdate > floor_date(const$rmm1_end, "month") ~ 3,
    eventdate >= floor_date(const$rmm2_start, "month") & 
      eventdate <= floor_date(const$rmm2_end, "month") ~ 4,
    eventdate > floor_date(const$rmm2_end, "month") ~ 5))

const$rmms <- const$rmms %>% 
  mutate(time_after_rmm1 = if_else(
    eventdate > floor_date(const$rmm1_end, "months"), 
    round(time_length(
      difftime(eventdate,
               floor_date(const$rmm1_end, "months")), 
      "months")), 
    0))

const$rmms <- const$rmms %>% 
  mutate(time_after_rmm2 = if_else(
    eventdate > floor_date(const$rmm2_end, "month"), 
    round(time_length(
      difftime(eventdate,
               floor_date(const$rmm2_end, "months")), 
      "months")), 
    0)) 

const$rmms <- const$rmms %>% 
  mutate(time = row_number()) %>% 
  mutate(rmm1 = if_else(time_after_rmm1 > 0, 1, 0), 
         rmm2 = if_else(time_after_rmm2 > 0, 1, 0)) %>% 
  mutate(exclude = case_when(
    rmm_period %in% c(2, 4) ~ "intervention",
    time_after_rmm1 > 0 & time_after_rmm1 <= 6 ~ "lag",
    time_after_rmm2 > 0 & time_after_rmm2 <= 6 ~ "lag",
    TRUE ~ "no" )) 
