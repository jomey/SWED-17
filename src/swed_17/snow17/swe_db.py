from sqlalchemy import create_engine, text
import pandas as pd


class SweDB:
    """
    Class to interact with the Snow-17 DB
    """

    class Query:
        ZONE_CALIBRATED = "SELECT opid, cal_yr, mon, zday, swe " \
                          "FROM states_snow17 " \
                          "WHERE segid = :segid"

    def __init__(self, connection_info: str) -> None:
        self._connection_info = connection_info

    def query(
        self, query: str, dataframe=True, **kwargs
    ) -> list | pd.DataFrame:
        """
        Execute a query for initialized connection string

        Parameters
        ----------
        query : str
            SQL query with optional parameters given via the kwargs
        dataframe: bool
            Return results as pandas dataframe (Default: True)

        Returns
        -------
        list or DataFrame
            Query result
        """
        engine = create_engine(self._connection_info)
        with engine.connect() as connection:
            if dataframe:
                result = pd.read_sql_query(
                    text(query), engine, params=kwargs
                )
            else:
                cursor = connection.execute(text(query), kwargs)
                result = cursor.fetchall()

        return result

    def zone_data(self, segid: str, opid: str = None) -> pd.DataFrame:
        """
        Get calibrated zone data

        Parameters
        ----------
        segid : str
            Snow-17 model segment name
        opid : str
            CBRFC zone name (Optional)

        Returns
        -------
        pd.DataFrame       
            Zone data for all available years.
        """
        # The '_C' suffix indicates calibrated segment records
        segid = segid + "_C"

        query = self.Query.ZONE_CALIBRATED
        query_args = {'segid': segid}

        if opid is not None:
            query = query + " AND opid = :opid"
            query_args['opid'] = opid

        data = self.query(query, **query_args)

        return data
