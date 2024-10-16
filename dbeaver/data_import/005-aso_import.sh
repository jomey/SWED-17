#/usr/bin/env bash
# 
# Import ASO SWE tifs
#
# Arguments:
#   -s: Path to file to import
#   -c Create table and import records
#   -a Append records to table (Default)
#   -d: Name of DB source file to use as temporary staging file
#       Required pattern: YYYYMMDD_file_name
# Example call
#   aso_import.sh -s data/ASO_SWE.tif -d data/20240101_SWE
#
# NOTE:
#   The DB source file is only temporary as the whole raster is imported
set -e

source import_script_options.sh

TABLE='aso'

# NOTE: This will update the $DB_FILE variable
source ./convert_to_db_tif.sh ${DB_FILE} ${SOURCE_FILE}

if [[ "$IMPORT_MODE" == "$APPEND_RECORDS" ]]; then
    POST_STEP="-p 005-update_aso_records.sql"
elif [[ "$IMPORT_MODE" == "$CREATE_TABLE" ]]; then
    POST_STEP="-p 005-update_aso_table.sql"
fi

./import_to_db.sh \
  -f ${DB_FILE} -t ${TABLE} \
  ${IMPORT_MODE} ${POST_STEP}
