-- Add date column and index
ALTER TABLE ua_1km ADD swe_date date;
UPDATE ua_1km SET swe_date =  to_date(split_part(filename, '_', 1), 'YYYYMMDD'); 
CREATE INDEX ON ua_1km(swe_date);

VACUUM FULL ua_1km;
