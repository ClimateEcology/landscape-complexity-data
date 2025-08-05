#' Add margins to cropland data layer raster
#'
#' Add margin raster (output from `make_fieldmargins`) to a CDL layer
#'
#' @param margin.lc margin habitat code (numeric value). Default is 171
#' @param margin.rast raster representing margin cells as non-NA values and all other cells NA
#' @param cdl.rast raster representing CDL land cover. Can use the `cdl.clean` layer from `make_fields` output
#'
#' @returns raster of CDL land cover with field margins indicated by `margin.rast` with the `margin.lc` value
#' @export
#'
add_margins_cdl <- function(margin.lc = 171, margin.rast, cdl.rast){

  marginfield <- terra::ifel(
    test=!is.na(margin.rast),       # if margin id layer is not NA
    yes=margin.lc,                  # assign margin land cover
    no=cdl.rast,                    # otherwise assign CDL data
    datatype="INT1U", NAflag=255,   # output file params
    overwrite = TRUE
  )

  marginfield
}
