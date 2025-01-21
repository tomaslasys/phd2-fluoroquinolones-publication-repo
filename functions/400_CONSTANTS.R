
rm(list = ls())
gc()

library(stringr)
library(tidyverse)
library(data.table)
library(tictoc)
library(gridExtra)

# SETTINGS #####################################################################

options(scipen = 999)

# CONSTANTS ####################################################################

const <- list()

const$rmmsNL <- list()
const$rmmsUK <- list()

const$rmmsNL$start1 <- as.Date("2018-10-04")
const$rmmsNL$end1 <- as.Date("2019-03-29")
const$rmmsUK$start1 <- as.Date("2018-10-04")
const$rmmsUK$end1 <- as.Date("2019-03-29")

# RMM2 - NL
const$rmmsNL$start2 <- as.Date("2020-09-28") 
const$rmmsNL$end2 <- as.Date("2020-10-29")

# RMM2 - UK
const$rmmsUK$start2 <- as.Date("2020-12-02") 
const$rmmsUK$end2 <- as.Date("2020-12-02")

