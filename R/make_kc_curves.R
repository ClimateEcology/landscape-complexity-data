#' Make Kc curves
#'
#' Follows the FAO method of defining Kc curves based on crop development
#' stages. Kc values are calculated for every day of the year based on the
#' user-provided Kc values, development dates, and stage lengths from Allen et
#' al. (1998). If `doublecrop` is indicated, then these parameter values for the
#' second crop must also be provided. If `Nistor` is TRUE, then season-based Kc
#' values from Nistor et al. (2018) need to be provided.
#'
#' @param ini Kc_ini crop coefficient
#' @param mid Kc_mid crop coefficient
#' @param end Kc_end crop coefficient
#' @param Lini L_ini length of Kc_ini period
#' @param Ldev L_dev length of development period between Kc_ini and Kc_mid
#'   periods
#' @param Lmid L_mid length of Kc_mid period
#' @param Llate L_late length of period transitioning from end of Kc_mid to
#'   Kc_end
#' @param dayPlant Julian day of spring crop
#' @param dayHarvest (Optional) date of harvest. Only needed if Lmid and Llate
#'   are not provided
#' @param doublecrop T/F whether to calculate curve for a winter crop
#'   (double-cropping), default is FALSE
#' @param winter.dayPlant (Optional) Julian day of winter planting, only for
#'   double crops
#' @param winter.ini (Optional) Kc_ini for winter crop
#' @param winter.mid (Optional) Kc_mid for winter crop
#' @param winter.end (Optional) Kc_end for winter crop
#' @param winter.Lini (Optional) L_ini length of Kc_ini of winter crop
#' @param winter.Ldev (Optional) L_dev length of development between Kc_ini and
#'   Kc_mid of winter crop
#' @param winter.Lmid (Optional) L_mid length of Kc_mid period of winter crop
#' @param winter.Llate (Optional) L_late length of period from end of Kc_mid to
#'   Kc_end of winter crop
#' @param monthly T/F whether to return daily (F) or monthly (T) Kc values.
#' @param Nistor T/F whether to use the method in Nistor et al. 2018
#' @param cold cold period parameter from Nistor et al. 2018
#'
#' @return A dataframe of daily or monthly Kc values based on inputs
#' @export
#'
#' @examples make_kc_curves(ini=0.7,mid=1.2,end=0.48,Lini=30,Ldev=40,Lmid=50,Llate=50,dayPlant=105,doublecrop=TRUE,winter.dayPlant=288,winter.ini=0.4,winter.mid=1.15,winter.end=0.33,winter.Lini=30,winter.Ldev=140,winter.Lmid=40,winter.Llate=30)
#'

make_kc_curves <- function(ini, mid, end, Lini, Ldev, Lmid, Llate,
                           dayPlant, dayHarvest,
                           doublecrop = FALSE, winter.dayPlant,
                           winter.ini, winter.mid, winter.end,
                           winter.Lini, winter.Ldev, winter.Lmid, winter.Llate,
                           monthly = TRUE, Nistor = FALSE, cold
                           ){

  # build a date table
  yeardates <- seq(as.Date("2023-01-01"), as.Date("2023-12-31"), by="days")
  datedf <- data.frame(jday = as.numeric(format(yeardates, "%j")),
                       month = as.numeric(format(yeardates, "%m")),
                       day = as.numeric(format(yeardates, "%d")),
                       Kc = NA)

  if(Nistor){
    if(missing(cold)|is.na(cold)){
      cold <- ini
    }
    # Nistor ini
    datedf[datedf$month %in% c(3,4,5), "Kc"] <- ini
    # Nistor mid
    datedf[datedf$month %in% c(6,7,8), "Kc"] <- mid
    # Nistor end
    datedf[datedf$month %in% c(9,10), "Kc"] <- end
    # Nistor cold
    datedf[datedf$month %in% c(1,2,11,12), "Kc"] <- cold
  }else{
    if(!missing(dayHarvest) & (!missing(Lmid) | !missing(Llate))){
      stop("Provide `dayHarvest` or mid- and late-season lengths (`Lmid` and `Llate`) but not both")
    }

    # calculate daily kc values for spring planting
    iniEnd <- dayPlant + Lini - 1                         # last day of the Kcini period
    datedf[wrapDays(dayPlant:iniEnd),"Kc"] <- ini         # assign Kcini period

    midBegin <- dayPlant + Lini + Ldev          # first day of Kcmid period
    devIncr <- (mid-ini)/(midBegin-iniEnd)      # increment of daily increase in Ldev period
    for(i in (iniEnd+1):midBegin){
      datedf[wrapDays(i),"Kc"] <- ini + devIncr * (i - iniEnd)  # apply increments up to midBegin
    }

    if(!missing(Lmid)){
      midEnd <- midBegin + Lmid -1                          # last day of the Kmid period
      datedf[wrapDays(midBegin:midEnd),"Kc"] <- mid         # assign Kmid period

      endSeason <- midBegin + Lmid + Llate          # end of season
      lateIncr <- (end-mid)/(endSeason-midEnd)      # increment of daily decrease in Llate period
      for(i in (midEnd+1):endSeason){
        datedf[wrapDays(i),"Kc"] <- mid + lateIncr * (i - midEnd)  # apply increments up to up to endSeason
      }
    }else{
      midEnd <- dayHarvest-1
      datedf[wrapDays(midBegin:midEnd),"Kc"] <- mid         # assign Kmid period
      datedf[wrapDays(dayHarvest),"Kc"] <- end
      endSeason <- dayHarvest
    }

    # use Kc ini for dormant season
    dormantEnd <- dayPlant + 364     # end of dormant season (day before next year's planting date)
    datedf[wrapDays((endSeason+1):dormantEnd),"Kc"] <- ini

    # NOT IMPLEMENTED: linearly increment from end to ini of next season
    # dormantIncr <- (ini-end)/(dormantEnd-endSeason)  # increment of daily change in dormant period
    # for(i in (endSeason+1):dormantEnd){
    #   datedf[wrapDays(i),"Kc"] <- end + dormantIncr * (i - endSeason)  # apply increments up to midBegin
    # }

    # calculate daily kc values for winter planting
    if(doublecrop){

      winter.iniEnd <- winter.dayPlant + winter.Lini - 1              # last day of the winter Kcini period
      datedf[wrapDays(winter.dayPlant:winter.iniEnd),"Kc"] <- winter.ini     # assign winter Kcini period

      winter.midBegin <- winter.dayPlant + winter.Lini + winter.Ldev  # first day of winter Kcmid period
      winter.devIncr <- (winter.mid-winter.ini)/(winter.midBegin-winter.iniEnd)      # increment of daily increase in winter.Ldev period
      for(i in (winter.iniEnd+1):winter.midBegin){
        datedf[wrapDays(i),"Kc"] <- winter.ini + winter.devIncr * (i - winter.iniEnd)  # apply increments up to winter.midBegin
      }

      winter.midEnd <- winter.midBegin + winter.Lmid -1     # last day of the winter Kmid period
      datedf[wrapDays(winter.midBegin:winter.midEnd),"Kc"] <- winter.mid    # assign Kmid period

      winter.endSeason <- winter.midBegin + winter.Lmid + winter.Llate      # end of season
      winter.lateIncr <- (winter.end-winter.mid)/(winter.endSeason-winter.midEnd)    # increment of daily decrease in Llate period
      for(i in (winter.midEnd+1):winter.endSeason){
        datedf[wrapDays(i),"Kc"] <- winter.mid + winter.lateIncr * (i - winter.midEnd)  # apply increments up to up to endSeason
      }

      # linearly increment from end to winter.endSeason of next season
      if(winter.endSeason < dormantEnd){
        datedf[wrapDays((winter.endSeason+1):dormantEnd),"Kc"] <- ini

        # NOT IMPLEMENTED: linearly increment from winter.endSeason to ini of next season
        # winter.dormantIncr <- (ini-winter.end)/(dormantEnd-winter.endSeason)  # increment of daily change in dormant period
        # for(i in (winter.endSeason+1):dormantEnd){
        #   datedf[wrapDays(i),"Kc"] <- winter.end + winter.dormantIncr * (i - winter.endSeason)  # apply increments up to midBegin
        # }
      }
    }
  }

  if(monthly){
    datedf <- datedf %>% group_by(month) %>% summarize(Kc = mean(Kc))
  }
  datedf
}
