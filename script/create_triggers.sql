delimiter //
CREATE TRIGGER car_trigger_i BEFORE INSERT ON car FOR EACH ROW
BEGIN
	   DECLARE v1 VARCHAR(50);
	   DECLARE v2 ENUM('M', 'A', 'B1', 'B', 'C1', 'C', 'D1', 'D', 'BE', 'C1E', 'CE', 'D1E', 'DE', 'T', 'F');
	   SELECT name, licence_type_required INTO v1, v2
	       FROM model M WHERE M.id = NEW.model_id;
	   SET NEW.model_name = v1;
	   SET NEW.licence_type_required = v2;
END //

CREATE TRIGGER car_trigger_u BEFORE UPDATE ON car FOR EACH ROW
BEGIN
	   DECLARE v1 VARCHAR(50);
	   DECLARE v2 ENUM('M', 'A', 'B1', 'B', 'C1', 'C', 'D1', 'D', 'BE', 'C1E', 'CE', 'D1E', 'DE', 'T', 'F');
	   SELECT name, licence_type_required INTO v1, v2
	       FROM model M WHERE M.id = NEW.model_id;
	   SET NEW.model_name = v1;
	   SET NEW.licence_type_required = v2;
END //

create trigger invoice_trigger_u
 before update on invoice
 for each row
 begin
    signal SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'It is not allowed to change data of an invoice!';
end //

create trigger invoice_trigger_d
 before delete on invoice
 for each row
 begin
    signal SQLSTATE VALUE '45000' SET MESSAGE_TEXT = 'It is not allowed to delete an invoice!';
end //

CREATE TRIGGER model_trigger_i BEFORE INSERT ON model FOR EACH ROW
BEGIN
	   IF NEW.car_brand_name NOT IN (
	      SELECT B.name FROM brand B
	   ) THEN
	      set @message = concat('Cannot insert. In table brand there is no brand named: ', new.car_brand_name);
	      signal SQLSTATE VALUE '45000' SET MESSAGE_TEXT = @message;
	   END IF;
	  
	   IF NEW.car_type_name NOT IN (
	      SELECT CT.name FROM car_type CT
	   ) THEN
	      set @message = concat('Cannot insert. In table car_type there is no type named: ', new.car_type_name);
	      signal SQLSTATE VALUE '45000' SET MESSAGE_TEXT = @message;
	   END IF;
END //

CREATE TRIGGER model_trigger_u BEFORE UPDATE ON model FOR EACH ROW
BEGIN
	   IF NEW.car_brand_name NOT IN (
	      SELECT B.name FROM brand B
	   ) THEN
	      set @message = concat('Cannot insert. In table brand there is no brand named: ', new.car_brand_name);
	      signal SQLSTATE VALUE '45000' SET MESSAGE_TEXT = @message;
	   END IF;
	  
	   IF NEW.car_type_name NOT IN (
	      SELECT CT.name FROM car_type CT
	   ) THEN
	      set @message = concat('Cannot insert. In table car_type there is no type named: ', new.car_type_name);
	      signal SQLSTATE VALUE '45000' SET MESSAGE_TEXT = @message;
	   END IF;
END //

CREATE TRIGGER check_car_availability BEFORE INSERT ON rental_order FOR EACH ROW
BEGIN
    DECLARE v_car_state VARCHAR(50);

    SELECT state INTO v_car_state FROM car
    WHERE id = NEW.car_id;

    IF v_car_state != 'available' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Car is not available!';
    END IF;
END //

CREATE TRIGGER renting_car AFTER INSERT ON rental_order FOR EACH ROW
BEGIN
       UPDATE rental_order
       SET is_finished = 0, start_date_time = NOW()
       WHERE id = NEW.id;
       UPDATE car
       SET state = 'rented'
       WHERE id = NEW.car_id;
END //

CREATE TRIGGER finished_rent AFTER UPDATE ON rental_order FOR EACH ROW
BEGIN
       UPDATE rental_order
       SET is_finished = 1, end_date_time = NOW()
       WHERE id = NEW.id;
       UPDATE car
       SET state = 'available'
       WHERE id = new.car_id;
END //

delimiter ;



