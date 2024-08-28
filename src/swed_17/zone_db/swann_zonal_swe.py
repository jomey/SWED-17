import datetime
import pandas as pd

from sqlalchemy import create_engine, text
from dataclasses import dataclass

from .base import Base


@dataclass
class SWANNZonalSWERow:
    z_date: datetime.date
    swe: float


class SWANNZonalSWE(Base):
    QUERY = "SELECT szs.z_date, szs.swe " \
            "FROM swann_zonal_swe szs " \
            "WHERE szs.cbrfc_zone_id = :zone_id"

    def for_zone(self, zone_id: int) -> pd.DataFrame:
        engine = create_engine(self.pd_connection_info())
        with engine.connect() as connection:
            return pd.read_sql_query(
                text(self.QUERY),
                connection,
                params={'zone_id': zone_id},
                index_col='z_date',
                parse_dates=['z_date']
            )
