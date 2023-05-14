import json
from types import SimpleNamespace

from sqlalchemy import create_engine, URL
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import sql

import pandas as pd

# Ignored by git!
DB_CONFIG_FILE = "config.json"

with open(DB_CONFIG_FILE, mode='r') as fp:
    DB_CONFIG = json.load(fp, object_hook=lambda x: SimpleNamespace(**x))

db_url = URL.create(
    drivername="mysql",
    username=DB_CONFIG.db_username,
    password=DB_CONFIG.db_password,
    host=DB_CONFIG.db_host,
    database=DB_CONFIG.db_database,
    port=DB_CONFIG.db_port
)
engine = create_engine(db_url)
session = Session(engine)

Base = automap_base()
Base.prepare(autoload_with=engine)
classes = Base.classes

# using DFs will simplify managing FKs and exporting SQL inserts
queries = [session.query(table).filter(sql.false()) for table in classes]
dfs = [pd.read_sql(query.statement, engine) for query in queries]
pass

# TODO generate data
