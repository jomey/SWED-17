-- Add date column and index
ALTER TABLE cu_boulder ADD swe_date date;
UPDATE cu_boulder SET swe_date =  to_date(split_part(filename, '_', 2), 'YYYYMMDD'); 
CREATE INDEX ON cu_boulder(swe_date);
