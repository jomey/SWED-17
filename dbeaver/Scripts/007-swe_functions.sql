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
