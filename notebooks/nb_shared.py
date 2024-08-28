from nb_paths import *
import os
import xarray as xr

from swed_17.nb_helpers import start_cluster
from swed_17 import ZoneCompare, ZonePlotter
from swed_17.zone_db import CBRFCZone, SWANNZonalSWE
from swed_17.snow17 import SweDB
from swed_17.peak_swe import peak_swe_for_pd, plot_peak_swe_pd, compare_peak_swe
from swed_17.swann_helpers import swann_data_for_zone, swann_swe_for_zone

# Plotting
import holoviews as hv
import hvplot.xarray
import hvplot.pandas
import matplotlib.pyplot as plt

BOKEH_OPTS = dict(
    width=900,
    height=600,
    cmap='viridis',
)

hv.plotting.bokeh.ElementPlot.active_tools = [
    'save', 'pan', 'box_zoom', 'reset'
]

# Jupyter Lab has missing PROJ envs
os.environ['PROJ_DATA'] = '/perc10/data/miniconda3/envs/snow_viz/share/proj'

# Create a nb_paths.py file that holds all directory infos
# This is not commited with the repository
# DB connection infos
#  * DB_CONNECTION_INFO (with CBRFC shapefiles and third-party SWE grids)
#  * SNOW_17_DB_CONNECTION
# SWANN files
#  * SWANN_HOME_DIR
# Output directories
#  * HTML_OUTPUT
