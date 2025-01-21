# Impact of Pharmacovigilance Interventions Targeting Fluoroquinolones on Antibiotic Use in the Netherlands and the United Kingdom

[DOI: 10.1002/pds.70081](https://doi.org/10.1002/pds.70081)

---

## Project Repository

This repository documents the folder structures and scripts used for the analysis in the study. It is organized into separate directories for PHARMO and CPRD data, as well as sections dedicated to the manuscript and supplementary material. 

---

## Folder Structure

### `1-pharmo/`
*This directory contains the folder structure and scripts used for analyzing PHARMO data.*  
The data were processed in a secure virtual environment, following this standardized structure:

- **`0_codelists/`**:  
  *Contains code lists used to identify relevant variables, diagnoses, medications, and datasets.*
- **`1_raw_data/`**:  
  *Includes the original raw data*
- **`2_interim_data/`**:  
  *Houses intermediate datasets generated during data preprocessing and transformation.*
- **`3_clean_data/`**:  
  *Contains datasets that are ready for analysis.*
- **`4_functions/`**:  
  *Stores reusable scripts and functions*
- **`5_preparation/`**:  
  *Includes scripts for preparing data for analysis, such as merging, cleaning, or transforming variables.*
- **`6_analysis/`**:  
  *Contains analysis scripts*
- **`7_outputs/`**:  
  *Stores results*

---

### `2-cprd/`
*This directory contains the folder structure and scripts used for analyzing CPRD GOLD data.*  
CPRD data were processed in a secure virtual environment, mirroring the structure used for PHARMO data. The standardized format includes:

- **`0_codelists/`**:  
  *Contains code lists used to identify relevant variables, diagnoses, medications, and datasets.*
- **`1_raw_data/`**:  
  *Includes the original raw data*
- **`2_interim_data/`**:  
  *Houses intermediate datasets generated during data preprocessing and transformation.*
- **`3_clean_data/`**:  
  *Contains datasets that are ready for analysis.*
- **`4_functions/`**:  
  *Stores reusable scripts and functions*
- **`5_preparation/`**:  
  *Includes scripts for preparing data for analysis, such as merging, cleaning, or transforming variables.*
- **`6_analysis/`**:  
  *Contains analysis scripts*
- **`7_outputs/`**:  
  *Stores results*

---

### `3-manuscript/`
*This directory contains the scripts and data used for the manuscript.*  
It ensures the reproducibility of the main results presented in the study and includes:
- Analysis scripts specific to manuscript results.
- Outputs such as tables and figures included in the manuscript.

---

### `4-supplement/`
*This directory contains scripts and data used for the supplementary material.*  
It includes additional analyses and outputs that were included in the supplementary material.

---

### `functions/`
*This directory centralizes reusable function scripts.*  
Functions stored here are used across multiple directories (`3-manuscript/` and `4-supplement/`).

---

### `output/`
*This directory consolidates all finalized output tables and graphs used in the manuscript and supplementary material.* 
