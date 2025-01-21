
source("4_functions/run_my_functions.R")

################################################################################

duration_estimation <- function(rx){
  
  rx <- rx %>%
    mutate(rx_duration = ceiling(amount/daily_units)) %>%
    mutate(rx_duration = case_when(
      (is.na(rx_duration) | rx_duration == 0) & ddd > 0 ~ ceiling(amount/ddd),
      TRUE ~ rx_duration))
  
  return(rx)
}

# Importing data ###############################################################

atc_codes <- fread("./0_lookup/atc_index.csv")

rx_J01 <- 
  read_rds("./1_raw_data/renamed/rx_J01.RDS")

################################################################################

check0 <- rx_J01 %>% distinct(atc_code)
check1 <- rx_J01 %>% filter(atc_code == "J01EA")
check2 <- rx_J01 %>% semi_join(check1, by = "patid")

rx_J01 <- rx_J01 %>% 
  mutate(atc_code = if_else(atc_code == "J01EA",
                            "J01EA01",
                            atc_code)) 


check3 <- rx_J01 %>% distinct(atc_code) 

################################################################################
# removing duplicates (dispensed amount = 0)

temp0 <- tibble(amount = 0) 

check4 <- rx_J01 %>% semi_join(temp0, by = "amount")

check5 <- rx_J01 %>% 
  semi_join(check4, by = "patid") %>% 
  arrange(patid, atc_code, eventdate)


rx_J01 <- rx_J01 %>% 
  anti_join(temp0, by = "amount")

rm(temp0)

################################################################################
# removing products that are not JO1 (topical and other non-systemic products)

# based on labels ##############################################################

products2exclude <- tibble(
  label_descr = c("Tetracycl.3%tca0.1% ungsimp", 
                  "METRONIDAZOLCREME 1%", 
                  "METRONIDAZOL2%VASELINELANET",
                  "TETRAC.1%,ZINKOLIE/VAS AA", 
                  "ERYTROMYCINE 2% IN CUTIVATE", 
                  "METRONIDAZOLVASECREME2%"))

check6 <- rx_J01 %>%
  semi_join(products2exclude, by = "label_descr")


rx_J01 <- rx_J01 %>% 
  anti_join(products2exclude, by = "label_descr") 

rm(products2exclude)

# based on label name and other information ####################################

check7 <- rx_J01 %>% 
  filter(atc_code %in% c("J01AA07",
                         "J01XC01", 
                         "J01FA01", 
                         "J01XD01", 
                         "J01FF01", 
                         "J01BA01",
                         "J01BA01",
                         "J01XB02") & 
           (units == "G" | units == "MG"))

rx_J01a <- rx_J01 %>% 
  filter(!(atc_code %in% c("J01AA07",
                           "J01XC01", 
                           "J01FA01", 
                           "J01XD01", 
                           "J01FF01", 
                           "J01BA01",
                           "J01BA01",
                           "J01XB02") & 
             (units == "G" | units == "MG")))

nrow(rx_J01) - nrow(rx_J01a) - nrow(check7)

rx_J01 <- rx_J01a

check8 <- rx_J01 %>% 
  filter(units == "G" | units == "MG")

rx_J01 <- rx_J01 %>% 
  filter(!(units == "G" | units == "MG"))

################################################################################
# removing duplicates

# Identify duplicate rows
check_dup1 <- rx_J01 %>%
  ungroup() %>%
  group_by(patid, eventdate, atc_code, amount, product_code) %>%
  filter(n() > 1) %>% 
  ungroup()

check_dup2 <- check_dup1 %>% 
  group_by(patid, eventdate, atc_code, amount, product_code) %>%
  filter(n() > 2) %>% 
  ungroup()

# Remove duplicate rows
rx_J01a <- rx_J01 %>%
  ungroup() %>%
  group_by(patid, eventdate, atc_code, amount, product_code) %>%
  distinct(eventdate, patid, atc_code, amount, product_code, .keep_all = TRUE) %>%
  ungroup()

check6 <- rx_J01a %>%
  group_by(patid, eventdate, atc_code, amount, product_code) %>%
  filter(n() > 1)

nrow(rx_J01) - nrow(rx_J01a) - nrow(check_dup1)/2

rx_J01 <- rx_J01a

# Identify duplicate rows (another cycle)
check_dup3 <- rx_J01 %>%
  ungroup() %>%
  group_by(patid, eventdate, atc_code, amount) %>%
  filter(n() > 1) %>% 
  ungroup()

check_dup4 <- check_dup3 %>% 
  group_by(patid, eventdate, atc_code, amount) %>%
  filter(n() > 2) %>% 
  ungroup()

# Remove duplicate rows
rx_J01a <- rx_J01 %>%
  ungroup() %>%
  group_by(patid, eventdate, atc_code, amount) %>%
  distinct(eventdate, patid, atc_code, amount, .keep_all = TRUE) %>%
  ungroup()

check7 <- rx_J01a %>%
  group_by(patid, eventdate, atc_code, amount) %>%
  filter(n() > 1)

nrow(rx_J01) - nrow(rx_J01a) - nrow(check_dup3)/2

rx_J01 <- rx_J01a

################################################################################
## prescription duration 

rx_J01 <- duration_estimation(rx_J01)

check8 <- rx_J01 %>% filter(is.na(rx_duration))

# change dose based on check8
rx_J01 <- rx_J01 %>% 
  mutate(rx_duration = 
           case_when(
             units == "ML" ~ 1,
             label_descr == "VANCOMYCINE 1,5G=500ML ZAK" ~ amount,
             label_descr == "VANCOMYCINE 1,25G=500ML ZAK" ~ amount,
             label_descr == "CEFTRIAXON 2G/100ML CASSETT" ~ amount,
             label_descr == "FLUCLOXACILLINE CASSETTE 12" ~ amount, 
             label_descr == "FLUCLOXACILLINE CASSETTE 6G" ~ amount, 
             label_descr == "TARDOCILLIN 1200 SUSPENSIE" ~ amount,
             label_descr == "PENIDURAL 1,2MIE PDR+SV 5ML" ~ amount,
             label_descr == "PENIDURAL 1,2MIE PDR+SV 5ML" ~ amount,
             label_descr == "DOXYCYCLINE ALPHARMA DISPER" ~ amount,
             label_descr == "DOXYCYCLINE CF DISPER TABLE" ~ amount,
             label_descr == "FLOXAPEN POEDER BIJBETALING" ~ amount,
             label_descr == "LEVOFLOXACINE BLUEFISH TABL" ~ amount,
             label_descr == "Tardocillin 1200 inj 1,2ME" ~ amount,
             label_descr == "TARDOCILLIN 1,2MIE 4ML" ~ amount,
             
             label_descr == "TARDOCILLIN 1200 INJSUSP 1," ~ amount,
             label_descr == "CEFTRIAXON 2 GRAM INTERMATE" ~ amount,
             label_descr == "FASIGYN 500MG TABLET" ~ amount/2,
             label_descr == "TRIMETHOPRIM SUSPENSIE 1G/1" ~ 1,
             label_descr == "NITROFUR SUSP 10 MG/ML" ~ 5, 
             label_descr == "CEFUROXIM CASSETTE 4500MG/2" ~ amount, 
             label_descr == "Tardocillin 1200 inj 1,2ME/" ~ amount, 
             label_descr == "CEFUROXIM CASSETTE 4500MG/2" ~ amount, 
             label_descr == "BENZYLPENICILLIN V INF NVZA" ~ amount, 
             TRUE ~ rx_duration
           ))

check9 <- rx_J01 %>% 
  filter(is.na(rx_duration))

# change dose based on check9
rx_J01 <- rx_J01 %>% 
  mutate(rx_duration = 
           if_else(is.na(rx_duration),
                   amount, 
                   rx_duration))

check10 <- rx_J01 %>% filter(is.na(rx_duration))

check11 <- rx_J01 %>% 
  filter(rx_duration > 120) # confirmed

################################################################################

rx <- rx_J01 %>% 
  left_join(atc_codes, by = "atc_code")

check12 <- rx %>% 
  filter(is.na(atc_name))

rx1 <- rx %>% 
  ungroup() %>% 
  group_by(atc_code, atc_name) %>% 
  summarize(median = median(rx_duration), 
            mean = mean(rx_duration), 
            max = max(rx_duration),
            n = n())

################################################################################
# removing no longer necessary columns
rx_J01 <- rx_J01 %>% 
  select(-c(ddd, 
            amount, 
            units, 
            label_descr, 
            dose_descr, 
            daily_units, 
            product_code)) 

rx_J01 <- rx_J01 %>%  
  mutate(rx_end_date = eventdate + rx_duration)

################################################################################

write_rds(rx_J01, 
          "./2_interim_data/rx_J01_with_duration.RDS")

