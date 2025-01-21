
library(tidyverse)
library(haven)

# read data ###########################################################

file_list <- list.files(path = "C:/export/",
                        pattern = ".sas7bdat",
                        full.names = TRUE)

file_list

raw_data <- lapply(file_list, function(x)read_sas(x))

file_names <- str_replace(file_list,
                         ".*\\/", "") %>%
                         str_replace(".sas7bdat", "")

names(raw_data) <- file_names

list2env(raw_data, envir = .GlobalEnv)

rm(file_list)
rm(file_names)
rm(raw_data)

################################################################################
# RENAMING FILES&COLUMNS #######################################################
################################################################################
# medication (-> rx) ###########################################################

# removing unecessary attributes
medication <- medication %>%
  mutate_all(`attr<-`, "format.sas", NULL) %>%
  mutate_all(`attr<-`, "label", NULL)

# renaming variables
#
# original_variable_name = description of the variable -> changed_name
#
# patient_id = Unique patient ID                  -> patid
# oapo_afldat = Day-Month-Year date of dispensing -> eventdate
# oapo_aflaantal = Amount dispensed               -> dispensed_amount
# oapo_afleenh = Unit dispensed amount            -> dispensed_units
# DDD = Defined Daily Dose                        -> ddd
# oapo_atccd = WHO ATC code                       -> atc_code
# oapo_etiket = Label description                 -> label_descr
# oapo_dosoms = Dose description                  -> dose_descr
# DS_NUnits = Units per day                       -> daily_units
# oapo_hpcd = Trade product code                  -> product_code

str(medication)

medication <- medication %>%
  rename(patid = patient_ID, 
         eventdate = oapo_afldat,
         amount = oapo_aflaantal,
         units = oapo_afleenh,
         ddd = DDD,
         atc_code = oapo_atccd,
         label_descr = oapo_etiket,
         dose_descr = oapo_dosoms,
         daily_units = DS_NUnits,
         product_code = oapo_hpcd)
str(medication)

# changing variable types
medication <- medication %>%
  mutate(across(c(patid,
                  units,
                  atc_code,
                  product_code),
                factor))

str(medication)

# spliting data into datasets based on drug class 
#
# main exposure is J01
# other drugs are for risk factors or concomitant use

rx <- medication %>%
  mutate(set = 
           case_when(
             grepl("^J01", atc_code) ~ "rx_J01",
             grepl("^H02", atc_code) ~ "rx_H02",
             grepl("^C10", atc_code) ~ "rx_C10",
             TRUE ~ "rx_other")) %>%
  split(as.factor(.$set))

rm(medication)

rx <- lapply(rx, function(x)select(x, -c(set)))

saveRDS(rx$rx_J01, 
        "./1_raw_data/renamed/rx_J01.RDS")

saveRDS(rx$rx_H02, 
        "./1_raw_data/renamed/rx_H02.RDS")

saveRDS(rx$rx_C10, 
        "./1_raw_data/renamed/rx_C10.RDS")

rm(rx)
gc()

################################################################################

str(gp_data)

# original_variable_name = description of the variable -> changed_name
#
# patient_id = Unique patient ID                    -> patid
# gp_epssince = Day-month-year start date episode   -> eventdate
# gp_epsicpc = GP coded diagnosis (ICPC code)       -> icpc_code

gp_data <- gp_data %>%
  rename(patid = patient_ID, 
         eventdate = gp_epssince,
         icpc_code = gp_epsicpc)

gp_data <- gp_data %>%
  mutate_all(`attr<-`, "format.sas", NULL) %>%
  mutate_all(`attr<-`, "label", NULL)

str(gp_data)

gp_data <- gp_data %>%
  mutate(across(c(patid,
                  icpc_code),
                factor))

saveRDS(gp_data, 
        "./1_raw_data/renamed/GP_data.RDS")

rm(gp_data)
gc()

################################################################################
################################################################################

str(hospital_admissions)

# original_variable_name = description of the variable -> changed_name
#
# patient_id = Unique patient ID                        -> patid
# zopn_opnamedat = Day-month-year date of admission     -> eventdate
# zopn_ontslagdat = (Day-)month-year date of discharge  -> enddate
# ICD9 = Diagnosis ICD9                                 -> icd9
# ICD10 = Diagnosis ICD10                               -> icd10
# zopn_primdiag = Primary diagnosis (1=yes, 0=no)       -> primary_dx

hospitalizations <- hospital_admissions %>%
  mutate_all(`attr<-`, "format.sas", NULL) %>%
  mutate_all(`attr<-`, "label", NULL)

rm(hospital_admissions)

str(hospitalizations)

hospitalizations <- hospitalizations %>%
  rename(patid = patient_ID, 
         eventdate = zopn_opnamedat,
         enddate = zopn_ontslagdat,
         icd9 = ICD9,
         icd10 = ICD10,
         primary_dx = zopn_primdiag)

hospitalizations <- hospitalizations %>%
  mutate(across(c(patid,
                  icd9,
                  icd10,
                  primary_dx),
                factor))


hospitalizations
str(hospitalizations)

saveRDS(hospitalizations,
        "./1_raw_data/renamed/hospitalizations.RDS")

rm(hospitalizations)
gc()

################################################################################

str(patientmatrix)

# patient_id = Unique patient ID                  -> patid
# cpb_gebjaar = Year of birth                     -> yob
# cpb_geslacht = Gender (M = male, F = female)    -> sex
# startfu = Day-Month-Year start follow-up in the PHARMO Data Network (start study period (01-01-2014) or start data collection of specific patient)
#         -> crd
# endfu = Day-month-year end of follow-up in the PHARMO Data Network (death, end of study period (31-12-2021) or end of follow-up in PHARMO)
#         -> tod
# hosp_avail = Linkage to hospital data (1=yes, 0=no) 
#         -> hosp_link
# study_pop1 = Patient is part of study population 1 (1=yes, 0=no) -> cohort1
# study_pop2 = Patient is part of study population 2 (1=yes, 0=no) -> cohort2

demographics <- patientmatrix %>%
  rename(patid = patient_ID, 
         yob = cpb_gebjaar,
         sex = cpb_geslacht,
         crd = startfu,
         tod = endfu,
         hosp_link = hosp_avail,
         cohort1 = study_pop1,
         cohort2 = study_pop2) 
rm(patientmatrix)

demographics <- demographics %>%
  mutate_all(`attr<-`, "format.sas", NULL) %>%
  mutate_all(`attr<-`, "label", NULL)

demographics <- demographics %>%
  mutate(across(c(patid,
                 sex,
                 hosp_link,
                 cohort1,
                 cohort2),
               factor))
str(demographics)

################################################################################

saveRDS(demographics, 
        "./1_raw_data/renamed/demographics.RDS")

rm(demographics)

