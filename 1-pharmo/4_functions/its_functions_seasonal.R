
################################################################################
################################################################################

its_model_estimation <- function(temp_all){
  
  temp_subset <- temp_all %>%
    filter(!(exclude == excluded))
  
  its1 <- glm(n_adj ~
                time +
                rmm1 +
                time_after_rmm1 +
                rmm2 +
                time_after_rmm2 +
                month,
              data = temp_subset )
  
  return(its1)
}


################################################################################
################################################################################

its_table_creation <- function(temp_all, its1){
  
  predicted1 <- predict(its1,
                        newdata = temp_all,
                        type = "response",
                        se.fit = TRUE,
                        interval = "confidence",
                        level = 0.95) %>% data.frame() %>% 
    select(fit, 
           se = se.fit)
  
  temp_all <- temp_all %>%
    bind_cols(predicted1) 
  
  temp_all <- temp_all %>%
    mutate(fit = if_else(exclude %in% excluded, NA, fit),
           se = if_else(exclude %in% excluded, NA, se)) %>% 
    mutate(lwr = fit - const$z*se,
           upr = fit + const$z*se) %>% 
    select(-se)
  
  return(temp_all)
  
}

################################################################################
################################################################################

coefficients_table <- function(its_rx1, product){
  
  coefficients_table <- as.data.frame(
    cbind(coef(its_rx1), confint(its_rx1),summary(its_rx1)$coefficients[, 4])) %>% 
    mutate_all(function(x)format(round(x, 3), nsmall = 3)) %>% 
    rename(V1 = 1, V2 = 2, V3 = 3, V4 = 4) %>% 
    mutate(value = paste0(V1, "[", V2, " to ", V3, "] p = ", V4)) %>% 
    select(value) %>% 
    t() %>% 
    as_tibble() %>% 
    mutate(drug = product)
  
  return(coefficients_table)
}



################################################################################
################################################################################

its_plot <- function(temp_ts, title){
  
  rmms <- list(start1 = const$rmm1_start, 
               end1 = const$rmm1_end, 
               start2 = const$rmm2_start, 
               end2 = const$rmm2_end) 
  
  rmms <- lapply(rmms, function(x) floor_date(x, "months"))
  
  colnames(temp_ts) <- c("eventdate", "rx1", "fit1", "lwr", "upr")
  
  plot <- ggplot(temp_ts) +
    
    annotate(geom = "rect", xmin =  rmms$start1 - 20, xmax = rmms$end1 + 20,
             ymin = -Inf, ymax = Inf, alpha = 0.07) +
    geom_text(x = (rmms$start1 + as.numeric(rmms$end1 - rmms$start1)/2), y = max(temp_ts$rx1)*0.1, label = "RMMs 1") +
    
    annotate(geom = "rect", xmin =  rmms$start2 - 20, xmax = rmms$end2 + 20,
             ymin = -Inf, ymax = Inf, alpha = 0.07) +
    geom_text(x = (rmms$start2 + as.numeric(rmms$end2 - rmms$start2)/2), y = max(temp_ts$rx1)*0.1, label = "RMMs 2") +
    
    geom_ribbon(aes(eventdate, 
                    ymin = lwr, ymax = upr),
                fill = "lightblue", alpha = 0.8) +
    
    geom_line(aes(eventdate, fit1), 
              col = "darkblue", linewidth = 1) +
    
    geom_point(aes(eventdate, rx1, color = "incident"),
               col = "red", size = 2, shape = 21) +
    
    ylim(0, NA) + 
    theme_classic() +
    theme(legend.position = "bottom") +
    labs(title = title,
         y = "prescriptions per 10,000\nperson years",
         x = "date")
  
  return(plot)
}



################################################################################
################################################################################

its_loop <- function(const_permissible_gaps1, products1, rx_types1, ts_all1) {
  all_its_tables <- tibble()  # Initialize empty tibble for all_its_tables
  all_tables <- tibble()      # Initialize empty tibble for all_tables
  
  for (gap in const_permissible_gaps1) {
    for (drug in products1) {
      for (type in rx_types1) {
        
        ts_data <- ts_all1 %>% 
          filter(atc_name == drug) %>% 
          filter(rx_type == type) %>% 
          filter(permissible_gap == gap)
        
        if (nrow(ts_data) == 0) {
          next
        }
        
        its_model <- its_model_estimation(ts_data)
        
        its_table <- its_table_creation(ts_data, its_model)
        
        all_its_tables <- all_its_tables %>% 
          bind_rows(its_table)
        
        tab1 <- coefficients_table(its_model, drug) %>% 
          mutate(rx_type = type, 
                 permissible_gap = gap) 
        
        all_tables <- all_tables %>% 
          bind_rows(tab1)
        
        msg1 <- paste0("## ITS for ",
                       drug, " (",
                       type, " use, pg = ",
                       gap, ") was calculated")
        
        cat("\n", msg1, "\n", "\n")
      }
    }
  }
  
  return(list(all_its_tables = all_its_tables, all_tables = all_tables))
}

