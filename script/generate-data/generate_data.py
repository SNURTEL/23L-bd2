import json
import datetime
import dateutil
from types import SimpleNamespace

import faker
import pandas as pd
from sqlalchemy import create_engine, URL
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import sql

DB_CONFIG_FILE = "config.json"  # Ignored by git!
INSERT_DRY_RUN = False

# TODO extract magic numbers
# TODO generate remaining data

print(" PREP ".center(60, '='))
print('Query DB to validate schema...')

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

queries = {name: session.query(table).filter(sql.false()) for name, table in Base.metadata.tables.items()}
dfs = {name: pd.read_sql(query.statement, engine) for name, query in queries.items()}

print(" GENERATE DATA ".center(60, '='))


def append_to_df(name: str, new_lines: pd.DataFrame) -> None:
    # RIP SOLID
    print(f"Generating \"{name}\" [{len(new_lines.index)}] done")
    assert str(new_lines.columns) == str(dfs[name].columns)
    dfs[name] = pd.concat([dfs[name], new_lines])


fake = faker.Faker('pl_PL')

employee_positions = pd.DataFrame([
    [0, 'mechanic', 'maintains vehicles'],
    [1, 'admin', 'keeps the system running']
], columns=['id', 'position_name', 'description'])
append_to_df('employee_position', employee_positions)

employees = pd.DataFrame(
    [(i, fake.first_name(), fake.last_name(), 0) for i in range(17)] + [(i, fake.first_name(), fake.last_name(), 1)
                                                                        for i in range(17, 20, 1)],
    columns=['id', 'name', 'surname', 'employee_position_id']
)
append_to_df('employee', employees)

customers = pd.DataFrame(
    [(i, fake.first_name(), fake.last_name()) for i in range(3000)],
    columns=['id', 'name', 'surname']
)
append_to_df('customer', customers)

fake_drv_lic_number = lambda: f"{fake.random.randint(0, 9999):04}/{fake.random.randint(0, 99):02}/{fake.random.randint(0, 9999):04}"
fake_drv_lic = lambda category, number: pd.DataFrame(
    [(customer_id,
      fake_drv_lic_number(),
      category,
      start_d.strftime("%d.%m.%Y"),
      (start_d + dateutil.relativedelta.relativedelta(years=15)).strftime("%d.%m.%Y"))
     for customer_id, start_d in zip(
        customers.sample(number)['id'].sort_values(),
        [fake.date_between(datetime.date(2008, 2, 21), datetime.date(2023, 5, 16)) for _ in range(number)])],
    columns=['customer_id', 'drivers_license_number', 'drivers_license_category', 'valid_from', 'valid_until']
)
driving_licences = pd.concat([
    fake_drv_lic('B', int(3000 * 0.98)),
    pd.concat([fake_drv_lic(cat, int(3000 * 0.03)) for cat in ('A', 'BE', 'C')]),
    pd.concat([fake_drv_lic(cat, int(3000 * 0.001)) for cat in
               ('M', 'B1', 'C1', 'D1', 'D', 'C1E', 'CE', 'D1E', 'DE', 'T', 'F')])
])
append_to_df('driving_licence', driving_licences)

print(" INSERT ".center(60, '='))

for name, df in dfs.items():
    aff_rows = df.to_sql(name=name,
                         con=engine,
                         if_exists='append',
                         index=False,
                         method='multi' if not INSERT_DRY_RUN else lambda pd_table, conn, keys, data_iter: len(
                             list(data_iter)))
    print(f"{'[DRY RUN] ' if INSERT_DRY_RUN else ''}INSERT to \"{name}\" affected {aff_rows} rows")

print(" END ".center(60, '='))
