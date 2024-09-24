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

-- UA SWE 4km views
DROP VIEW public.UA_4k_ALEC2HMF;
CREATE OR REPLACE VIEW public.UA_4k_ALEC2HLF AS (
    SELECT ROW_NUMBER() OVER () AS ID, swe, raster_center
    FROM ua_4k_mask_for_zone('ALEC2HLF') AS ua_swe
);

-- CU Boulder SWE views
CREATE OR REPLACE VIEW public.CUB_ALEC2HLF AS (
    SELECT ROW_NUMBER() OVER () AS ID, swe, raster_center
    FROM cu_swe_for_zone_and_date('ALEC2HLF', '2023-04-01') AS cu_swe
);

-- SNODAS SWE views
CREATE OR REPLACE VIEW public.SNODAS_ALEC2HLF AS (
    SELECT ROW_NUMBER() OVER () AS ID, swe, raster_center
    FROM snodas_swe_for_zone_and_date ('ALEC2HLF', '2023-04-01') AS cu_swe
);

-- ASO SWE view
CREATE OR REPLACE VIEW public.ASO_ALEC2HLF AS (
    SELECT ROW_NUMBER() OVER () AS ID, swe, raster_center
    FROM aso_swe_for_zone_and_date ('ALEC2HLF', '2023-04-01') AS cu_swe
);

-- UA 1km SWE view
CREATE OR REPLACE VIEW public.UA_1KM_ALEC2HLF AS (
    SELECT ROW_NUMBER() OVER () AS ID, swe, raster_center
    FROM ua_1km_swe_for_zone_and_date ('ALEC2HLF', '2023-04-01') AS cu_swe
);