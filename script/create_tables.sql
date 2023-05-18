CREATE TABLE brand (
    name VARCHAR(50) NOT NULL UNIQUE
);
ALTER TABLE brand ADD CONSTRAINT brand_pk PRIMARY KEY ( name );


CREATE TABLE car (
    id                          int NOT NULL,
    model_id                    int NOT NULL,
    model_name                  varchar(50) NOT NULL,
    licence_type_required       ENUM('M', 'A', 'B1', 'B', 'C1', 'C', 'D1', 'D', 'BE', 'C1E', 'CE', 'D1E', 'DE', 'T', 'F') NOT NULL,
    has_issues                  int NOT NULL,
    locationx                   double NOT NULL,
    locationy                   double NOT NULL,
    state                       ENUM('available', 'rented', 'issues', 'decommissioned') NOT NULL
);
ALTER TABLE car ADD CONSTRAINT car_pk PRIMARY KEY ( id );

CREATE TABLE car_type (
    name VARCHAR(50) NOT NULL UNIQUE
);
ALTER TABLE car_type ADD CONSTRAINT car_type_pk PRIMARY KEY (name);


CREATE TABLE customer (
    id                 int NOT NULL,
    name               VARCHAR(20),
    surname            VARCHAR(20)
);
ALTER TABLE customer ADD CONSTRAINT customer_pk PRIMARY KEY ( id );


CREATE TABLE driving_licence 
    (
    customer_id              int NOT NULL,
    drivers_license_number   VARCHAR(20) NOT NULL,
    drivers_license_category ENUM('M', 'A', 'B1', 'B', 'C1', 'C', 'D1', 'D', 'BE', 'C1E', 'CE', 'D1E', 'DE', 'T', 'F') NOT NULL,
    valid_from DATE NOT NULL,
    valid_until DATE NOT NULL
) 
;
ALTER TABLE driving_licence ADD CONSTRAINT driving_licence_pk PRIMARY KEY ( customer_id );


CREATE TABLE employee (
    id                   int NOT NULL,
    name                 VARCHAR(20) NOT NULL,
    surname              VARCHAR(20) NOT NULL,
    employee_position_id int NOT NULL
);
ALTER TABLE employee ADD CONSTRAINT employee_pk PRIMARY KEY ( id );


CREATE TABLE employee_position (
    id            int NOT NULL,
    position_name VARCHAR(20),
    description   VARCHAR(100)
);
ALTER TABLE employee_position ADD CONSTRAINT employee_position_pk PRIMARY KEY ( id );


CREATE TABLE insurance (
    car_id         int NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date   TIMESTAMP NOT NULL
);
ALTER TABLE insurance ADD CONSTRAINT insurance_pk PRIMARY KEY ( car_id );


CREATE TABLE invoice (
    invoice_id      int NOT NULL,
    total 			double NOT NULL,
    nip             int NOT NULL,
    customer_name    VARCHAR(20),
    customer_surname  VARCHAR(20),
    rental_orders     VARCHAR(500)
);
ALTER TABLE invoice ADD CONSTRAINT invoice_pk PRIMARY KEY ( invoice_id );


CREATE TABLE model
    (
    id                       int NOT NULL,
    name                     VARCHAR(20) NOT NULL,
    licence_type_required ENUM('M', 'A', 'B1', 'B', 'C1', 'C', 'D1', 'D', 'BE', 'C1E', 'CE', 'D1E', 'DE', 'T', 'F') NOT NULL,
    car_brand_name           VARCHAR(50) NOT NULL,
    car_type_name           VARCHAR(50) NOT NULL)
;
ALTER TABLE model ADD CONSTRAINT model_pk PRIMARY KEY ( id );


CREATE TABLE model_parameter (

    id              int NOT NULL,
    text_value      VARCHAR(30),
    numerical_value int,
    model_id        int NOT NULL,
    parameter_id    int NOT NULL
);
ALTER TABLE model_parameter ADD CONSTRAINT model_parameter_pk PRIMARY KEY ( id );


CREATE TABLE parameter (
    id          int NOT NULL,
    name        VARCHAR(30) NOT NULL,
    description VARCHAR(30),
    type        CHAR(1) -- 'N' for numerical, 'T' for text
);
ALTER TABLE parameter ADD CONSTRAINT parameter_pk PRIMARY KEY ( id );


CREATE TABLE registration_certificate (
    car_id         int NOT NULL,
    start_date DATE NOT NULL,
    end_date   DATE NOT NULL
);
ALTER TABLE registration_certificate ADD CONSTRAINT registration_certificate_pk PRIMARY KEY ( car_id );


CREATE TABLE rental_order 
    (
    id          int NOT NULL,
    is_finished bool NOT NULL,
    fee_rate    int  NOT NULL,
    start_date_time TIMESTAMP, 
    end_date_time TIMESTAMP,
    car_id      int NOT NULL,
    customer_id int, -- (może być null po usunieciu klienta z bazy
    invoice_id int 
    ) 
;
ALTER TABLE rental_order ADD CONSTRAINT rental_order_pk PRIMARY KEY ( id );


CREATE TABLE technical_inspection (
    id          int NOT NULL,
    `date`      DATETIME NOT NULL,
    mechanic_id int NOT NULL,
    car_id int NOT NULL
    
);
ALTER TABLE technical_inspection ADD CONSTRAINT technical_inspection_pk PRIMARY KEY ( id );


ALTER TABLE car
    ADD CONSTRAINT car_model_fk FOREIGN KEY ( model_id )
        REFERENCES model ( id )
            ON DELETE CASCADE ON UPDATE CASCADE;


ALTER TABLE driving_licence
    ADD CONSTRAINT driving_licence_customer_fk FOREIGN KEY ( customer_id )
        REFERENCES customer ( id )
            ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE employee
    ADD CONSTRAINT employee_employee_position_fk FOREIGN KEY ( employee_position_id )
        REFERENCES employee_position ( id )
            ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE insurance
    ADD CONSTRAINT insurance_car_fk FOREIGN KEY ( car_id )
        REFERENCES car ( id )
            ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE model_parameter
    ADD CONSTRAINT model_parameter_model_fk FOREIGN KEY ( model_id )
        REFERENCES model ( id )
            ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE model_parameter
    ADD CONSTRAINT model_parameter_parameter_fk FOREIGN KEY ( parameter_id )
        REFERENCES parameter ( id )
            ON DELETE CASCADE ON UPDATE CASCADE;
        
ALTER TABLE registration_certificate
    ADD CONSTRAINT registration_certificate_car_fk FOREIGN KEY ( car_id )
        REFERENCES car ( id )
            ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE rental_order
    ADD CONSTRAINT rental_order_car_fk FOREIGN KEY ( car_id )
        REFERENCES car ( id )
            ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE rental_order
    ADD CONSTRAINT rental_order_customer_fk FOREIGN KEY ( customer_id )
        REFERENCES customer ( id )
            ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE rental_order
    ADD CONSTRAINT rental_order_invoice_fk FOREIGN KEY ( invoice_id )
        REFERENCES invoice ( invoice_id )
            ON DELETE CASCADE ON UPDATE CASCADE;
           
ALTER TABLE technical_inspection
    ADD CONSTRAINT technical_inspection_employee_position_fk FOREIGN KEY ( mechanic_id )
        REFERENCES employee_position ( id )
            ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE technical_inspection
    ADD CONSTRAINT technical_inspection_car_fk FOREIGN KEY ( car_id )
        REFERENCES car ( id )
            ON DELETE CASCADE ON UPDATE CASCADE;
           
-- ------------------------------------------------------------------


