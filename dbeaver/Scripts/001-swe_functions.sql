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
DROP FUNCTION IF EXISTS public.swe_from_product_for_zone_and_date;
CREATE FUNCTION public.swe_from_product_for_zone_and_date(product TEXT, zone_name TEXT, target_date TEXT)
 RETURNS TABLE(swe double precision, raster_center geometry)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY EXECUTE FORMAT(
        'WITH cbrfc_zone AS (
            select geom, buffered_envelope from public.cbrfc_zone_buffer($1)
        ),
        product_pixels AS (
            SELECT (ST_PixelAsCentroids(
                ST_CLIP(
                    %I.rast,
                    cbrfc_zone.buffered_envelope,
                    true
                )
            )).*
            FROM %I, cbrfc_zone
            WHERE %I.swe_date = TO_DATE($2, ''YYYY-MM-DD'') 
            AND ST_Intersects(%I.rast, cbrfc_zone.buffered_envelope)
        )
        SELECT product_pixels.val, product_pixels.geom
        FROM product_pixels, cbrfc_zone
        WHERE ST_WITHIN(product_pixels.geom, cbrfc_zone.geom)',
        product, product, product, product
    ) USING zone_name, target_date;
END
$function$
;