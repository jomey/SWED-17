#!/usr/bin/env bash
# Import the Upper/Lower CRB and GSL zone shapefiles

shp2pgsql -c -s 4269 -i -I CBRFC_Zones_UC.shp CBRFC_Zones_UC | \
    psql -U oper -h honduras -d swe_data
shp2pgsql -c -s 4269 -i -I CBRFC_Zones_LC.shp CBRFC_Zones_LC | \
    psql -U oper -h honduras -d swe_data
shp2pgsql -c -s 4269 -i -I CBRFC_Zones_GSL.shp CBRFC_Zones_GSL | \
    psql -U oper -h honduras -d swe_data
