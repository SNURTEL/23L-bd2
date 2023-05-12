INSERT INTO brand (id, name) VALUES(1, 'audi');
INSERT INTO car_type (id, name) VALUES(1, 'small');
INSERT INTO model (id, name, engine, drive_type, transmission, seats, licence_type_required, car_brand_name, car_type_name)
	VALUES (1, 'audi a4', 'electric', 'fwd', 'manual', 5, 'B1', 'audi', 'small'); -- this works OK
	
INSERT INTO model (id, name, engine, drive_type, transmission, seats, licence_type_required, car_brand_name, car_type_name)
	VALUES (2, 'audi a5', 'electric', 'fwd', 'manual', 5, 'B1', 'audi', 'big'); -- this don't works,
-- above doesnt' work: 'Cannot insert. In table car_type there is no type named: big' OK

INSERT INTO model (id, name, engine, drive_type, transmission, seats, licence_type_required, car_brand_name, car_type_name)
	VALUES (3, 'audi a5', 'electric', 'fwd', 'manual', 5, 'B1', 'toyota', 'small'); -- this don't works,
-- above doesnt' work: 'Cannot insert. In table brand there is no brand named: toyota' OK

INSERT INTO car (id, model_id, model_name, licence_type_required, has_issues, locationx, locationy, state)
    VALUES (1, 1, null, null, 1, 14.5, 12.7, 'available');
   -- this works! It doesn't matter what values you put in model_name and licence_type_required column, trigger sets
   -- those values to be exactly the same as in model referenced by model_id).
   
   
   
INSERT INTO invoice (invoice_id, total, nip, customer_name, customer_surname, rental_orders)
VALUES (1, 50.6, 142531, 'Jedrzej', 'Chmiel', '{[1, "toyota", ble ble ble]}'); -- this works

UPDATE invoice SET customer_name = 'Michal' WHERE invoice_id = 1; -- this doesn't work: It is not allowed to change data of an invoice!

DELETE FROM invoice WHERE invoice_id = 1; -- this doesn't work: It is not allowed to It is not allowed to delete an invoice!

