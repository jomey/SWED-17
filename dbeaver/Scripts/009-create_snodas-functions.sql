DROP FUNCTION IF EXISTS public.snodas_swe_for_zone_and_date;
CREATE FUNCTION public.snodas_swe_for_zone_and_date(zone_name TEXT, target_date TEXT)
 RETURNS TABLE(swe double precision, raster_center geometry)
 LANGUAGE sql
AS $function$
    WITH cbrfc_zone AS (
        select geom, buffered_envelope from public.cbrfc_zone_buffer(zone_name)
    ),
    snodas_pixels AS (
        SELECT (ST_PixelAsCentroids(
            ST_CLIP(
                snd.rast,
                cbrfc_zone.buffered_envelope,
                true
            )
        )).*
        FROM snodas snd, cbrfc_zone
        WHERE snd.swe_date = TO_DATE(target_date, 'YYYY-MM-DD') AND
              ST_Intersects(snd.rast, cbrfc_zone.buffered_envelope)
    )
    SELECT snodas_pixels.val, snodas_pixels.geom
    FROM snodas_pixels, cbrfc_zone
    WHERE ST_WITHIN(snodas_pixels.geom, cbrfc_zone.geom)
$function$
;

-- Function to average SNODAS SWE into an areal mean
-- SNODAS values are in mm
DROP FUNCTION IF EXISTS public.snodas_areal_swe_for_date;
CREATE FUNCTION public.snodas_areal_swe_for_date(zone_name TEXT, target_date TEXT)
  RETURNS TABLE (snodas_swe double precision)
  LANGUAGE SQL
AS $function$
  SELECT avg(zone_data.swe)
  FROM public.snodas_swe_for_zone_and_date(zone_name, target_date) as zone_data
$function$
;