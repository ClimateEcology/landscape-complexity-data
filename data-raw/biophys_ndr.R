## code to prepare `biophys_ndr` dataset
library(tidyverse)

# land use crosswalk groups
ndr_lugroups <- read.csv("data-raw/nutrient_delivery_ratio/biophys_ndr_groups.csv")

# NP application by crop groups from Stewart et al. 2019
crop_NP <- read.csv("data-raw/nutrient_delivery_ratio/NP_application_Stewart.csv")

# pameter values from Benez-Secanho et al.
param_BenezSecanho <- read.csv("data-raw/nutrient_delivery_ratio/biophys_ndr_BenezSecanho.csv")

# Use crosswalk to match crop to Stewart NP applications and adjust
# for on-pixel retention: applied_nutrient * (1 - retention_efficiency)
# https://storage.googleapis.com/releases.naturalcapitalproject.org/invest-userguide/latest/en/ndr.html#data-needs


biophys_ndr <- ndr_lugroups %>%
  left_join(param_BenezSecanho) %>% left_join(crop_NP, by = c("crop_group_Stewart2019" = "crop_group")) %>%
  mutate(load_n = ifelse(lucode_nlcd==82, n_apply_kgha*(1-eff_n), load_n),
         load_p = ifelse(lucode_nlcd==82, p_apply_kgha*(1-eff_p), load_p)) %>%
  select(lucode_cdl, name, load_n, eff_n, load_p, eff_p, crit_len_n, crit_len_p, proportion_subsurface_n) %>%
  rename(lucode = lucode_cdl)

usethis::use_data(biophys_ndr, overwrite = TRUE)
