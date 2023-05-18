import json
import datetime
import math
import random

import dateutil
import itertools
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

employee_positions = pd.DataFrame([
    [0, 'mechanic', 'maintains vehicles'],
    [1, 'admin', 'keeps the system running']
], columns=['id', 'position_name', 'description'])
append_to_df('employee_position', employee_positions)

employees = pd.DataFrame(
    [(i, name, surname, 0,
      f"{name[0].lower()}{surname.lower()}@{fake.free_email_domain()}".encode('ascii', errors='ignore').decode("utf-8"),
      ''.join(random.choices("1234567890abcdef", k=128))) for i, (name, surname) in
     enumerate(((fake.first_name(), fake.last_name()) for _ in range(17)))] +
    [(i, name, surname, 1,
      f"{name[0].lower()}{surname.lower()}@{fake.free_email_domain()}".encode('ascii', errors='ignore').decode("utf-8"),
      ''.join(random.choices("1234567890abcdef", k=128))) for i, (name, surname) in
     enumerate(((fake.first_name(), fake.last_name()) for _ in range(3)), 17)],
    columns=['id', 'name', 'surname', 'employee_position_id', 'email', 'password_hash']
)
append_to_df('employee', employees)

customers = pd.DataFrame(
    [(i, name, surname,
      f"{name[0].lower()}{surname.lower()}@{fake.free_email_domain()}".encode('ascii', errors='ignore').decode("utf-8"),
      ''.join(random.choices("1234567890abcdef", k=128))) for i, (name, surname) in
     enumerate(((fake.first_name(), fake.last_name()) for _ in range(3000)))],
    columns=['id', 'name', 'surname', 'email', 'password_hash']
)
append_to_df('customer', customers)

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
        random.choices(['available', 'decommissioned'], weights=[0.95, 0.05])[
            # random.choices(['available', 'rented', 'decommissioned'], weights=[0.6, 0.35, 0.05])[
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
append_to_df('car', cars)  # TODO Works only on dry run! wait until model table is done

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

rendal_order_idx_generator = itertools.count()
rental_order = pd.DataFrame(  # this assumes no car was rented more than once a day
    itertools.chain(*[(
        [(next(rendal_order_idx_generator),
          True,
          random.randint(80, 130),
          base_d + start_h,
          base_d + start_h + datetime.timedelta(minutes=random.randint(8, 80)),
          car,
          customer,
          None
          ) for start_h, car, customer in zip(
            (datetime.timedelta(hours=6) + datetime.timedelta(minutes=random.randint(0, 17 * 60)) for _ in
             range(num_rented_cars)),
            cars.sample(num_rented_cars, replace=False)['id'],
            customers.sample(num_rented_cars, replace=False)['id'])]
    ) for base_d, num_rented_cars in zip(
        reversed([datetime.datetime(2023, 5, 16) - datetime.timedelta(days=d) for d in range(365)]),
        (random.randint(20, 40) for _ in range(365))
    )]),
    columns=['id', 'is_finished', 'fee_rate', 'start_date_time', 'end_date_time', 'car_id', 'customer_id', 'invoice_id']
)


sampled = rental_order.sample(n=1000).sort_values('id')
to_invoice = pd.merge(sampled, customers, left_on="customer_id", right_on="id")
total_fees = ((to_invoice['end_date_time'] - to_invoice['start_date_time']).dt.components['hours'] * 60 + \
              (to_invoice['end_date_time'] - to_invoice['start_date_time']).dt.components['minutes']) * \
              to_invoice['fee_rate']
invoice = pd.concat([
    pd.DataFrame(range(len(to_invoice))),
    total_fees,
    pd.DataFrame([fake.company_vat() for _ in range(1000)]),
    to_invoice['name'],
    to_invoice['surname'],
    pd.DataFrame(['' for _ in range(1000)])],
    axis=1)
invoice.columns = ['invoice_id', 'total', 'nip', 'customer_name', 'customer_surname', 'rental_orders']

rental_order_to_invoice_mapping = dict(zip(list(to_invoice['id_x']), list(invoice['invoice_id'])))

def row_func(row):
    res = rental_order_to_invoice_mapping.get(row['id'], None)
    if res is None:
        return row
    else:
        return row.replace({None: res}, regex=False)
        return row

rental_order = rental_order.apply(row_func, axis=1)

append_to_df('rental_order', rental_order)
append_to_df('invoice', invoice)

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
