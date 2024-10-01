#!/usr/bin/env bash
set -e

# Convert to EPSG:4269
gdalwarp -overwrite -t_srs EPSG:4269 ${1} ${1/.tif/.vrt}

# Convert to tiled tif
gdal_translate -co TILED=YES -co COMPRESS=ZSTD -co PREDICTOR=2 -co NUM_THREADS=ALL_CPUS \
    ${1/.tif/.vrt} ${1/.tif/_db.tif}

# Import metadata to database
raster2pgsql -d -I -C -x -M -F -R -s 4269 -F -t 32x32 \
    $(realpath ${1/.tif/_db.tif}) cu_boulder | \
    psql -U oper -h mujeres -d swe_data

# Add date column with index based on filenames
psql -U oper -h mujeres -d swe_data -f 003-update_cu_boulder.sql
