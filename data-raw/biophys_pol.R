## code to prepare `biophys_pol` dataset
library(tidyverse)
koh_reclass <- read.csv("data-raw/pollination/koh_reclass.csv")

biophys_pol_flr <- koh_reclass %>%
  left_join(read.csv("data-raw/pollination/koh_floralresources.csv"),
            by = c("Koh.reclass" = "Categories")) %>%
  select(VALUE, CDL.class, Spring.mean, Summer.mean, Autumn.mean) %>%
  rename(lucode="VALUE", CLASS_NAME="CDL.class",
         floral_resources_spring_index="Spring.mean",
         floral_resources_summer_index="Summer.mean",
         floral_resources_fall_index="Autumn.mean")

biophys_pol_nst <- koh_reclass %>%
  left_join(read.csv("data-raw/pollination/koh_nestresources.csv"),
            by = c("Koh.reclass" = "Categories")) %>%
  select(VALUE, CDL.class, Ground.mean, Cavity.mean, Stem.mean, Wood.mean) %>%
  rename(lucode="VALUE", CLASS_NAME="CDL.class",
         nesting_ground_availability_index="Ground.mean",
         nesting_cavity_availability_index="Cavity.mean",
         nesting_stem_availability_index="Stem.mean",
         nesting_wood_availability_index="Wood.mean")

biophys_pol <- biophys_pol_nst %>% left_join(biophys_pol_flr)

usethis::use_data(biophys_pol, overwrite = TRUE)
