#/usr/bin/env bash
#
# Import snow.nc file from iSnobal
#
# Script assumes:
# * Import a file to the database if given one argument
#   Example: 006-isnobal.sh path/to/snow.tif
# * Convert iSnobal snow.nc and import to the database if given a second argument
#   Example: 006-isnobal.sh path/to/snow.tif NETCDF:"data/20230401_iSnobal_ERW_snow.nc":specific_mass
set -e

if [ ! -z ${2} ]; then

  # Remove old file if present
  if [ -f ${1} ]; then
    rm ${1}
  fi

gdalwarp -t_srs EPSG:4269 \
    -co TILED=YES \
    -co COMPRESS=ZSTD \
    -co PREDICTOR=2 \
    -co NUM_THREADS=ALL_CPUS \
    ${2} ${1}

fi

# Import the entire raster into the database
# Note the -x option that does not add a max extent contraint to the table
raster2pgsql -I -C -M -x -d -F -Y -t 32x32 \
    $(realpath ${1}) isnobal | \
    psql -U oper -h mujeres -d swe_data

# Add date column with index based on filenames and link to cbrfc zones
psql -U oper -h mujeres -d swe_data -f 006-update_isnobal.sql
