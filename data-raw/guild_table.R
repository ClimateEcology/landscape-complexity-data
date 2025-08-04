## code to prepare `guild_table` dataset

guild_table <- read.csv("data-raw/pollination/guild_table_kammerer.csv")

usethis::use_data(guild_table, overwrite = TRUE)
