#/usr/bin/env bash
# 
# Import ASO SWE tifs and make sure they are in EPSG:4269
#
# Script assumes:
# * Import a file to the database if given one argument
#   Example: 005-aso_import.sh path/to/aso.vrt
# * Convert a raw ASO file and import to the database if given a second argument
#   Example: 005-aso_import.sh path/to/aso.vrt path/to/aso.tif
set -e

if [ ! -z ${2} ]; then

  # Remove old file if present
  if [ -f ${1} ]; then
    rm ${1}
  fi

  gdalwarp -t_srs EPSG:4269 ${2} ${1}
fi

# Import the entire raster into the database
# Note the -x option that does not add a max extent contraint to the table
raster2pgsql -I -C -M -x -F -Y -t 32x32 \
    $(realpath ${1}) aso | \
    psql -U oper -h mujeres -d swe_data

# Add date column with index based on filenames
psql -U oper -h mujeres -d swe_data -f 005-update_aso.sql
