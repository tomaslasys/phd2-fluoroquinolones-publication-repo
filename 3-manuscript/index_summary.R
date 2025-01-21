
gc()
rm(list = ls())

library(openxlsx)
library(purrr)
library(tidyverse)

################################################################################

summary_index2 <- readRDS("./2-cprd/7_output/summary_index_pg30.RDS")
summary_index1 <- readRDS("./1-pharmo/7_output/summary_index_pg30.RDS")

################################################################################

index <- map2(summary_index2, summary_index1, bind_rows)

################################################################################

add_combined_column <- function(df) {
  if ("percent" %in% colnames(df)) {
    df <- df %>%
      mutate(percent = format(round(percent, 1), nsmall = 1)) %>% 
      mutate(value = paste0(
          format(n, big.mark = ","),  
          " (", percent, "%)")
        ) %>% 
  select(-n, -percent) %>% 
  mutate(value = gsub("( 0.0%)", "<0.1%", value))
    
  } else {
    df <- df %>%
      mutate(
        n = round(n, 1),
        value = format(n, big.mark = ",")
      ) %>%
      select(-n)
    
  }
  
  if ("description" %in% colnames(df)) {
    df <- df %>% 
      filter(!(description %in% c("Min.", "Max.")))
  }
  
  return(df)
}

################################################################################

summary_index <- lapply(index, add_combined_column)

wider_list <- lapply(summary_index, function(df) {
  df %>%
    pivot_wider(
      names_from = database, 
      values_from = value
    )
})

summary_index <- wider_list

################################################################################

wb <- createWorkbook()

for (i in seq_along(summary_index)) {
  addWorksheet(wb, sheetName = names(summary_index)[i])
  writeData(wb, sheet = names(summary_index)[i], summary_index[[i]]) 
}

saveWorkbook(wb, file = "output/xlsx/index_summary.xlsx", overwrite = TRUE)

