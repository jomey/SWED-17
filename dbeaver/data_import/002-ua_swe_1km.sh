#!/usr/bin/env bash
#
# Import University of Arizona SWE 1km SWE
set -e

# Convert to EPSG:4269
gdalwarp -overwrite -t_srs EPSG:4269 ${1} ${1/.tif/.vrt}

# Convert to tiled tif
gdal_translate -co TILED=YES -co COMPRESS=ZSTD -co PREDICTOR=2 -co NUM_THREADS=ALL_CPUS \
    ${1/.tif/.vrt} ${1/.tif/_db.tif}

# Import metadata to database
raster2pgsql -I -C -x -M -F -R -s 4269 -F -t 32x32 \
    $(realpath ${1/.tif/_db.tif}) ua_1km | \
    psql -h mujeres -U oper -d swe_data

# Add date column with index based on filenames
psql -U oper -h mujeres -d swe_data -f 002-update_ua_1km.sql
