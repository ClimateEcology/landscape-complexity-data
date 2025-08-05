#' Make fields raster from crop sequence boundaries polygons
#'
#' Makes a layer with focal fields identified by the crop sequence boundary
#' layer. Outputs a 2-layer raster of the field cells only, with cell values
#' showing 1) field id, 2) crop fields, and 3) a 'cleaned' version of the cdl
#' where crop fields contain only a single crop type.  The function assigns a
#' sequential field id based on CSB polygon row number.
#'
#' @param fields.poly Crop sequence boundaries polygons, in sf format
#' @param field.col Crop ID column name in csb polygon vector object
#' @param cdl.rast CDL raster on which to superimpose the `fields.poly` fields
#'
#' @return 3-layer terra raster of field id, crop fields, and cdl with 'cleaned'
#'   crop fields
#' @export
#'
make_fields <- function(fields.poly, field.col, cdl.rast){
  fields.poly <- fields.poly %>% dplyr::mutate(field.id=row_number())

  mgmt.zones <- terra::rasterize(fields.poly, cdl.rast, field = "field.id") # field IDs
  mgmt.crops <- terra::rasterize(fields.poly, cdl.rast, field = field.col) # field crops

  mgmt.cdl <- terra::ifel(is.na(mgmt.zones),mgmt.zones,cdl.rast) # isolate AOI area

  mgmt.fld <- terra::classify(mgmt.cdl, rcl = field.rcl)   # keep only field areas
  mgmt.fld.id <- terra::ifel(mgmt.fld==1, mgmt.zones, NA)  # cdl field cells with the ID
  mgmt.fld.crop <- terra::ifel(mgmt.fld==1, mgmt.crops, NA)  # cdl field cells with crop

  cdl.clean <- terra::ifel(is.na(mgmt.fld.crop), cdl.rast, mgmt.fld.crop)

  terra::rast(list(id=mgmt.fld.id, crop=mgmt.fld.crop, cdl.clean=cdl.clean))
}
