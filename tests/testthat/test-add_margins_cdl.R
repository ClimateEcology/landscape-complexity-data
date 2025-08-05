#-------- ref code to build testmargins dataset --------
# testfields <- terra::rast(testthat::test_path("testdata/testfields.tif"))
# testmargins <- make_fieldmargins(testfields$id, testfields$crop)
# terra::writeRaster(testmargins,testthat::test_path("testdata/testmargins.tif"))

cdl <- terra::rast(test_path("testdata/testfields.tif"))
margins <- terra::rast(test_path("testdata/testmargins.tif"))

test_that("add margins to CDL works", {
  fieldmargins <- add_margins_cdl(margin.rast = margins$field_id, cdl.rast = cdl$cdl.clean)

  # output is raster
  expect_s4_class(fieldmargins, "SpatRaster")

  # output has the expected layer (cdl)
  expect_equal(names(fieldmargins), c("cdl.clean"))

  # output includes the new pollinator habitat code (171)
  expect_contains(terra::values(fieldmargins), 171)
})
