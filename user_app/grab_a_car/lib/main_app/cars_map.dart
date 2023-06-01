import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/car.dart';
import '../database/base_connector.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'car_details.dart';

class CarMap extends StatefulWidget {
  final BaseConnector connector;
  final LatLng userPosition = LatLng(52.219158, 21.012215);

  CarMap({super.key, required this.connector});

  @override
  _CarMapState createState() => _CarMapState();
}

class _CarMapState extends State<CarMap> {
  List<Marker> markersList = [];

  final distanceTextController = TextEditingController();
  final carBrandNameController = TextEditingController();
  final carTypeNameController = TextEditingController();
  final seatsTextController = TextEditingController();
  double? maxDistance;
  int? seatsNumber;
  List<GearboxType?> selectedGearboxTypes = [];
  List<LicenceTypeRequired?> selectedLicenceTypesRequired = [];
  List<FuelType?> selectedFuelTypes = [];
  List<CarState?> selectedCarStates = [];


  @override
  void initState() {
    markersList = createMarkersList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final MapController mapController = MapController();
    return Stack(
      alignment: Alignment.topCenter,
      children: [
          FlutterMap(
            options: MapOptions(
                center: LatLng(52.229790, 21.011872),
                zoom: 15.0,
                maxBounds: LatLngBounds(LatLng(52.601076, 20.391374), LatLng(51.869359, 21.660594)),
                maxZoom: 18.0
            ),
            mapController: mapController,
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                  markers: markersList
              ),
            ],
          ),
       ExpansionTile(
          title: const Text('Filters'),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,

          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'max distance',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: distanceTextController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'car type',
              ),
              controller: carTypeNameController,
            ),
            TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'brand name',
              ),
              controller: carBrandNameController,
            ),
            TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'seats numbers',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: seatsTextController,
            ),
            MultiSelectChipField<GearboxType?>(
              title: const Text('gearbox type'),
              items: <MultiSelectItem<GearboxType>>[
                MultiSelectItem<GearboxType>(GearboxType.manual, 'manual'),
                MultiSelectItem<GearboxType>(GearboxType.automatic, 'automatic'),
              ],
              selectedChipColor: Colors.green,
              icon: const Icon(Icons.check, color: Colors.white),
              onTap: (List<GearboxType?> selectedValues){
                selectedGearboxTypes = selectedValues;
              },
              initialValue: selectedGearboxTypes,
            ),
            MultiSelectChipField<LicenceTypeRequired?>(
              title: const Text('licence type required'),
              items: LicenceTypeRequired.values.map((e) => MultiSelectItem(e, e.name)).toList(),
              selectedChipColor: Colors.green,
              icon: const Icon(Icons.check, color: Colors.white),
              onTap: (List<LicenceTypeRequired?> selectedValues){
                selectedLicenceTypesRequired = selectedValues;
              },
              initialValue: selectedLicenceTypesRequired,
            ),
            MultiSelectChipField<FuelType?>(
              title: const Text('fueal type'),
              items: <MultiSelectItem<FuelType>>[
                MultiSelectItem<FuelType>(FuelType.diesel, 'diesel'),
                MultiSelectItem<FuelType>(FuelType.gasoline, 'automatic'),
              ],
              selectedChipColor: Colors.green,
              icon: const Icon(Icons.check, color: Colors.white),
              onTap: (List<FuelType?> selectedValues){
                selectedFuelTypes = selectedValues;
              },
              initialValue: selectedFuelTypes,
            ),
          ],
         onExpansionChanged: (bool expanding){
            if(expanding) return;
            List<Marker> newMarkersList = createMarkersList();
            setState(() {
              markersList = newMarkersList;
            });
         },
        ),
        Align(
         alignment: Alignment.bottomRight,
         child: Padding(
           padding: const EdgeInsets.fromLTRB(0, 0, 15.0, 15.0),
           child: IconButton(
             icon: const Icon(Icons.arrow_circle_up_sharp, size: 40, weight: 30.0),
             onPressed: () => mapController.rotate(0),
           ),
         )
       )
      ],
    );
  }

  List<Marker> createMarkersList(){
    if(distanceTextController.text.isEmpty){ maxDistance = null;}
    else {
      try {
        maxDistance = double.parse(distanceTextController.text);
      } catch (e) {
        maxDistance = null;
      }
    }
    if(seatsTextController.text.isEmpty){seatsNumber = null;}
    else{
      try {
        seatsNumber = int.parse(seatsTextController.text);
      } catch (e) {
        seatsNumber = null;
      }
    }

    List<Marker> newMarkersList = [
      Marker(
        point: widget.userPosition,
        builder: (context) => const Icon(Icons.person, color: Colors.blue),
      )
    ];
    final List<Car> carList = widget.connector.cars.values.toList();
    for(Car car in carList){
      if(testCar(car)){
        Color carColor = Colors.red;
        if(car.state == CarState.available){ carColor = Colors.black;}
        else if(car.state == CarState.rented){ carColor = Colors.blue;}

        newMarkersList.add(
            Marker(
              point: car.position,
              builder: (context) => IconButton(
                icon:  Icon(Icons.directions_car, color: carColor),
                tooltip: 'See car info',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CarDetails(
                        car: car,
                        connector: widget.connector,
                        rentAvailability: true,
                      ),
                    ),
                  ).then((_) => {setState((){
                    markersList = createMarkersList();
                  })});
                },
              ),
            )
        );
      }
    }
    return newMarkersList;
  }

  bool testCar(Car car){
    if(maxDistance != null &&
      Geolocator.distanceBetween(
          widget.userPosition.latitude,
          widget.userPosition.longitude,
          car.position.latitude,
          car.position.longitude) > maxDistance!
    ) return false;

    if(carBrandNameController.text.isNotEmpty &&
        !car.carBrandName.contains(carBrandNameController.text)) return false;

    if(carTypeNameController.text.isNotEmpty &&
        !car.carTypeName.contains(carTypeNameController.text)) return false;

    if(seatsNumber != null && seatsNumber != car.seatsNumber) return false;
    
    if(selectedLicenceTypesRequired.isNotEmpty &&
        !selectedLicenceTypesRequired.contains(car.licenceTypeRequired)) return false;

    if(selectedGearboxTypes.isNotEmpty &&
        !selectedGearboxTypes.contains(car.gearboxType)) return false;

    if(selectedFuelTypes.isNotEmpty &&
        !selectedFuelTypes.contains(car.fuelType)) return false;

    if(selectedCarStates.isNotEmpty &&
        !selectedCarStates.contains(car.state)) return false;

    return true;
  }
}