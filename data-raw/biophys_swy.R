## code to prepare `biophys_swy` dataset

library(tidyverse)
devtools::load_all()

kcref <- read.csv("data-raw/seasonal_water_yield/biophys_swy_kc.csv")

# warnings are ok because mid values that are non-numeric are for crops with a harvest date
fao_ref <- kcref %>% filter(Kc.reference %in% c("FAO","Double")) %>%
  select(VALUE, CLASS_NAME, Kc.reference,
         ini, mid, end,
         Init...Lini.,Dev...Ldev.,Mid..Lmid.,Late..Llate.,Total,
         Plant.month,Plant.day,Harv.month,Harv.day,
         Winter.ini,Winter.mid,Winter.end,
         Winter.Init...Lini.,Winter.Dev...Ldev.,Winter.Mid..Lmid.,
         Winter.Late..Llate.,Winter.Total,Winter.plant.month,Winter.plant.day) %>%
  mutate(Mid..Lmid. = as.numeric(Mid..Lmid.),
         Late..Llate. = as.numeric(Late..Llate.))

# single crop--------
singlecrop <- fao_ref %>% filter(Kc.reference=="FAO")
singlecrop.params <- list()

for(i in seq_len(nrow(singlecrop))){
  crop.i <- singlecrop[i,]
  singlecrop.params[[i]] <- list(
    ini = crop.i$ini,
    mid = crop.i$mid,
    end = crop.i$end,
    dayPlant = asJDay(m=crop.i$Plant.month, d=crop.i$Plant.day),
    monthly = TRUE,
    Lini = crop.i$Init...Lini.,
    Ldev = crop.i$Dev...Ldev.
  )
  if(!is.na(crop.i$Mid..Lmid.)){
    singlecrop.params[[i]] <- c(
      singlecrop.params[[i]],
      Lmid = crop.i$Mid..Lmid.,
      Llate = crop.i$Late..Llate.
    )
  }else{
    singlecrop.params[[i]] <- c(
      singlecrop.params[[i]],
      dayHarvest = asJDay(m=crop.i$Harv.month, d=crop.i$Harv.day)
    )
  }
}

# list of single crop Kc
singlecropkc <- lapply(singlecrop.params, \(x){do.call(make_kc_curves,x)})
names(singlecropkc) <- singlecrop$VALUE

# double crop-------
doublecrop <- fao_ref %>% filter(Kc.reference=="Double")
doublecrop.params <- list()

for(i in seq_len(nrow(doublecrop))){
  doublecrop.i <- doublecrop[i,]
  doublecrop.params[[i]] <- list(
    ini = doublecrop.i$ini,
    mid = doublecrop.i$mid,
    end = doublecrop.i$end,
    dayPlant = asJDay(m=doublecrop.i$Plant.month, d=doublecrop.i$Plant.day),
    doublecrop = TRUE, monthly = TRUE,
    Lini = doublecrop.i$Init...Lini.,
    Ldev = doublecrop.i$Dev...Ldev.,
    Lmid = doublecrop.i$Mid..Lmid.,
    Llate = doublecrop.i$Late..Llate.,
    winter.ini = doublecrop.i$Winter.ini,
    winter.mid = doublecrop.i$Winter.mid,
    winter.end = doublecrop.i$Winter.end,
    winter.dayPlant = asJDay(m=doublecrop.i$Winter.plant.month, d=doublecrop.i$Winter.plant.day),
    winter.Lini = doublecrop.i$Winter.Init...Lini.,
    winter.Ldev = doublecrop.i$Winter.Dev...Ldev.,
    winter.Lmid = doublecrop.i$Winter.Mid..Lmid.,
    winter.Llate = doublecrop.i$Winter.Late..Llate.
  )
}

# list of double crop Kc
doublecropkc <- lapply(doublecrop.params, \(x){do.call(make_kc_curves,x)})
names(doublecropkc) <- doublecrop$VALUE

# Nistor method-------
nistorlc <- kcref %>% filter(Kc.reference=="Nistor et al.")
nistorlc.params <- list()

for(i in seq_len(nrow(nistorlc))){
  nistorlc.i <- nistorlc[i,]
  nistorlc.params[[i]] <- list(
    ini = nistorlc.i$ini,
    mid = nistorlc.i$mid,
    end = nistorlc.i$end,
    cold = nistorlc.i$cold,
    monthly = TRUE,
    Nistor = TRUE
  )
}

# list of Nistor land cover Kc
nistorkc <- lapply(nistorlc.params, \(x){do.call(make_kc_curves,x)})
names(nistorkc) <- nistorlc$VALUE

# combine kc tables
Kc_cdl <- bind_rows(
  bind_rows(
    lapply(singlecropkc,pivot_wider,names_from=month,values_from=Kc,names_prefix="Kc_"),
    .id = "VALUE"
  ),
  bind_rows(
    lapply(doublecropkc,pivot_wider,names_from=month,values_from=Kc,names_prefix="Kc_"),
    .id = "VALUE"
  ),
  bind_rows(
    lapply(nistorkc,pivot_wider,names_from=month,values_from=Kc,names_prefix="Kc_"),
    .id = "VALUE"
  )
) %>% mutate(VALUE = as.numeric(VALUE))

biophys_swy <- read.csv("data-raw/seasonal_water_yield/biophys_swy_cn.csv") %>%
  left_join(Kc_cdl, by = c(lucode="VALUE")) %>%
  select(-curvenum_ref) %>% mutate(across(Kc_1:Kc_12, ~.x/1.2)) # convert to alfalfa based ref.

usethis::use_data(biophys_swy, overwrite = TRUE)
