
source("4_functions/run_my_functions.R")

# uploading data ###############################################################
  
indexed_files_list <- list.files("./2_interim_data/", 
                                pattern = "rx_indexed",
                                full.names = TRUE)[3:4]

# custom function ##############################################################

# Define the tx_information function
tx_information <- function(rx_indexed) {
  rx_indexed %>%
    group_by(tx_episode) %>%
    summarise(
      start = min(eventdate), 
      end = max(rx_end_date), 
      n_rx = n(),
      n_atc = n_distinct(atc_code),  # More efficient than length(unique())
      duration = as.numeric(max(rx_end_date) - min(eventdate))
    )
}

################################################################################

# Process each file
for (file in indexed_files_list) {
  
  # Read and process the indexed file
  rx_indexed <- readRDS(file) %>%
    ungroup() %>% 
    select(tx_episode, eventdate, rx_end_date, atc_code)
  
  # Generate the new directory name
  directory <- gsub("rx_indexed_pg", "tx_info_pg", file)
  
  tx_info <- tx_information(rx_indexed) 
  
  saveRDS(tx_info, directory)
  
  # Explicitly remove large objects to free memory
  rm(rx_indexed)
  rm(tx_info)
  gc()
  
  print(paste0(file, " - processed"))
}

################################################################################

rm(indexed_files_list)

