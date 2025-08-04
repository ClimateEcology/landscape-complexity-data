## code to prepare `biophys_sdr` dataset
library(tidyverse)

biophys_sdr <- read.csv("data-raw/sediment_delivery_ratio/biophys_sdr_Borrelli.csv") %>%
  select(lucode, name, usle_c, usle_p)

usethis::use_data(biophys_sdr, overwrite = TRUE)
