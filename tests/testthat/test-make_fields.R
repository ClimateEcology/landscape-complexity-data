
#-------- ref code to build csbtest dataset --------
# wsb <- sf::st_read(test_path("testdata/watershed.gpkg"))
# csb.path <- "path/to/csb.gdb"
# csb <- query_cropbdry(wsb,csb.path)
# sf::st_write(csb, test_path("testdata/csbtest.gpkg"))

#--------- test -------------
csb <- sf::st_read(test_path("testdata/csbtest.gpkg"))
cdl <- terra::rast(test_path("testdata/cdl_hu010700060102.tif"))

test_that("make fields works", {
  testfields <- make_fields(csb, "R22", cdl)

  # output is raster
  expect_s4_class(testfields, "SpatRaster")

  # output has the three expected layers
  expect_equal(names(testfields), c("id","crop","cdl.clean"))
})
