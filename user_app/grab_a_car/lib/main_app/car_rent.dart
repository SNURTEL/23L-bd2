import 'package:flutter/material.dart';
import '../data/car.dart';
import '../database/base_connector.dart';
import 'connector_utils.dart';

class CarRent extends StatelessWidget {
  final Car car;
  BaseConnector connector;
  bool rentAvailability;

  CarRent({super.key, required this.connector, required this.car,
    required this.rentAvailability,});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Car Details'),
      ),
      body: Column(children: [
        Expanded(child: _CarDetails(car: car)),
        if(car.state == CarState.available && rentAvailability)
          ElevatedButton(onPressed: (){
            final Future<bool> future = connector.insertRentalOrder(car.id);
            showFutureDialog(
              future: future,
              context: context,
              progressInfo: 'Starting car rent, please wait.',
              failedInfo: 'Unable to start car rent.\n'
                'Please check your internet connection address and try again later.',
              successInfo: 'Tour started!',
            );
          }, child: const Text('Rent'))
      ],),
    );
  }
}

/*
FutureBuilder<void>(
                  future: success,
                  builder: (BuildContext context, snapshot)  {
                    return Center(child: Text('Ala ma kota'));
                  }
              )
 */

class _CarDetails extends StatelessWidget {
  final Car car;

  const _CarDetails({required this.car});

  @override
  Widget build(BuildContext context) {

    const leftStyle = TextStyle(fontSize: 16,fontWeight: FontWeight.bold);
    const rightStyle = TextStyle(fontSize: 16);

    return  Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text ('Car ID:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  '${car.id}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text ('Model:', style : leftStyle),
                const SizedBox(width: 8),
                Text( car.modelName, style : rightStyle),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text ('Brand:', style : leftStyle),
                const SizedBox(width: 8),
                Text(car.carBrandName, style : rightStyle),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text ('Type:', style : leftStyle),
                const SizedBox(width: 8),
                Text(car.carTypeName, style: rightStyle,),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text ('Color:', style : leftStyle),
                const SizedBox(width: 8),
                Text(car.color ?? 'N/A', style: rightStyle),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text ('Gearbox:', style : leftStyle),
                const SizedBox(width: 8),
                Text(car.gearboxType?.name ?? 'N/A', style: rightStyle,),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text ('Fuel Type:', style : leftStyle),
                const SizedBox(width: 8),
                Text(car.fuelType?.name ?? 'N/A', style: rightStyle,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text ('Seats:', style : leftStyle),
                const SizedBox(width: 8),
                Text('${car.seatsNumber ?? 'N/A'}', style: rightStyle),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text ('License Type Required:', style : leftStyle),
                const SizedBox(width: 8),
                Text(car.licenceTypeRequired.name, style: rightStyle,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('State:', style : leftStyle),
                const SizedBox(width: 8),
                Text(car.state.name, style: rightStyle,)
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Position:', style : leftStyle),
                const SizedBox(width: 8),
                Text(
                    '${car.position.longitude} N '
                        '${car.position.latitude} E',
                    style: rightStyle),
              ],
            ),
          ],
        ),
    );
  }
}