
wrapDays <- function(d){
  ifelse(d>365,d-365,d)
}

asJDay <- function(m,d){
  aDate <- as.Date(paste("2023",m,d,sep="-"),
                   tryFormats=c("%Y-%m-%d", "%Y-%B-%d", "%Y-%b-%d"))
  as.numeric(format(aDate, "%j"))
}
