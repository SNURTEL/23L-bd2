import 'package:flutter/material.dart';
import 'data/car.dart';
import 'dart:developer' as developer;
import '../data/rental_order.dart';
import '../data/invoice.dart';
import '../data/customer.dart';

void prettyPrintCars(Map<int, Car>? cars) {
  if(cars == null){
    debugPrint('cars is null'); return;
  }
  for (Car car in cars.values) {
    developer.log(
    'Car Information:\n'
    '----------------------------\n'
    'Car ID: ${car.id}\n'
    'Licence Type Required: ${car.licenceTypeRequired}\n'
    'Position: ${car.position.latitude}, ${car.position.longitude}\n'
    'CarState: ${car.state.toString().split('.').last}\n'
    'Model Name: ${car.modelName}\n'
    'Car Brand Name: ${car.carBrandName}\n'
    'Car Type Name: ${car.carTypeName} \n'
    '${car.color != null ? 'Color is ${car.color}\n' : ''}'
    '${car.gearboxType != null ? 'Drive Type: ${car.gearboxType.toString().split('.').last}\n' : ''}'
    '${car.fuelType != null ? 'Fuel Type: ${car.fuelType.toString().split('.').last}\n' : ''}'
    '${car.seatsNumber != null ? 'Number of Seats: ${car.seatsNumber}\n' : ''}'
    '----------------------------\n\n\n',
    name: 'my.app.category');
  }
}

void debugPrintRentalOrders(Map<int, RentalOrder>? rentalOrders) {
  if (rentalOrders == null) {
    developer.log('rentals are null'); return;
  }
  developer.log(
    'Rental Orders:',
    name: 'my.app.category',
  );

  for (RentalOrder order in rentalOrders.values) {
    developer.log(
      '\n\nRental Order ID: ${order.id}\n'
          'Is Finished: ${order.isFinished}\n'
          'Fee Rate: ${order.price}\n'
          'Start Time: ${order.startTime}\n'
          'End Time: ${order.endTime}\n'
          'Car ID: ${order.carId}\n'
          'Invoice ID: ${order.invoiceID}\n',
      name: 'my.app.category',
    );
  }
}

void debugPrintInvoices(Map<int, Invoice>? invoices) {
  if (invoices == null) {
    developer.log('invoices are null'); return;
  }
  developer.log(
    'Invoices:',
    name: 'my.app.category',
  );

  for (Invoice invoice in invoices.values) {
    developer.log(
      'Invoice ID: ${invoice.invoiceId}\n'
          'Total: ${invoice.total}\n'
          'NIP: ${invoice.nip}\n'
          'Customer Name: ${invoice.customerName}\n'
          'Customer Surname: ${invoice.customerSurname}\n',
      name: 'my.app.category',
    );
  }
}

void debugPrintCustomer(Customer customer) {
  developer.log(
  '--- Customer Info ---\n'
  'Name: ${customer.name}\n'
  'Surname: ${customer.surname}\n'
  'Email: ${customer.email}\n'
  '----------------------\n');
}
