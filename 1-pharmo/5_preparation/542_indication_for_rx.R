
source("4_functions/run_my_functions.R")

# uploading data ###############################################################

indications <- 
  readRDS("./2_interim_data/indications.rds")

tx_info_files_list <- list.files("./2_interim_data/", 
                                 pattern = "tx_info_pg",
                                 full.names = TRUE)

################################################################################

for(file_dir in tx_info_files_list){

  tx_start <- readRDS(file_dir) %>%
    ungroup() %>% 
    select(tx_episode,
           start) %>% 
    mutate(patid = gsub(pattern = "-.*", 
                        replacement = "", 
                        tx_episode))
  
  tx_all_dx <- tx_start %>% 
    semi_join(indications, by = "patid") %>% 
    left_join(indications, by = "patid", relationship = "many-to-many") %>% 
    mutate(dx_rx_diff = as.numeric(dx_date - start)) %>% 
    filter(abs(dx_rx_diff) <= const$gap_between_Rx_and_Dx) %>% 
    ungroup() %>% 
    group_by(tx_episode) %>% 
    arrange(tx_episode, dx_rx_diff) %>% 
    mutate(dx_rank = rleid(dx_rx_diff)) %>% 
    select(-patid)
  
  ##############################################################################
  
  temp_txdx <- tx_all_dx %>% 
    select(tx_episode, dx_rx_diff) %>% 
    distinct()
  
  step1 <- tibble(dx_rx_diff = 0)
  tx_dx1 <- temp_txdx %>% 
    semi_join(step1, by = "dx_rx_diff")
  
  
  step2 <- tibble(dx_rx_diff = 
                    seq(-const$gap_between_Rx_and_Dx, 
                        -1, 
                        1))
  tx_dx2 <- temp_txdx %>%
    anti_join(tx_dx1, by = "tx_episode") %>% 
    semi_join(step2, by = "dx_rx_diff") %>% 
    group_by(tx_episode) %>% 
    filter(dx_rx_diff == max(dx_rx_diff)) %>% 
    ungroup()
  
  tx_dx3 <- temp_txdx %>%
    anti_join(tx_dx1, by = "tx_episode") %>%
    anti_join(tx_dx2, by = "tx_episode") %>%
    group_by(tx_episode) %>% 
    filter(dx_rx_diff == min(dx_rx_diff)) %>% 
    ungroup()
  
  tx_dx <- tx_dx1 %>% 
    bind_rows(tx_dx2) %>% 
    bind_rows(tx_dx3) %>% 
    mutate(selected = TRUE)
  
  ################################################################################
  
  tx_all_dx1 <- tx_all_dx %>% 
    left_join(tx_dx, 
              by = c("tx_episode", "dx_rx_diff")) %>% 
    mutate(selected = replace_na(selected, FALSE))
  
  
  directory <- gsub("tx_info_pg", "tx_all_dx_pg", file_dir)
  
  saveRDS(tx_all_dx1,
          directory)
  
  ################################################################################
  
  tx_all_dx2 <- tx_all_dx1 %>% 
    filter(selected == TRUE) %>% 
    select(tx_episode, start, dx_group)
  
  tx_indications <- tx_start %>%
    ungroup() %>% 
    select(tx_episode, start) %>% 
    anti_join(tx_all_dx2, by = "tx_episode") %>%
    bind_rows(tx_all_dx2) %>% 
    mutate(dx_group = if_else(is.na(dx_group), "Unknown", dx_group))
  
  tx_indications %>% 
    filter(is.na(dx_group))
  
  directory <- gsub("tx_info_pg", "tx_indications_pg", file_dir)
  
  saveRDS(tx_indications, 
          directory)
}
