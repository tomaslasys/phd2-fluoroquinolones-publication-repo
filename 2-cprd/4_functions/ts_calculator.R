

ts_calculator <- function(rx_data){
  
  var_names <- colnames(select(rx_data, -tx_episode)) 
  
  ts_vars <- colnames(select(rx_data, 
                             -c(tx_episode, eventdate))) 
  
  shell_tab <- data.frame(
    eventdate = seq(const$study_start, 
                    const$study_end,
                    by ="months")) %>% 
    tibble()
  
  for(var in ts_vars){
    shell_tab <- shell_tab %>% 
      cross_join(select(rx_data, var) %>% 
                   distinct()) %>% 
      droplevels()
  }
  
  ts_tab <- rx_data %>%
    ungroup() %>% 
    select(-tx_episode) %>% 
    mutate(eventdate = floor_date(eventdate, unit = "month")) %>%
    group_by(across(var_names)) %>% 
    summarise(n = n()) %>% 
    right_join(shell_tab, by = var_names) %>% 
    mutate(n = replace_na(n, 0))
  
  return(ts_tab)
}




