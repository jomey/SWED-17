import pandas as pd
from .swe_db import SweDB


class Swe:
    """
    Zonal SWE dataframe
    """
    INCH_TO_MM = 25.4
    SWE_COLUMN = 'SWE (in)'
    SWE_COLUMN_MM = 'SWE (mm)'
    COLUMN_MAPPING = ['Zone Name', 'Year', 'Month', 'Day', SWE_COLUMN]

    def __init__(
        self, db_handler: SweDB, model_segment: str, zone_name: str = None
    ):
        self._df = db_handler.zone_data(segid=model_segment, opid=zone_name)
        self._df.columns = self.COLUMN_MAPPING
        self.create_time_index()
        self.swe_to_mm()

    @property
    def dataframe(self) -> pd.DataFrame:
        """
        Dataframe getter

        Returns
        -------
        pd.DataFrame
        """
        return self._df

    def create_time_index(self) -> None:
        """
        Concatenate the date columns (year, month, day) and set as index on
        the dataframe.
        """
        self._df['Date'] = pd.to_datetime(self._df[['Year', 'Month', 'Day']])
        self._df = self._df.drop(columns=['Year', 'Month', 'Day'])
        self._df = self._df.set_index('Date')

    def swe_to_mm(self) -> None:
        """
        Convert SWE column to mm and rename in the dataframe
        """
        self._df[self.SWE_COLUMN] *= self.INCH_TO_MM
        self._df = self._df.rename(
            columns={self.SWE_COLUMN: self.SWE_COLUMN_MM}
        )
