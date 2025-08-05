
# landscape-complexity-data

<!-- badges: start -->
<!-- badges: end -->

The GitHub repository landscape-complexity-data supports the publication "Benefits of wildflower strips in agricultural field margins differ based on landscape complexity across four ecosystem services," published in _Landscape Ecology_.

The repository is structured as an R package. The "data-raw/" folder contains the underlying data and code used to build the biophysical tables for the study's ecosystem service models. Essential functions for processing the raw data are stored in the folder “R/”. These functions are loaded as part of the package. The package can be loaded by ensuring the working directory is the repository folder (e.g., by opening the .Rproj file with Rstudio) and then running `devtools::load_all()`. You can also install the development version of landscape-complexity-data from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ClimateEcology/landscape-complexity-data")
```

### Writing biophys tables

The biophysical tables are loaded as part of the package. These can be written to a csv file as follows:

```r
library(landscape-complexity-data)

write.csv(biophys_sdr, "biophys_sdr.csv")
```

The available biophysical tables loaded in the package are:

|package data | Explanation |
|:-------------|:-------------|
|`biophys_pol`|Pollinator abundance biophysical table |
|`guild_table`|Pollinator abundance bee guild table |
|`biophys_swy`|Seasonal water yield (groundwater recharge) biophysical table |
|`biophys_sdr`|Sediment delivery ratio (sediment runoff) biophysical table |
|`biophys_ndr`|Nutrient delivery ratio (nutrient runoff) biophysical table |

### Field and wildflower strip delineation

The package also includes functions to build wildflower strips around management units defined by the [crop sequence boundary](https://www.nass.usda.gov/Research_and_Science/Crop-Sequence-Boundaries/index.php) dataset (Hunt et al. 2024). The steps for preparing the field and wildflower strip data are as follows:

#### 1. Query crop sequence boundary for management units

Management units within a watershed can be extracted from the large crop sequence boundary (CSB) dataset using the `query_cropbdry` function. This requires loading the watershed polygon first and directing the function to the local filepath for the crop sequence boundary dataset.

``` r
watershed <- sf::st_read("path/to/waterhshed.gpkg")
selected_mgmt_units <- query_cropbdry(watershed, "path/to/crop_sequence_boundary_dataset")
```

#### 2. Add management units to the cropland data layer raster

The extracted management unit polygons are added to the [cropland data layer](https://www.nass.usda.gov/Research_and_Science/Cropland/SARS1a.php) (CDL) coverage of the waterhsed using the function `make_fields`.

```r
cdl <- terra::rast("path/to/cdl.tif")
cdl_fields <- make_fields(fields.poly=selected_mgmt_units, # queried management units from 1.
                          field.col="R22",                 # CSB column indicating desired year, e.g. 2022
                          cdl.rast=cdl                     # CDL object
                          )
```

#### 3. Delineate field margins around management units

The function `make_fieldmargins` delineates the margins around each field. It attempts to avoid double counting field edges by adding margins iteratively, only adding margins to one field at a time and skipping over field edges that have been previously filled.

```r
margins <- make_fieldmargins(field.id.rast=fields.i$id,       # field id layer from `make_fields` output
                             field.crop.rast = fields.i$crop  # crop type layer from `make_fields` output
                             )
```
