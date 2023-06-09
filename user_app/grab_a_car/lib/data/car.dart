import 'package:latlong2/latlong.dart';

enum GearboxType{manual, automatic}
enum FuelType{diesel, gasoline}
enum CarState{available, rented, issues, decommissioned}
enum LicenceTypeRequired{M, A, B1, B, C1, C, D1, D, BE, C1E, CE, D1E, DE, T, F}

class Car{
  final int id;
  LicenceTypeRequired licenceTypeRequired;
  LatLng position;
  CarState state;
  final String modelName;
  final String carBrandName;
  final String carTypeName;
  final double fee_rate;
  final String? color;
  final GearboxType? gearboxType;
  final FuelType? fuelType;
  final int? seatsNumber;

  Car({
    required this.id,
    required this.licenceTypeRequired,
    required this.position,
    required this.state,
    required this.modelName,
    required this.carBrandName,
    required this.carTypeName,
    required this.fee_rate,
    this.color,
    this.gearboxType,
    this.fuelType,
    this.seatsNumber
  });
}