DROP FUNCTION IF EXISTS public.aso_swe_for_zone_and_date;
CREATE FUNCTION public.aso_swe_for_zone_and_date(zone_name TEXT, target_date TEXT)
 RETURNS TABLE(swe double precision, raster_center geometry)
 LANGUAGE sql
AS $function$
    WITH cbrfc_zone AS (
        select geom, buffered_envelope from public.cbrfc_zone_buffer(zone_name)
    ),
    aso_pixels AS (
        SELECT (ST_PixelAsCentroids(
            ST_CLIP(
                aso.rast,
                cbrfc_zone.buffered_envelope,
                true
            )
        )).*
        FROM aso, cbrfc_zone
        WHERE aso.swe_date = TO_DATE(target_date, 'YYYY-MM-DD') 
        AND ST_Intersects(aso.rast, cbrfc_zone.buffered_envelope)
        
    )
    SELECT aso_pixels.val, aso_pixels.geom
    FROM aso_pixels, cbrfc_zone
    WHERE ST_WITHIN(aso_pixels.geom, cbrfc_zone.geom)
$function$
;

-- Function to average ASO SWE into an areal mean
-- ASO values are in meters
DROP FUNCTION IF EXISTS public.aso_areal_swe_for_date;
CREATE FUNCTION public.aso_areal_swe_for_date(zone_name TEXT, target_date TEXT)
  RETURNS TABLE (aso_swe double precision)
  LANGUAGE SQL
AS $function$
  SELECT avg(zone_data.swe)
  FROM public.aso_swe_for_zone_and_date(zone_name, target_date) as zone_data
$function$
;