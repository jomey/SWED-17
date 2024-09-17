#!/usr/bin/env bash

if [ -f ${2} ]; then
  rm ${2}
fi

## GeoTIFF
gdal_translate \
  -of GTiff \
  -a_srs EPSG:4326 \
  -a_ullr -124.73333333333333 52.87500000000000 -66.94166666666667 24.95000000000000 \
  -a_nodata -9999 \
  -co TILED=YES \
  -co COMPRESS=ZSTD \
  -co PREDICTOR=2 \
  -co NUM_THREADS=ALL_CPUS \
  ${1} ${2}

## NetCDF
# gdal_translate \
#   -of NetCDF \
#   -a_srs EPSG:4326 \
#   -a_ullr -124.73333333333333 52.87500000000000 -66.94166666666667 24.95000000000000 \
#   -a_nodata -9999 \
#   -co FORMAT=NC4C \
#   -co COMPRESS=DEFLATE \
#   ${1} ${2}

# Import metadata to database
raster2pgsql -I -C -M -F -R -Y -s 4269 -F -t 32x32 \
    ${2} snodas | \
    psql -U oper -h mujeres -d swe_data

# Add date column with index based on filenames
psql -U oper -h mujeres -d swe_data -f 004-update_snodas.sql

