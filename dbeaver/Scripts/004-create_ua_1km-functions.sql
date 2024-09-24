DROP FUNCTION IF EXISTS public.ua_1km_swe_for_zone_and_date;
CREATE FUNCTION public.ua_1km_swe_for_zone_and_date(zone_name TEXT, target_date TEXT)
 RETURNS TABLE(swe double precision, raster_center geometry)
 LANGUAGE sql
AS $function$
    WITH cbrfc_zone AS (
        select geom, buffered_envelope from public.cbrfc_zone_buffer(zone_name)
    ),
    ua_1km_pixels AS (
        SELECT (ST_PixelAsCentroids(
            ST_CLIP(
                ua_1km.rast,
                cbrfc_zone.buffered_envelope,
                true
            )
        )).*
        FROM ua_1km, cbrfc_zone
        WHERE ua_1km.swe_date = TO_DATE(target_date, 'YYYY-MM-DD') 
        AND ST_Intersects(ua_1km.rast, cbrfc_zone.buffered_envelope)
        
    )
    SELECT ua_1km_pixels.val, ua_1km_pixels.geom
    FROM ua_1km_pixels, cbrfc_zone
    WHERE ST_WITHIN(ua_1km_pixels.geom, cbrfc_zone.geom)
$function$
;

-- Function to average UA SWE into an areal mean
-- UA SWE values are in mm
DROP FUNCTION IF EXISTS public.ua_1km_areal_swe_for_date;
CREATE FUNCTION public.ua_1km_areal_swe_for_date(zone_name TEXT, target_date TEXT)
  RETURNS TABLE (ua_1km_swe double precision)
  LANGUAGE SQL
AS $function$
  SELECT avg(zone_data.swe)
  FROM public.ua_1km_swe_for_zone_and_date(zone_name, target_date) as zone_data
$function$
;