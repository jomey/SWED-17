-- Update table structure, add SWE date, and link with CBRFC zone
ALTER TABLE aso 
    ADD swe_date date,
    ADD ch5_id integer,
    ADD CONSTRAINT cbrfc_ch5id_fk FOREIGN KEY (ch5_id) REFERENCES cbrfc_ch5id(id);

UPDATE aso SET swe_date =  to_date(split_part(filename, '_', 1), 'YYYYMMDD');

CREATE INDEX ON aso(swe_date);
CREATE INDEX aso_ch5id_fk_idx ON aso(ch5_id);

-- Sample update after importing data for ERW
UPDATE aso 
SET ch5_id = subquery.id
FROM (
    SELECT id FROM cbrfc_ch5id WHERE ch5_id = 'ALEC2'
) as subquery
WHERE aso.filename like '%ERW%';
