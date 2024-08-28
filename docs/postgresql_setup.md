# Install via conda
```
conda env create -n postgresql postgis
```

# Setup
## Create new cluster
Flags:
* (g) Allow user group acces
* (E) Set server and template encoding to UTF-8
* (U) Use a 'neutral' root user name
```shell
initdb -g -E utf8 -U oper -D /path/to/db_home
```

## Server config
Edit file `postgresql.conf` inside the DB home directory

### Allow connections from outside
```
listen_addresses = '*'
```

### Activate all GDAL drivers
Add new section at the bottom of the file
```
postgis.gdal_enabled_drivers = 'ENABLE_ALL'
postgis.enable_outdb_raster = 1
```

#### Verify
After server start with a SQL console:
```sql
SELECT short_name, long_name, can_write
FROM st_gdaldrivers()
ORDER BY short_name;
```

### Set server timezone to UTC
```
timezone = 'UTC'
datestyle = 'iso, ymd'
```

### To allow connections outside of 'localhost'
Edit `pg_hba.conf` and add allowed IP address

## After starting the server
### Activate postgis and raster extensions on new DB
In a SQL console
```sql
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;
```

## Reads
https://wiki.postgresql.org/wiki/Don't_Do_This

# Data management
## Sample import of NetCDF
Options from:
https://postgis.net/docs/using_raster_dataman.html
`I` -> Create index
`l` -> Overviews

```shell
raster2pgsql -I -C -e -Y -l 2 -s 4269 -F -t 32x32 NETCDF:"4km_SWE_Depth_WY1982_v01.nc":SWE wy_1982 | psql -h honduras -d swannData
```

## Sample import of Shapefile
https://postgis.net/docs/using_postgis_dbmanagement.html#shp2pgsql_usage
```shell
shp2pgsql -c -s 4269 -i -I CBRFC_Zones_UC.shp CBRFC_Zones_UC | psql -h honduras -d swannData
```

# Reads
https://www.crunchydata.com/blog/postgres-raster-query-basics