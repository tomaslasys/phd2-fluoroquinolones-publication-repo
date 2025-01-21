
rm(list = ls())
gc()

################################################################################

library(stringr)
library(tidyverse)
library(data.table)

options(scipen = 999)
graphics.off()

################################################################################

const <- list()

my_functions <- list.files(pattern = "^[0-9].*\\.R$",
                           path = "./4_functions/", 
                           full.names = TRUE)

invisible(
  lapply(my_functions, function(x) source(x)))

rm(my_functions)
