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

from hashes import hash_list

DB_CONFIG_FILE = "config.json"  # Ignored by git!
INSERT_DRY_RUN = False

DATE_FORMAT = "%Y-%m-%d"


print(" PREP ".center(60, '='))
if INSERT_DRY_RUN:
    print(u"\u001b[32m" + "DRY RUN ENABLED!".center(60, '=') + u"\u001b[0m")
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

queries = {name: session.query(table).filter(sql.false())
           for name, table in Base.metadata.tables.items()}
dfs = {name: pd.read_sql(query.statement, engine)
       for name, query in queries.items()}

print(" GENERATE DATA ".center(60, '='))


def append_to_df(name: str, new_lines: pd.DataFrame) -> None:
    # RIP SOLID
    print(f"Generating \"{name}\" [{len(new_lines.index)}] done")
    assert str(new_lines.columns) == str(dfs[name].columns)
    dfs[name] = pd.concat([dfs[name], new_lines])


fake = faker.Faker('pl_PL')

############################
# employee_positions
############################

employee_positions = pd.DataFrame([
    [1, 'mechanic', 'maintains vehicles'],
    [2, 'admin', 'keeps the system running']
], columns=['id', 'position_name', 'description'])
append_to_df('employee_position', employee_positions)

############################
# employees
############################

employees_no_hashes = pd.DataFrame(
    [(i, name.lower(), surname.lower(), 1,
      f"{name[0].lower()}{surname.lower()}@{fake.free_email_domain()}".encode('ascii',
                                                                              errors='ignore').decode("utf-8"),
      ) for i, (name, surname) in
     enumerate(((fake.first_name(), fake.last_name()) for _ in range(17)), 1)] +
    [(i, name, surname, 2,
      f"{name[0].lower()}{surname.lower()}@{fake.free_email_domain()}".encode('ascii',
                                                                              errors='ignore').decode("utf-8"),
      ) for i, (name, surname) in
     enumerate(((fake.first_name(), fake.last_name()) for _ in range(3)), 18)],
    columns=['id', 'name', 'surname', 'employee_position_id', 'email']
)

employee_passwords_with_hashes = pd.DataFrame(
    itertools.islice(itertools.cycle(hash_list), 20),
    columns=['password', 'hash']
)
employees = pd.concat(
    [employees_no_hashes,
     employee_passwords_with_hashes['hash']],
    axis=1
)
employees.columns = list(employees_no_hashes.columns) + ['password_hash']

with open('employee_cred.json', mode='w') as fp:
    empl_email_to_password = pd.concat(
        [employees['email'], employee_passwords_with_hashes['password']], axis=1)
    fp.write(empl_email_to_password.to_json(indent=4))
append_to_df('employee', employees)

############################
# customers
############################

customers_no_hashes = pd.DataFrame(
    [(i, name.lower(), surname.lower(),
      f"{name[0].lower()}{surname.lower()}@{fake.free_email_domain()}".encode('ascii',
                                                                              errors='ignore').decode("utf-8"),
      ) for i, (name, surname) in
     enumerate(((fake.first_name(), fake.last_name()) for _ in range(100)), 1)],
    columns=['id', 'name', 'surname', 'email',]
)

customer_passwords_with_hashes = pd.DataFrame(
    itertools.islice(itertools.cycle(hash_list), 100),
    columns=['password', 'hash']
)
customers = pd.concat(
    [customers_no_hashes,
     customer_passwords_with_hashes['hash']],
    axis=1
)
customers.columns = list(customers_no_hashes.columns) + ['password_hash']

with open('customer_cred.json', mode='w') as fp:
    cust_email_to_password = pd.concat(
        [customers['email'], customer_passwords_with_hashes['password']], axis=1)
    fp.write(cust_email_to_password.to_json(indent=4))


append_to_df('customer', customers)

############################
# car types
############################

car_type = pd.DataFrame(['hatchback', 'kombi', 'sedan', 'liftback', 'van', 'suv', 'crossover', 'coupe'],
                        columns=['name'])
append_to_df('car_type', car_type)

############################
# brands
############################

brand = pd.DataFrame(['toyota', 'volkswagen', 'ford', 'honda', 'nissan', 'hyundai', 'chevrolet', 'kia',
                      'mercedes', 'bmw', 'fiat', 'opel', 'peugeot', 'citroen', 'audi', 'skoda', 'volvo', 'mazda',
                      'seat',
                      'suzuki', 'mitsubishi', 'land rover', 'jeep', 'porsche', 'alfa romeo', 'chrysler', 'jaguar',
                      'ferrari', 'infiniti',
                      'lexus', 'dacia', 'mini', 'smart', 'renault'], columns=['name'])
append_to_df('brand', brand)

############################
# parameters
############################

parameter = pd.DataFrame([
    [1, 'drive_type', 'drive type', 's'],
    [2, 'engine_capacity', 'engine capacity', 'f'],
    [3, 'engine_power', 'engine_power', 'i'],
    [4, 'fuel_type', 'fuel type', 's'],
    [5, 'gearbox_type', 'gearbox type', 's'],
    [6, 'mileage', 'mileage', 'i'],
    [7, 'seat_number', 'seat number', 'i'],
    [8, 'color', 'color', 's']],
    columns=['id', 'name', 'description', 'type'])
append_to_df('parameter', parameter)

############################
# models
############################

model = pd.DataFrame([
    [1, '3', 'B', 'mazda', 'sedan', 0.4],
    [2, 'a4', 'B', 'audi', 'sedan', 0.7],
    [3, 'a6', 'B', 'audi', 'sedan', 0.8],
    [4, 'punto', 'B', 'fiat', 'hatchback', 0.3],
    [5, 'civic', 'B', 'honda', 'hatchback', 0.5],
    [6, 'focus', 'B', 'ford', 'hatchback', 0.6],
    [7, 'golf', 'B', 'volkswagen', 'hatchback', 0.6],
    [8, 'passat', 'B', 'volkswagen', 'sedan', 0.7],
    [9, 'clio', 'B', 'renault', 'hatchback', 0.4],
    [10, 'megane', 'B', 'renault', 'hatchback', 0.5],
    [11, 'corolla', 'B', 'toyota', 'hatchback', 0.5],
    [12, 'yaris', 'B', 'toyota', 'hatchback', 0.4],
    [13, 'auris', 'B', 'toyota', 'hatchback', 0.5],
    [14, 'avensis', 'B', 'toyota', 'sedan', 0.6],
    [15, 'ceed', 'B', 'kia', 'hatchback', 0.5],
    [16, 'rio', 'B', 'kia', 'hatchback', 0.4],
    [17, 's40', 'B', 'volvo', 'sedan', 0.6],
    [18, 'v40', 'B', 'volvo', 'hatchback', 0.5],
    [19, 'v50', 'B', 'volvo', 'hatchback', 0.5],
    [20, 'xc60', 'B', 'volvo', 'suv', 0.8],
    [21, 'xc70', 'B', 'volvo', 'suv', 0.8],
    [22, 'c4', 'B', 'citroen', 'hatchback', 0.4],
    [23, 'c5', 'B', 'citroen', 'sedan', 0.6],
    [24, 'c6', 'B', 'citroen', 'sedan', 0.7],
    [25, 'qashqai', 'B', 'nissan', 'suv', 0.7],
    [26, 'juke', 'B', 'nissan', 'suv', 0.6],
    [27, 'micra', 'B', 'nissan', 'hatchback', 0.4],
    [28, 'note', 'B', 'nissan', 'hatchback', 0.4],
    [29, 'astra', 'B', 'opel', 'hatchback', 0.5]],
    columns=['id', 'name', 'licence_type_required',
             'car_brand_name', 'car_type_name', 'fee_rate']
)
append_to_df('model', model)

############################
# model parameters
############################

model_parameter = pd.DataFrame(
    [[i, 'red', None, i, 8] for i in range(1, 30)] +
    [[i + 29, 'manual', None, i, 5] for i in range(1, 30)] +
    [[i + 58, None, None, i, 7] for i in range(1, 30)],
    columns=['id', 'text_value', 'numerical_value', 'model_id', 'parameter_id']
)

append_to_df('model_parameter', model_parameter)

############################
# driving licences
############################


def fake_drv_lic_number(
): return f"{fake.random.randint(0, 9999):04}/{fake.random.randint(0, 99):02}/{fake.random.randint(0, 9999):04}"


def fake_drv_lic(category, id):
    start_d = fake.date_between(datetime.date(
        2008, 2, 21), datetime.date(2023, 5, 16))
    return (id,
            fake_drv_lic_number(),
            category,
            start_d.strftime(DATE_FORMAT),
            (start_d + dateutil.relativedelta.relativedelta(years=15)).strftime(DATE_FORMAT))


drv_lic_columns = ['customer_id', 'drivers_license_number',
                   'drivers_license_category', 'valid_from', 'valid_until']

driving_licences = pd.concat([
    pd.DataFrame([fake_drv_lic('B', customer_id)
                 for customer_id in customers['id'][:2800]], columns=drv_lic_columns),
    pd.DataFrame([fake_drv_lic(category, customer_id) for category, customer_id in
                  zip(random.choices(('A', 'BE', 'C'), k=170), customers['id'][2800:2970])], columns=drv_lic_columns),
    pd.DataFrame([fake_drv_lic(category, customer_id) for category, customer_id in
                  zip(random.choices(('M', 'B1', 'C1', 'D1', 'D', 'C1E', 'CE', 'D1E', 'DE', 'T', 'F'), k=30),
                      customers['id'][2970:])], columns=drv_lic_columns),
])
append_to_df('driving_licence', driving_licences)

############################
# cars
############################

loc_center_x, loc_center_y, loc_radius = 52.240237, 21.032048, 0.118085334
sampled_models = model.sample(n=50, replace=True)

cars = pd.concat([
    pd.DataFrame(range(1, 51)),
    sampled_models.reset_index()['id'],
    sampled_models.reset_index()['name'],
    pd.DataFrame(
        [('B',
          loc_center_x + r * math.cos(theta),
          loc_center_y + r * math.sin(theta),
          random.choices(['available', 'decommissioned'], weights=[0.95, 0.05])[0])
         for (r, theta) in
            [[math.sqrt(random.random() * loc_radius) * math.sqrt(loc_radius), 2 * math.pi * random.random()] for _ in
             range(50)]])
], axis=1)
cars.columns = ['id', 'model_id', 'model_name', 'licence_type_required', 'locationx', 'locationy',
                'state']
append_to_df('car', cars)

############################
# registration certificates
############################

registration_certificate = pd.DataFrame(
    [(car_id,
      fake.date_between(datetime.date(2022, 5, 16), datetime.date(
          2023, 5, 16)).strftime(DATE_FORMAT),
      None) for car_id in cars['id']],
    columns=['car_id', 'start_date', 'end_date']
)
append_to_df('registration_certificate', registration_certificate)

############################
# insurance
############################

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

############################
# technical inspection
############################

technical_inspection = pd.DataFrame(
    [(
        i,
        date,
        mechanic,
        car
    ) for i, (date, mechanic, car) in enumerate(zip(
        sorted(fake.date_between(datetime.date(2013, 5, 16),
               datetime.date(2023, 5, 16)) for _ in range(500)),
        employees[employees['employee_position_id']
                  == 1]['id'].sample(500, replace=True),
        cars['id'].sample(500, replace=True)
    ), 1)], columns=['id', 'date', 'mechanic_id', 'car_id']
)
append_to_df('technical_inspection', technical_inspection)

############################
# rental order
# invoice
############################

rental_order_idx_generator = itertools.count(1)
rental_order = pd.DataFrame(  # this assumes no car was rented more than once a day
    itertools.chain(*[(
        [(next(rental_order_idx_generator),
          True,
          random.randint(0, 100),  # TODO generate price based on fee_rate
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
        reversed([datetime.datetime(2023, 5, 16) - \
                 datetime.timedelta(days=d) for d in range(365)]),
        (random.randint(20, 40) for _ in range(365))
    )]),
    columns=['id', 'is_finished', 'price', 'start_date_time',
             'end_date_time', 'car_id', 'customer_id', 'invoice_id']
)

sampled = rental_order.sample(n=1000).sort_values('id')
to_invoice = pd.merge(sampled, customers, left_on="customer_id", right_on="id")
total_fees = ((to_invoice['end_date_time'] - to_invoice['start_date_time']).dt.components['hours'] * 60 +
              (to_invoice['end_date_time'] - to_invoice['start_date_time']).dt.components['minutes']) * \
    to_invoice['price']
invoice = pd.concat([
    pd.DataFrame(range(1, len(to_invoice) + 1)),
    total_fees,
    pd.DataFrame([fake.company_vat() for _ in range(1000)]),
    to_invoice['name'],
    to_invoice['surname']],
    axis=1)
invoice.columns = ['invoice_id', 'total',
                   'nip', 'customer_name', 'customer_surname']

rental_order_to_invoice_mapping = dict(
    zip(list(to_invoice['id_x']), list(invoice['invoice_id'])))


def row_func(row):
    res = rental_order_to_invoice_mapping.get(row['id'], None)
    if res is None:
        return row
    else:
        return row.replace({None: res}, regex=False)


rental_order = rental_order.apply(row_func, axis=1)

append_to_df('rental_order', rental_order)
append_to_df('invoice', invoice)

############################
# insert
############################

print(" INSERT ".center(60, '='))

insert_order = [
    'employee_position',
    'employee',
    'customer',
    'driving_licence',
    'brand',
    'car_type',
    'parameter',
    'model',
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
    print(u"\u001b[32m" + f"{'[DRY RUN] ' if INSERT_DRY_RUN else ''}" +
          u"\u001b[0m" + f"INSERT to \"{table_name}\"", end=' ')
    aff_rows = df.to_sql(name=table_name,
                         con=engine,
                         if_exists='append',
                         index=False,
                         chunksize=None,
                         method=None if not INSERT_DRY_RUN else lambda pd_table, conn, keys, data_iter: len(
                             list(data_iter)))
    print(f"affected {aff_rows} rows")

print(" END ".center(60, '='))
