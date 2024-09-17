-- Function to extract zonal CBRFC SWE for CU Boulder SWE rasters
DROP FUNCTION public.cu_swe_for_zone_and_date;
CREATE OR REPLACE FUNCTION public.cu_swe_for_zone_and_date(zone_name TEXT, target_date TEXT)
 RETURNS TABLE(swe double precision, raster_center geometry)
 LANGUAGE sql
AS $function$
    WITH cbrfc_zone AS (
        select geom, buffered_envelope from public.cbrfc_zone_buffer(zone_name)
    ),
    cu_pixels AS (
        SELECT (ST_PixelAsCentroids(
            ST_CLIP(
                cub.rast,
                cbrfc_zone.buffered_envelope
            )
        )).*
        FROM cu_boulder cub, cbrfc_zone
        WHERE cub.swe_date = TO_DATE(target_date, 'YYYY-MM-DD')
    )
    SELECT cu_pixels.val, cu_pixels.geom
    FROM cu_pixels, cbrfc_zone
    WHERE ST_WITHIN(cu_pixels.geom, cbrfc_zone.geom)
$function$
;