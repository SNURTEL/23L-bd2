import json
import datetime
import math
import random

import dateutil
from types import SimpleNamespace

import faker
import pandas as pd
from sqlalchemy import create_engine, URL
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import sql

DB_CONFIG_FILE = "config.json"  # Ignored by git!
INSERT_DRY_RUN = True

DATE_FORMAT = "%Y-%m-%d"

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
    port=DB_CONFIG.db_port,
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

############################
# employee positions
############################

employee_positions = pd.DataFrame([
    [0, 'mechanic', 'maintains vehicles'],
    [1, 'admin', 'keeps the system running']
], columns=['id', 'position_name', 'description'])
append_to_df('employee_position', employee_positions)

############################
# employees
############################

employees = pd.DataFrame(
    [(i, fake.first_name(), fake.last_name(), 0) for i in range(17)] + [(i, fake.first_name(), fake.last_name(), 1)
                                                                        for i in range(17, 20, 1)],
    columns=['id', 'name', 'surname', 'employee_position_id']
)
append_to_df('employee', employees)

############################
# customers
############################

customers = pd.DataFrame(
    [(i, fake.first_name(), fake.last_name()) for i in range(3000)],
    columns=['id', 'name', 'surname']
)
append_to_df('customer', customers)

############################
# driving licences
############################

fake_drv_lic_number = lambda: f"{fake.random.randint(0, 9999):04}/{fake.random.randint(0, 99):02}/{fake.random.randint(0, 9999):04}"


def fake_drv_lic(category, id):
    start_d = fake.date_between(datetime.date(2008, 2, 21), datetime.date(2023, 5, 16))
    return (id,
            fake_drv_lic_number(),
            category,
            start_d.strftime(DATE_FORMAT),
            (start_d + dateutil.relativedelta.relativedelta(years=15)).strftime(DATE_FORMAT))


drv_lic_columns = ['customer_id', 'drivers_license_number', 'drivers_license_category', 'valid_from', 'valid_until']

# FIXME no info on whether only automatic transmission is allowed
driving_licences = pd.concat([
    pd.DataFrame([fake_drv_lic('B', customer_id) for customer_id in customers['id'][:2800]], columns=drv_lic_columns),
    pd.DataFrame([fake_drv_lic(category, customer_id) for category, customer_id in
                  zip(random.choices(('A', 'BE', 'C'), k=170), customers['id'][2800:2970])], columns=drv_lic_columns),
    pd.DataFrame([fake_drv_lic(category, customer_id) for category, customer_id in
                  zip(random.choices(('M', 'B1', 'C1', 'D1', 'D', 'C1E', 'CE', 'D1E', 'DE', 'T', 'F'), k=30),
                      customers['id'][2970:])], columns=drv_lic_columns),
])
append_to_df('driving_licence', driving_licences)

# cars
models_with_id = [  # TODO replace with actual data
    (10001, 'Volkswagen Golf'),
    (10002, 'Hyundai i20'),
    (10003, 'Toyota Yaris'),
    (10004, 'Ford Mondeo')
]

loc_center_x, loc_center_y, loc_radius = 52.240237, 21.032048, 0.118085334
cars = pd.DataFrame(
    [(
        i,
        *random.choice(models_with_id),
        'B',
        has_issues,  # FIXME REDUNDANT COLUMN!
        loc_center_x + r * math.cos(theta),
        loc_center_y + r * math.sin(theta),
        random.choices(['available', 'rented', 'decommissioned'], weights=[0.6, 0.35, 0.05])[
            0] if not has_issues else 'issues'
    ) for i, (r, theta), has_issues in zip(
        range(50),
        # this draws uniformly distributed points from a circle
        [[math.sqrt(random.random() * loc_radius) * math.sqrt(loc_radius), 2 * math.pi * random.random()] for _ in
         range(50)],
        random.choices([0, 1], weights=[0.92, 0.08], k=50)
    )],
    columns=['id', 'model_id', 'model_name', 'licence_type_required', 'has_issues', 'locationx', 'locationy', 'state']
)
# append_to_df('car', cars)  # TODO wait until model table is done

registration_certificate = pd.DataFrame(
    [(car_id,
      fake.date_between(datetime.date(2022, 5, 16), datetime.date(2023, 5, 16)).strftime(DATE_FORMAT),
      None) for car_id in cars['id']],
    columns=['car_id', 'start_date', 'end_date']
)
append_to_df('registration_certificate', registration_certificate)

insurance = pd.DataFrame(
    [(car_id,
      start_d.strftime(DATE_FORMAT),
      (start_d + dateutil.relativedelta.relativedelta(years=1)).strftime(DATE_FORMAT))
     for car_id, start_d in zip(cars['id'],
                                [fake.date_between(datetime.date(2022, 5, 16), datetime.date(2023, 5, 16)) for _ in
                                 range(len(cars['id']))])],
    columns=['car_id', 'start_date', 'end_date']
)
append_to_df('insurance', insurance)

technical_inspection = pd.DataFrame(
    [(
        i,
        date,
        mechanic,
        car
    ) for i, (date, mechanic, car) in enumerate(zip(
        sorted(fake.date_between(datetime.date(2013, 5, 16), datetime.date(2023, 5, 16)) for _ in range(500)),
        employees[employees['employee_position_id'] == 0]['id'].sample(500, replace=True),
        cars['id'].sample(500, replace=True)
    ))], columns=['id', 'date', 'mechanic_id', 'car_id']
)
append_to_df('technical_inspection', technical_inspection)

print(" INSERT ".center(60, '='))

insert_order = [
    'employee_position',
    'employee',
    'customer',
    'driving_licence',
    'brand',
    'car_type',
    'model',
    'parameter',
    'model_parameter',
    'car',
    'technical_inspection',
    'registration_certificate',
    'insurance',
    'invoice',
    'rental_order'
]
assert set(insert_order) == set(dfs.keys())

for table_name in insert_order:
    df = dfs[table_name]
    print(f"{'[DRY RUN] ' if INSERT_DRY_RUN else ''}INSERT to \"{table_name}\"", end=' ')
    aff_rows = df.to_sql(name=table_name,
                         con=engine,
                         if_exists='append',
                         index=False,
                         chunksize=None,
                         method='multi' if not INSERT_DRY_RUN else lambda pd_table, conn, keys, data_iter: len(
                             list(data_iter)))
    print(f"affected {aff_rows} rows")

print(" END ".center(60, '='))
