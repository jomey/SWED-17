-- UA SWE views
DO $$
DECLARE
    cbrfc_zone record;
BEGIN
    FOR cbrfc_zone IN 
        SELECT czu.zone AS name 
        FROM cbrfc_zones_uc czu 
        WHERE czu.zone LIKE 'ALEC2%'
    LOOP 
        RAISE NOTICE 'Creating view for zone %', cbrfc_zone.name;
        EXECUTE FORMAT(
            'Create or replace view public.%I AS SELECT * FROM mask_for_zone(%L)',
            cbrfc_zone.name, cbrfc_zone.name
        );
    END LOOP;
END; 
$$

-- CU Boulder SWE views
CREATE OR REPLACE VIEW public.CUB_ALEC2HLF AS (
    SELECT ROW_NUMBER() OVER () AS ID, swe, raster_center
    FROM cu_swe_for_zone_and_date('ALEC2HLF', '2023-04-01') AS cu_swe
)
