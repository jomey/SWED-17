-- Add date column and index
ALTER TABLE snodas ADD swe_date date;
UPDATE snodas SET swe_date =  to_date(split_part(filename, '_', 1), 'YYYYMMDD'); 
CREATE INDEX ON snodas(swe_date);
