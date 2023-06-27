import 'dart:async';
import 'package:mysql1/mysql1.dart';
import '../data/car.dart';
import '../data/rental_order.dart';
import '../data/invoice.dart';
import '../data/customer.dart';
import 'package:latlong2/latlong.dart';
import 'package:tuple/tuple.dart';
import 'connection_provider.dart';

class __ModelParameters{
  String? color;
  GearboxType? gearboxType;
  FuelType? fuelType;
  int? seatsNumber;

  __ModelParameters({
    this.color,
    this.gearboxType,
    this.fuelType,
    this.seatsNumber
  });
}

class BaseConnector{
  final int __customerId;
  Map<int, Car> __cars = {};
  Map<int, RentalOrder> __presentOrders  = {};
  Map<int, RentalOrder> __finishedOrders  = {};
  Map<int, Invoice> __invoices  = {};
  Customer __customer =  Customer(name: '', surname: '', email: '');


  Map<int, Car> get cars => __cars;
  Map<int, RentalOrder> get presentOrders => __presentOrders;
  Map<int, RentalOrder> get finishedOrders => __finishedOrders;
  Map<int, Invoice> get invoices => __invoices;
  Customer get customer => __customer;

  BaseConnector.__privateConstructor(this.__customerId);

  static Future<BaseConnector?> createBaseConnector(int customerId) async{
    BaseConnector connector = BaseConnector.__privateConstructor(customerId);

    if(await connector.refreshCars() && await connector.refreshOrders() &&
        await connector.refreshInvoices() && await connector.refreshCustomer())
    {
      return connector;
    }
    return null;
  }

  Future<bool> refreshCars() async{
    Map<int, Car>? carsMap = await __downloadCars();
    if(carsMap == null) return false;
    __cars = carsMap;
    return true;
  }
  Future<bool> refreshOrders() async{
    Tuple2<Map<int, RentalOrder>, Map<int, RentalOrder>>? allOrders  = await __downloadRentalOrders();

    if(allOrders == null) return false;
    __presentOrders = allOrders.item1;
    __finishedOrders = allOrders.item2;
    return true;
  }
  Future<bool> refreshInvoices() async{
    Map<int, Invoice>? invoicesMap  = await __downloadInvoices();
    if(invoicesMap == null) return false;
    __invoices = invoicesMap;
    return true;
  }
  Future<bool> refreshCustomer() async{
    Customer? customer = await __downloadCustomer();
    if(customer == null) return false;
    __customer = customer;
    return true;
  }


  Future <Map<int, Car>?> __downloadCars() async{
    final MySqlConnection? conn = await ConnectionProvider.getConnection();
    if(conn == null){ return null;}
    Map<int, Car> carsMap = {};
    try {
      Map<int, __ModelParameters> models = {};
      var result = await conn.query(''
          'SELECT C.id as carId, C.model_name as modelName, C.model_id as modelId, '
          '  C.licence_type_required as licenceTypeRequired, C.locationX as x,'
          '  C.locationY as y,  C.state as state, M.car_brand_name as carBrandName, '
          '  M.car_type_name as carTypeName, M.fee_rate as fee_rate '
          'FROM car C inner JOIN model M on C.model_id = M.id');

      for (var row in result) {
        CarState carState = CarState.available;
        LicenceTypeRequired licenceTypeRequired = LicenceTypeRequired.A;
        int modelId = row['modelId'] as int;
        __ModelParameters modelParams;

        __ModelParameters? tmp = models[modelId];
        if (tmp != null) {
          modelParams = tmp;
        }
        else {
          modelParams = __ModelParameters();
          var result = await conn.query(''
              'SELECT P.name as pname, P.type as ptype, '
              'MP.text_value as text_value, MP.numerical_value as numerical_value '
              'FROM parameter P INNER JOIN model_parameter MP  '
              'ON P.id = MP.parameter_id '
              'WHERE MP.model_id = ?', [modelId]);
          for (var row in result) {
            String pname = row['pname'] as String;
            String? textValue = row['text_value'] as String?;
            int? numericalValue = row['numerical_value'] as int?;
            if (pname == 'color') {
              modelParams.color = textValue;
            } else if (pname == 'gearbox_type') {
              switch (textValue) {
                case 'manual':
                  modelParams.gearboxType = GearboxType.manual;
                  break;
                case 'automatic':
                  modelParams.gearboxType = GearboxType.automatic;
                  break;
                default:
                  throw Exception('Invalid value in database.');
              }
            } else if (pname == 'fuel_type') {
              switch (textValue) {
                case 'diesel':
                  modelParams.fuelType = FuelType.diesel;
                  break;
                case 'gasoline':
                  modelParams.fuelType = FuelType.gasoline;
                  break;
                default:
                  throw Exception('Invalid value in database.');
              }
            } else if (pname == 'seat_number') {
              modelParams.seatsNumber = numericalValue;
            }
          }
          models[modelId] = modelParams;
        }


        switch (row['state'] as String) {
          case 'available':
            carState = CarState.available;
            break;
          case 'rented':
            carState = CarState.rented;
            break;
          case 'issues':
            carState = CarState.issues;
            break;
          case 'decommissioned':
            carState = CarState.decommissioned;
            break;
          default:
            throw Exception('Invalid state value in database.');
        }

        switch (row['licenceTypeRequired']) {
          case 'M':
            licenceTypeRequired = LicenceTypeRequired.M;
            break;
          case 'A':
            licenceTypeRequired = LicenceTypeRequired.A;
            break;
          case 'B1':
            licenceTypeRequired = LicenceTypeRequired.B1;
            break;
          case 'B':
            licenceTypeRequired = LicenceTypeRequired.B;
            break;
          case 'C1':
            licenceTypeRequired = LicenceTypeRequired.C1;
            break;
          case 'C':
            licenceTypeRequired = LicenceTypeRequired.C;
            break;
          case 'D1':
            licenceTypeRequired = LicenceTypeRequired.D1;
            break;
          case 'D':
            licenceTypeRequired = LicenceTypeRequired.D;
            break;
          case 'BE':
            licenceTypeRequired = LicenceTypeRequired.BE;
            break;
          case 'C1E':
            licenceTypeRequired = LicenceTypeRequired.C1E;
            break;
          case 'CE':
            licenceTypeRequired = LicenceTypeRequired.CE;
            break;
          case 'D1E':
            licenceTypeRequired = LicenceTypeRequired.D1E;
            break;
          case 'DE':
            licenceTypeRequired = LicenceTypeRequired.DE;
            break;
          case 'T':
            licenceTypeRequired = LicenceTypeRequired.T;
            break;
          case 'F':
            licenceTypeRequired = LicenceTypeRequired.F;
            break;
          default:
            throw Exception('Invalid licence_type_required value in database.');
        }


        carsMap[row['carId'] as int] = Car(
            id: row['carId'] as int,
            licenceTypeRequired: licenceTypeRequired,
            position: LatLng(row['x'] as double, row['y'] as double),
            state: carState,
            modelName: row['modelName'] as String,
            carBrandName: row['carBrandName'] as String,
            carTypeName: row['carTypeName'] as String,
            fee_rate: row['fee_rate'] as double,
            color: modelParams.color,
            gearboxType: modelParams.gearboxType,
            fuelType: modelParams.fuelType,
            seatsNumber: modelParams.seatsNumber,
        );
      }

    }catch(e){
      return null;
    }finally{
      await conn.close();
    }
    return carsMap;
  }

  Future<Tuple2<Map<int, RentalOrder>, Map<int, RentalOrder>>?> __downloadRentalOrders() async {
    final MySqlConnection? conn = await ConnectionProvider.getConnection();
    if(conn == null) return null;
    Map<int, RentalOrder> allOrders = {};

    try {
      var result = await conn.query(
          'SELECT id, is_finished, price, start_date_time, end_date_time, '
              'car_id, invoice_id '
              'FROM rental_order WHERE customer_id = ?', [__customerId]);

      for (var row in result) {
        allOrders[row['id'] as int] = RentalOrder(
            id: row['id'] as int,
            isFinished: row['is_finished'] == 1 ? true : false,
            price: row['price'] as double,
            startTime: row['start_date_time'] as DateTime,
            endTime: row['end_date_time'] as DateTime?,
            carId: row['car_id'] as int,
            invoiceID: row['invoice_id'] as int?,
          );
      }
    }catch(e){
      return null;
    }finally{
      await conn.close();
    }

    Map<int, RentalOrder> finishedOrders = {};
    Map<int, RentalOrder> presentOrders = {};
    allOrders.forEach((int orderId, RentalOrder order) {
      if(order.isFinished) { finishedOrders[orderId] = order;}
      else { presentOrders[orderId] = order;}
    });

    return Tuple2(presentOrders, finishedOrders);
  }

  Future<Map<int, Invoice>?> __downloadInvoices() async {
    final MySqlConnection? conn = await ConnectionProvider.getConnection();
    if(conn == null) return null;

    Map<int, Invoice> invoiceMap = {};
    try {
      var result = await conn.query(''
        'SELECT I.invoice_id as invoiceID, I.total as total, I.nip as nip, '
        '   I.customer_name as customerName,'
        '   I.customer_surname as customerSurname '
        'FROM invoice I JOIN rental_order R ON I.invoice_id = R.invoice_id '
        'WHERE R.customer_id = ?', [__customerId]);

      for (var row in result) {
        invoiceMap[row['invoiceID'] as int] = Invoice(
            invoiceId: row['invoiceID'] as int,
            total: row['total'] as double,
            nip: row['nip'] as int,
            customerName: row['customerName'] as String,
            customerSurname: row['customerSurname'] as String,
          );
      }

    }catch(e){
      return null;
    }finally{
      await conn.close();
    }
    return invoiceMap;
  }

  Future<Customer?> __downloadCustomer() async {
    final MySqlConnection? conn = await ConnectionProvider.getConnection();
    if(conn == null) return null;

    try {
      var result = await conn.query(''
          'SELECT name, surname, email FROM customer WHERE id = ?', [__customerId]);
      var row = result.first;

      return Customer(
        name: row['name'],
        surname: row['surname'],
        email: row['email']
      );
    }catch (e) {
      return null;
    }finally{
      await conn.close();
    }
  }

  Future<bool> updateCustomer(Customer customer) async {
    final MySqlConnection? conn = await ConnectionProvider.getConnection();
    if(conn == null) return false;

    try {
      var result = await conn.query(
        'UPDATE customer SET name = ?, surname = ?, email = ? WHERE id = ?',
        [customer.name, customer.surname, customer.email, __customerId],
      );
      int? affectedRows = result.affectedRows;
      if (affectedRows == null) return false;

      if (affectedRows > 0) {
        __customer = customer;
        return true;
      }
    } catch (e) {
      return false;
    } finally {
      await conn.close();
    }
    return false;
  }

  Future<bool> insertRentalOrder(int carId) async {
    final MySqlConnection? conn = await ConnectionProvider.getConnection();
    if(conn == null) return false;

    try {
      DateTime now = DateTime.now();
      var result = await conn.query(
        'INSERT INTO rental_order (car_id, customer_id) VALUES (?, ?)',
        [carId, __customerId],
      );
      int? resultId = result.insertId;
      if (resultId != null) {
        __presentOrders[resultId] = RentalOrder(
          id: resultId,
          isFinished: false,
          price: 0.0,
          startTime: now,
          endTime: null,
          carId: carId,
          invoiceID: null,
        );
        __cars[carId]?.state = CarState.rented;
        return true;
      }
    } catch (e) {
      return false;
    } finally {
      await conn.close();
    }
    return false;
  }

  Future<bool> finishRentalOrder(int orderId, int carId) async {
    final MySqlConnection? conn = await ConnectionProvider.getConnection();
    if(conn == null) return false;
    DateTime now = DateTime.now();
    try {
      var result = await conn.query(
        'UPDATE rental_order SET is_finished = ? WHERE id = ?',
        [1, orderId],
      );
      int? affectedRows = result.affectedRows;
      if(affectedRows == null || affectedRows<=0) return false;

      if(await refreshOrders()){

        __cars[carId]?.state = CarState.available;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      await conn.close();
    }
  }

}