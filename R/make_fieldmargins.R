#' Make field margin layers
#'
#' Takes field polygons and overlays them on land cover layer (cdl) and
#' determines field margins, including inner and outer margin costs
#'
#' @param field.id.rast field id raster, `id` layer returned from `make_fields`
#' @param inner.margin.cost proportional cost of an inner border compared to
#'   outer field border. Default is inner border is 2x cost
#' @param field.crop.rast field crop raster, `crop` layer returned from
#'   `make_fields`
#' @param show.progress T/F show progress
#'
#' @return A list with a raster stack of 1) margin cell id, 2) margin cell cost,
#'   and 3) margin field id
#' @export
#'
make_fieldmargins <- function(field.id.rast, inner.margin.cost=2,
                              field.crop.rast,
                              show.progress=TRUE){

  field.ids <- terra::unique(field.id.rast)[,1]

  fieldborders <- terra::setValues(field.id.rast, NA)
  # cycle through fields and add borders iterative. Supposed to prevent double borders
  if(show.progress) pb = txtProgressBar(min = 0, max = length(field.ids), initial = 0, style=3)
  keep.track <- c()
  for(i in 1:length(field.ids)){
    keep.track[i] <- field.ids[i]
    field.i <- terra::ifel(!is.na(terra::match(field.id.rast, keep.track)), 1, NA)
    fieldborders.i <- terra::boundaries(field.i)
    fieldborders <- terra::ifel(!is.na(fieldborders), fieldborders, fieldborders.i)
    if(show.progress) setTxtProgressBar(pb,i)
  }

  # cost of installation
  outsideborders <- terra::boundaries(terra::ifel(!is.na(field.id.rast),1,NA))

  costborders <- terra::ifel(outsideborders==1, 1, inner.margin.cost*fieldborders)       # outside borders should cost less
  costborders <- terra::ifel(costborders==0, NA, costborders) # remove zero cells

  field_id <- terra::ifel(!is.na(costborders), field.id.rast, NA)

  field_crop <- terra::ifel(!is.na(costborders), field.crop.rast, NA)

  fieldmargins <- terra::rast(terra::sds(list(costborders, field_id, field_crop)))
  names(fieldmargins) <- c("cost", "field_id", "field_crop")

  return(fieldmargins)

}
