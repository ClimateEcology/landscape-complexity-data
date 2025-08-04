#' Make field sections
#'
#' @param field.poly a single field (sf object)
#' @param section.size field margin section size
#' @param simplify.param parameter for simplifying field polygon in intermediate
#'   step. Default is 100.
#'
#' @return an sf object
#' @export
#'
make_fieldsections <- function(field.poly, section.size, simplify.param=100){
  field.simple <- try(sf::st_simplify(field.poly, dTolerance = simplify.param))

  new.param <- simplify.param
  while(inherits(field.simple, "try-error")|st_is_empty(field.simple)){
    new.param <- new.param*.5
    field.simple <- try(sf::st_simplify(field.poly, dTolerance = new.param))
  }

  margin.line <- sf::st_cast(sf::st_as_sfc(field.simple), "MULTILINESTRING") %>%
    sf::st_cast("LINESTRING")
  section.pts <- sf::st_line_sample(margin.line, density = 1/section.size)

  field.voronoi <- sf::st_intersection(
    sf::st_cast(sf::st_voronoi(section.pts)) %>% st_buffer(0.0),
    field.poly
    ) %>% st_as_sf() %>% st_buffer(0.0)

  # if the new field voronoi cuts out part of the original field, adjust simplification tolerance
  while(!isTRUE(all.equal(st_area(st_union(field.voronoi)), st_area(field.poly)))){
    new.param <- new.param*.5
    field.simple <- try(sf::st_simplify(field.poly, dTolerance = new.param))

    margin.line <- sf::st_cast(sf::st_as_sfc(field.simple), "MULTILINESTRING") %>%
      sf::st_cast("LINESTRING")
    section.pts <- sf::st_line_sample(margin.line, density = 1/section.size)

    field.voronoi <- sf::st_intersection(
      sf::st_cast(sf::st_voronoi(section.pts)) %>% st_buffer(0.0),
      field.poly
      ) %>% st_as_sf() %>% st_buffer(0.0)
  }

  return(field.voronoi)
}
