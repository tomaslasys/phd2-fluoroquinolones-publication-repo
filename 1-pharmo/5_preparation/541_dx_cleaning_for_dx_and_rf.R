
source("4_functions/run_my_functions.R")

# uploading data ###############################################################

rf_index <- 
  readRDS("./temp/rf_index.rds") %>% 
  mutate(type = "rf") %>% 
  rename(group = concept) %>% 
  mutate(group = if_else(group == "dyslipidemia", "dislipidemia", group))

dx_index <- 
  readRDS("./temp/dx_index.rds")%>% 
  rename(group = concept) %>% 
  mutate(type = "inf")

gp_data <- 
  readRDS("./1_raw_data/renamed/gp_data.RDS")

hospitalizations <- 
  readRDS("./1_raw_data/renamed/hospitalizations.RDS")

included_IDs <- 
  readRDS("./2_interim_data/index_dates_pg7.RDS") %>% 
  select(patid)

################################################################################

gp_data <- gp_data %>% 
  semi_join(included_IDs, by = "patid") %>% 
  mutate(row = row_number())

hospitalizations <- hospitalizations %>% 
  semi_join(included_IDs, by = "patid")

code_index <- rf_index %>% 
  bind_rows(dx_index) %>% 
  mutate(type = case_when(
    type == "inf" ~ "indications",
    type == "rf" ~ "risk_factors",
    TRUE ~ NA)) 

rm(included_IDs)
rm(rf_index)
rm(dx_index)

################################################################################

dx_icpc <- code_index %>% 
  filter(system == "icpc") %>% 
  rename(icpc_code = code) %>% 
  select(icpc_code, dx_group = group, type) 

dx1 <- gp_data %>% 
  semi_join(dx_icpc, by = "icpc_code") %>% 
  left_join(dx_icpc, by = "icpc_code") %>%
  select(patid, eventdate, dx_group, type) %>%
  mutate(prescriber = "GP")

dx_icd9 <- code_index %>% 
  filter(system == "icd9") %>% 
  rename(icd9 = code) %>% 
  select(icd9, dx_group = group, type)

dx2 <- hospitalizations %>% 
  filter(!is.na(icd9)) %>% 
  semi_join(dx_icd9, by = "icd9") %>% 
  left_join(dx_icd9, by = "icd9") %>% 
  select(patid, eventdate, dx_group, type) %>% 
  mutate(prescriber = "hospital")


dx_icd10 <- code_index %>% 
  filter(system == "icd10") %>% 
  rename(icd10 = code) %>% 
  select(icd10, dx_group = group, type)

dx3 <- hospitalizations %>% 
  filter(!is.na(icd10)) %>% 
  semi_join(dx_icd10, by = "icd10") %>% 
  left_join(dx_icd10, by = "icd10") %>% 
  select(patid, eventdate, dx_group, type) %>% 
  mutate(prescriber = "hospital")


rm(dx_icpc)
rm(gp_data)
rm(dx_icd9)
rm(dx_icd10)
rm(hospitalizations)
rm(code_index)

dx <- dx1 %>% 
  bind_rows(dx2) %>% 
  bind_rows(dx3) %>% 
  rename(dx_date = eventdate) %>% 
  split(as.factor(.$type))

dx <- lapply(dx, function(x)select(x, -type))

list2env(dx, 
         envir = .GlobalEnv)

rm(dx,
   dx1, 
   dx2,
   dx3)

################################################################################

saveRDS(indications, 
        "./2_interim_data/indications.rds")

saveRDS(risk_factors, 
        "./2_interim_data/risk_factors.rds")

rm(indications,
   risk_factors)


