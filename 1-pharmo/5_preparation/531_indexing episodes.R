
source("4_functions/run_my_functions.R")

# uploading data ###############################################################

rx_selected <- readRDS("./2_interim_data/rx_selected.rds") %>% 
  as_tibble()

################################################################################

tx_indexing <- function(rx_selected, permissible_gap){
  
  #creating episode IDs
  tx_episode_ids <- rx_selected  %>%
    group_by(patid) %>% 
    filter(lag_rx > permissible_gap) %>%
    mutate(tx_episode = rleid(patid, eventdate)) %>%
    select(patid, eventdate, tx_episode) %>%
    mutate(tx_episode = paste0(patid, "-", tx_episode)) %>% 
    
    # adding end dates to the treatment episodes (start of the another tx episode or the end of the study)
    mutate(end = data.table::shift(eventdate, type = "lead")) %>%
    mutate(end = replace_na(end, const$study_end + 1)) %>% 
    rename(start = eventdate) %>% 
    select(patid, tx_episode, start, end) %>% 
    group_by(patid) %>% 
    mutate(index_date = min(start)) %>% 
    ungroup()
  
  
  # creating dummy variable for all possible patid & eventdate combinations
  eventdates <- rx_selected %>% 
    select(patid, eventdate) %>% 
    distinct()
  
  # merging patid & date combinations with corresponding tx_episode IDs
  date_indexes <- eventdates %>% 
    left_join(tx_episode_ids, by = "patid", relationship = "many-to-many") %>% 
    filter(eventdate >= start & eventdate < end) %>% 
    select(-c(start, end)) %>% 
    droplevels()
  
  
  rx_indexed <- date_indexes %>% 
    inner_join(rx_selected, by = c("patid", "eventdate")) %>% ungroup() %>% 
    group_by(patid, tx_episode) %>% 
    mutate(rx_order = rleid(patid, eventdate)) 
  
  prescription_types <- rx_indexed %>% 
    ungroup() %>% 
    distinct(rx_order, lag_atc) %>% 
    mutate(rx_type = case_when(
      rx_order == 1 ~ 
        "incident", 
      lag_atc <= permissible_gap ~ 
        "continued", 
      TRUE ~ 
        "add-on")) %>% 
    mutate(rx_type = factor(rx_type, 
                            levels = c("incident", "continued", "add-on"), 
                            ordered = TRUE))
  
  rx_indexed1 <- rx_indexed %>% 
    left_join(prescription_types, by = c("rx_order", "lag_atc")) 
  
  return(rx_indexed1)
  
}

################################################################################
permissible_gap = 10

for(permissible_gap in const$permissible_gaps){
  
  tic(paste0("indexing with permissible gap ", 
             permissible_gap, 
             " days"))

  rx_indexed <- tx_indexing(rx_selected, 
                             permissible_gap = permissible_gap)
  
  directory <- paste0("./2_interim_data/rx_indexed_pg", 
                      permissible_gap, 
                      ".RDS")
  
  saveRDS(rx_indexed, 
          directory)

  
  rm(rx_indexed,
     directory,
     permissible_gap)
  gc()
  
  toc()
  
}


################################################################################
rm(tx_indexing)
rm(rx_selected)
