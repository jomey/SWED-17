-- CBRFC zone buffer function
-- Ensure that the perimeter of a zone is accounted for when extracting raster
-- based SWE with the ST_CLIP function
DROP FUNCTION public.cbrfc_zone_buffer;
CREATE OR REPLACE FUNCTION public.cbrfc_zone_buffer(zone_name TEXT)
  RETURNS TABLE(geom geometry, buffered_envelope geometry)
  LANGUAGE SQL
AS $function$ 
    WITH cbrfc_zone AS (
        select geom from cbrfc_zones czu where zone = zone_name
    )
    SELECT cbrfc_zone.geom, st_buffer(st_envelope(cbrfc_zone.geom), 0.05) AS buffered_geom
    FROM cbrfc_zone;
$function$;

-- Function to query a SWE product for given zone and date
-- Query steps:
--  1. Get SRID of target raster to clip from (raster_srid)
--  2. Get target CBRFC zone and transform to SRID from target raster (cbrfc_zone)
--  3. Get centroids for each raster pixel that falls within the CBRFC zone (product_pixels)
--  4. Get values for the pixels (final query)
DROP FUNCTION IF EXISTS public.swe_from_product_for_zone_and_date;
CREATE FUNCTION public.swe_from_product_for_zone_and_date(product TEXT, zone_name TEXT, target_date TEXT)
 RETURNS TABLE(swe double precision, raster_center geometry)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY EXECUTE FORMAT(
        'WITH raster_srid AS (
            SELECT ST_SRID(%1$I.rast) AS epsg FROM %1$I LIMIT 1
        ), 
        cbrfc_zone AS (
            SELECT ST_TRANSFORM(geom, raster_srid.epsg) as geom, 
                ST_TRANSFORM(buffered_envelope, raster_srid.epsg) as transform_envelope
                FROM public.cbrfc_zone_buffer($1), raster_srid
        ), 
        product_pixels AS (
            SELECT (ST_PixelAsCentroids(
                ST_CLIP(
                    %1$I.rast,
                    cbrfc_zone.transform_envelope,
                    true
                )
            )).*
            FROM %1$I, cbrfc_zone
            WHERE %1$I.swe_date = TO_DATE($2, ''YYYY-MM-DD'') 
            AND ST_Intersects(
                %1$I.rast, cbrfc_zone.transform_envelope
            )
        )
        SELECT product_pixels.val, product_pixels.geom
        FROM product_pixels, cbrfc_zone
        WHERE ST_WITHIN(
            product_pixels.geom, cbrfc_zone.geom
        )',
        product
    ) USING zone_name, target_date;
END
$function$
;