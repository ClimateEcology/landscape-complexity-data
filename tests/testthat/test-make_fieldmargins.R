#-------- ref code to build testfields dataset --------
# csb <- sf::st_read(test_path("testdata/csbtest.gpkg"))
# cdl <- terra::rast(test_path("testdata/cdl_hu010700060102.tif"))
# testfields <- make_fields(csb, "R22", cdl)
# terra::writeRaster(testfields,testthat::test_path("testdata/testfields.tif"))

testfields <- terra::rast(testthat::test_path("testdata/testfields.tif"))

test_that("make_fieldmargins works", {
  margins <- make_fieldmargins(testfields$id, testfields$crop)

  # output is raster
  expect_s4_class(margins, "SpatRaster")

  # output has the three expected layers
  expect_equal(names(margins), c("field_id","field_crop"))
})
