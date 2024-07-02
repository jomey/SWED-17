from dataclasses import dataclass


@dataclass
class CBRFCZone:
    ch5_id: str
    zone: str
    description: str

    ZONES_IN_CH5ID = "SELECT cz.ch5_id, cz.zone, cz.description FROM cbrfc_zones CZ " \
                     "WHERE CH5_ID = ANY(%s)"
