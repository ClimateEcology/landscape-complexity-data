#' Return crop sequence boundary polygons falling within a polygon
#'
#' @param polysf sf polyon
#' @param cropbdry.path Character string to cropbdry geodatabase
#'
#' @return sf polygon object of crop sequence boundary polygons falling within
#'   `polysf`
#' @export
#'
query_cropbdry <- function(polysf, cropbdry.path){
  if(sf::st_crs(polysf)!=cropbdry.crs){
    polysf <- sf::st_transform(x=polysf, crs=cropbdry.crs)
  }

  thesecounties <- counties[sf::st_intersects(polysf, counties)[[1]],]

  # use sql to subset to containing counties
  cropbdry.sql <- paste0("SELECT * FROM nationalGIS WHERE ",
                  paste(
                    paste0(rep("(STATEFIPS = ", nrow(thesecounties)),
                           paste0("'",thesecounties$STATEFP,"'"),
                           " AND ",
                           rep("CNTYFIPS = ", nrow(thesecounties)),
                           paste0("'",thesecounties$COUNTYFP,"')")
                    ),
                    collapse=" OR "
                  ))

  cty.cropbdry <- sf::st_read(cropbdry.path, query = cropbdry.sql)

  # subset to crop boundaries within polysf
  cty.cropbdry[polysf, op=sf::st_within]
}
