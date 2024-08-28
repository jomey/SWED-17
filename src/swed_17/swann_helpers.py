import pandas as pd
import xarray as xr

from .zone_db import CBRFCZone
from .zone_raster import ZoneRaster


SWANN_SUFFIX = '_SWANN'


def swann_data_for_zone(
        swann_files: xr.Dataset, zone_name: str, zone_db: CBRFCZone
) -> xr.DataArray:
    """
    Retrieve the data for requested zone from given SWANN files and calculate
    daily means.

    This uses the database to get the CBRFC zone mask and then applies
    it to the files as a mask.

    Parameters
    ----------
    swann_files : xr.Dataset
        Xarray Dataset with all SWE files to extract data from
    zone_name : str
        CBRFC zone to get data for
    zone_db : CBRFCZone
        Instance that holds the database connection

    Returns
    -------
    xr.DataArray
        Results as xarray DataArray.
    """
    zone_mask = zone_db.as_rio(zone_name)
    swann_xr = swann_files.sel(
        ZoneRaster.bounding_box(zone_mask)
    )

    # Apply mask as new coordinate
    swann_xr.coords['mask'] = (
        ('lat', 'lon'), ZoneRaster.data_as_xr(zone_mask)
    )

    return swann_xr.where(swann_xr.mask == 1).mean(['lat', 'lon']).compute()


def swann_swe_for_zone(
        swann_xr: xr.Dataset, zone_name: str, zone_db: CBRFCZone
) -> pd.DataFrame:
    """Get SWE data from SWANN xarray dataset and return as dataframe.

    Uses the :meth:`swann_data_for_zone` to retrieve SWANN data.

    Parameters
    ----------
    swann_xr : xr.Dataset
        Dataset with all SWANN files
    zone_name : str
        Zone name to extract data for.
    zone_db : ZoneDB
        Connection object to the database

    Returns
    -------
    pd.DataFrame
        Dataframe with dates of peak SWE by year.
    """
    zone_df = swann_data_for_zone(
        swann_xr, zone_name, zone_db
    ).SWE.to_dataframe()

    zone_df = zone_df.rename(columns={'SWE': zone_name + SWANN_SUFFIX})
    # Pandas uses a time index that accounts for nano-leapseconds
    # Rounding to the nearest day.
    zone_df.index = zone_df.index.round('D')

    return zone_df
