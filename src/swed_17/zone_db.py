import psycopg

from contextlib import contextmanager

from psycopg import Cursor
from psycopg.rows import TupleRow
from sqlalchemy import create_engine


class ZoneDB:
    """
    Base database query class.
    """

    CONNECTION_OPTIONS = dict(
        autocommit=True,
    )

    class Query:
        """
        Set of pre-defined database queries.
        """
        ZONE_AS_RASTER = "SELECT ST_AsGDALRaster(ST_Union(zone_mask.rast), 'GTiff') " \
                         "FROM zone_mask_as_raster(%(zone_name)s) AS zone_mask"

    def __init__(self, connection_info: str):
        self._connection_info = connection_info

    @contextmanager
    def query(self, query: str, params: dict = {}, row_factory={}) -> Cursor[TupleRow]:
        """
        Execute given query by passing in requested parameters.

        This uses a conextmanager to manage the DB connection and to yield
        the results as DB cursor.

        Parameters
        ----------
        query : str
            SQL query
        params : dict, optional
            Pass in query parameters if the query contains any, by default {}
        row_factory: dict, optional
            Specify the class to use to parse each result row

        Returns
        -------
        Cursor
            Cursor with result from psycopg execute().
        """
        with psycopg.connect(
            self._connection_info, **self.CONNECTION_OPTIONS
        ) as connection:
            with connection.cursor() as cursor:
                if row_factory:
                    cursor.row_factory = row_factory

                cursor.execute(query, params)
                yield cursor

