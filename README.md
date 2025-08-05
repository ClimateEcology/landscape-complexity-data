
<!-- README.md is generated from README.Rmd. Please edit that file -->

# landscape-complexity-data

<!-- badges: start -->

<!-- badges: end -->

The GitHub repository “landscape-complexity-data” supports the
publication “Benefits of wildflower strips in agricultural field margins
differ based on landscape complexity across four ecosystem services,”
published in *Landscape Ecology*.

The repository is structured as an R package. The “data-raw/” folder
contains the underlying data and code used to build the biophysical
tables for the study’s ecosystem service models. Essential functions for
processing the raw data are stored in the folder “R/”. These functions
are loaded as part of the package. The package can be loaded by ensuring
the working directory is the repository folder (e.g., by opening the
.Rproj file with Rstudio) and then running `devtools::load_all()`. You
can also install the development version of landscape-complexity-data
from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ClimateEcology/landscape-complexity-data")
```

### Writing biophys tables

The biophysical tables are loaded as part of the package. These can be
written to a csv file as follows:

``` r
devtools::load_all()
#> ℹ Loading landscape-complexity-data
```

``` r

write.csv(biophys_sdr, "biophys_sdr.csv")
```

The available biophysical tables loaded in the package are:

| package data | Explanation |
|:---|:---|
| `biophys_pol` | Pollinator abundance biophysical table |
| `guild_table` | Pollinator abundance bee guild table |
| `biophys_swy` | Seasonal water yield (groundwater recharge) biophysical table |
| `biophys_sdr` | Sediment delivery ratio (sediment runoff) biophysical table |
| `biophys_ndr` | Nutrient delivery ratio (nutrient runoff) biophysical table |

### Field and wildflower strip delineation

The package also includes functions to build wildflower strips around
management units defined by the [crop sequence
boundary](https://www.nass.usda.gov/Research_and_Science/Crop-Sequence-Boundaries/index.php)
dataset (Hunt et al. 2024). The steps for preparing the field and
wildflower strip data are as follows:

#### 1. Query crop sequence boundary for management units

Management units within a watershed can be extracted from the large crop
sequence boundary (CSB) dataset using the `query_cropbdry` function.
This requires loading the watershed polygon first and directing the
function to the local filepath for the crop sequence boundary dataset.

``` r
watershed <- sf::st_read("path/to/waterhshed.gpkg")
selected_mgmt_units <- query_cropbdry(watershed, "path/to/crop_sequence_boundary_dataset")
```

#### 2. Add management units to the cropland data layer raster

The extracted management unit polygons are added to the [cropland data
layer](https://www.nass.usda.gov/Research_and_Science/Cropland/SARS1a.php)
(CDL) coverage of the waterhsed using the function `make_fields`.

``` r
datadir <- paste0(testthat::test_path(),"/testdata/")      # use test data as example

# load data from datadir
cdl <- terra::rast(paste0(datadir, "cdl_hu010700060102.tif"))
selected_mgmt_units <- sf::st_read(
  paste0(datadir, "csbtest.gpkg")                          # preloaded boundary data
  )
#> Reading layer `csbtest' from data source 
#>   `/Users/kevinl/Documents/GitHub/landscape-complexity-data/tests/testthat/testdata/csbtest.gpkg' 
#>   using driver `GPKG'
#> Simple feature collection with 169 features and 21 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 1938522 ymin: 2506749 xmax: 1950886 ymax: 2517195
#> Projected CRS: Albers_Conic_Equal_Area
```

``` r

cdl_fields <- make_fields(fields.poly=selected_mgmt_units, # queried management units
                          field.col="R22",                 # CSB column indicating desired year, e.g. 2022
                          cdl.rast=cdl                     # CDL object
                          )
```

#### 3. Delineate field margins around management units

The function `make_fieldmargins` delineates the margins around each
field. It attempts to avoid double counting field edges by adding
margins iteratively, only adding margins to one field at a time and
skipping over field edges that have been previously filled. The output
is a raster of only field margins.

``` r
margins <- make_fieldmargins(
  field.id.rast=cdl_fields$id,       # field id layer from `make_fields` output
  field.crop.rast = cdl_fields$crop  # crop type layer from `make_fields` output
  )
#>   |                                                                              |                                                                      |   0%  |                                                                              |                                                                      |   1%  |                                                                              |=                                                                     |   1%  |                                                                              |=                                                                     |   2%  |                                                                              |==                                                                    |   2%  |                                                                              |==                                                                    |   3%  |                                                                              |==                                                                    |   4%  |                                                                              |===                                                                   |   4%  |                                                                              |===                                                                   |   5%  |                                                                              |====                                                                  |   5%  |                                                                              |====                                                                  |   6%  |                                                                              |=====                                                                 |   7%  |                                                                              |=====                                                                 |   8%  |                                                                              |======                                                                |   8%  |                                                                              |======                                                                |   9%  |                                                                              |=======                                                               |   9%  |                                                                              |=======                                                               |  10%  |                                                                              |=======                                                               |  11%  |                                                                              |========                                                              |  11%  |                                                                              |========                                                              |  12%  |                                                                              |=========                                                             |  12%  |                                                                              |=========                                                             |  13%  |                                                                              |==========                                                            |  14%  |                                                                              |==========                                                            |  15%  |                                                                              |===========                                                           |  15%  |                                                                              |===========                                                           |  16%  |                                                                              |============                                                          |  17%  |                                                                              |============                                                          |  18%  |                                                                              |=============                                                         |  18%  |                                                                              |=============                                                         |  19%  |                                                                              |==============                                                        |  20%  |                                                                              |==============                                                        |  21%  |                                                                              |===============                                                       |  21%  |                                                                              |===============                                                       |  22%  |                                                                              |================                                                      |  22%  |                                                                              |================                                                      |  23%  |                                                                              |=================                                                     |  24%  |                                                                              |=================                                                     |  25%  |                                                                              |==================                                                    |  25%  |                                                                              |==================                                                    |  26%  |                                                                              |===================                                                   |  27%  |                                                                              |===================                                                   |  28%  |                                                                              |====================                                                  |  28%  |                                                                              |====================                                                  |  29%  |                                                                              |=====================                                                 |  30%  |                                                                              |======================                                                |  31%  |                                                                              |======================                                                |  32%  |                                                                              |=======================                                               |  33%  |                                                                              |========================                                              |  34%  |                                                                              |========================                                              |  35%  |                                                                              |=========================                                             |  36%  |                                                                              |==========================                                            |  37%  |                                                                              |===========================                                           |  38%  |                                                                              |===========================                                           |  39%  |                                                                              |============================                                          |  40%  |                                                                              |=============================                                         |  41%  |                                                                              |=============================                                         |  42%  |                                                                              |==============================                                        |  43%  |                                                                              |===============================                                       |  44%  |                                                                              |===============================                                       |  45%  |                                                                              |================================                                      |  46%  |                                                                              |=================================                                     |  47%  |                                                                              |==================================                                    |  48%  |                                                                              |==================================                                    |  49%  |                                                                              |===================================                                   |  50%  |                                                                              |====================================                                  |  51%  |                                                                              |====================================                                  |  52%  |                                                                              |=====================================                                 |  53%  |                                                                              |======================================                                |  54%  |                                                                              |=======================================                               |  55%  |                                                                              |=======================================                               |  56%  |                                                                              |========================================                              |  57%  |                                                                              |=========================================                             |  58%  |                                                                              |=========================================                             |  59%  |                                                                              |==========================================                            |  60%  |                                                                              |===========================================                           |  61%  |                                                                              |===========================================                           |  62%  |                                                                              |============================================                          |  63%  |                                                                              |=============================================                         |  64%  |                                                                              |==============================================                        |  65%  |                                                                              |==============================================                        |  66%  |                                                                              |===============================================                       |  67%  |                                                                              |================================================                      |  68%  |                                                                              |================================================                      |  69%  |                                                                              |=================================================                     |  70%  |                                                                              |==================================================                    |  71%  |                                                                              |==================================================                    |  72%  |                                                                              |===================================================                   |  72%  |                                                                              |===================================================                   |  73%  |                                                                              |====================================================                  |  74%  |                                                                              |====================================================                  |  75%  |                                                                              |=====================================================                 |  75%  |                                                                              |=====================================================                 |  76%  |                                                                              |======================================================                |  77%  |                                                                              |======================================================                |  78%  |                                                                              |=======================================================               |  78%  |                                                                              |=======================================================               |  79%  |                                                                              |========================================================              |  79%  |                                                                              |========================================================              |  80%  |                                                                              |=========================================================             |  81%  |                                                                              |=========================================================             |  82%  |                                                                              |==========================================================            |  82%  |                                                                              |==========================================================            |  83%  |                                                                              |===========================================================           |  84%  |                                                                              |===========================================================           |  85%  |                                                                              |============================================================          |  85%  |                                                                              |============================================================          |  86%  |                                                                              |=============================================================         |  87%  |                                                                              |=============================================================         |  88%  |                                                                              |==============================================================        |  88%  |                                                                              |==============================================================        |  89%  |                                                                              |===============================================================       |  89%  |                                                                              |===============================================================       |  90%  |                                                                              |===============================================================       |  91%  |                                                                              |================================================================      |  91%  |                                                                              |================================================================      |  92%  |                                                                              |=================================================================     |  92%  |                                                                              |=================================================================     |  93%  |                                                                              |==================================================================    |  94%  |                                                                              |==================================================================    |  95%  |                                                                              |===================================================================   |  95%  |                                                                              |===================================================================   |  96%  |                                                                              |====================================================================  |  96%  |                                                                              |====================================================================  |  97%  |                                                                              |====================================================================  |  98%  |                                                                              |===================================================================== |  98%  |                                                                              |===================================================================== |  99%  |                                                                              |======================================================================|  99%  |                                                                              |======================================================================| 100%
```

#### 4. Add field margins to the CDL layer

Use the function `add_margins_cdl` to re-classify field margin cells in
a clean CDL layer to pollinator habitat (cell value = 171). The clean
CDL layer is produced by the `make_fields` function (as a layer of the
raster “cdl_fields”).

``` r
margin.lc <- 171                  # define margin land cover as 171

fieldmargins <- add_margins_cdl(margin.lc = 171,
                                margin.rast = margins$field_id, 
                                cdl.rast = cdl_fields$cdl.clean)
```
