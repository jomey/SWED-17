#!/usr/bin/env bash
#
# Script assumes:
# * Import a file to the database if given one argument
#   Example: 004-sondas-convert.sh path/to/snodas.tif
# * Convert a raw snodas file and import to the database if given a second argument
#   Example: 004-sondas-convert.sh path/to/snodas.tif path/to/snodas.dat

if [ ! -z ${2} ] && [ -f ${1} ]; then
  # Remove old file
  rm ${1}

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

fi

# Import metadata to database
# This links to the actual file on disk
raster2pgsql -I -C -M -F -R -Y -s 4269 -F -t 32x32 \
    $(realpath ${1}) snodas | \
    psql -U oper -h mujeres -d swe_data

# Add date column with index based on filenames
psql -U oper -h mujeres -d swe_data -f 004-update_snodas.sql

