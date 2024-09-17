#!/usr/bin/env bash

# Convert to tiled raster
gdal_translate -co TILED=YES -co COMPRESS=ZTD -co PREDICTOR=2 -co NUM_THREADS=ALL_CPUS \
    ${1} ${1/.tif/_db.tif}

# Import metadata to database
raster2pgsql -I -C -M -F -R -Y -s 4269 -F -t 32x32 \
    ${1/.tif/_db.tif} cu_boulder | \
    psql -U oper -h mujeres -d swe_data

# Add date column with index based on filenames
psql -U oper -h mujeres -d swe_data -f 003-update_cu_boulder.sql
