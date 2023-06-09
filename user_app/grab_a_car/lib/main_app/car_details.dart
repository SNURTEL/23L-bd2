import 'package:flutter/material.dart';
import '../data/car.dart';
import '../database/base_connector.dart';
import 'connector_utils.dart';

class CarDetails extends StatelessWidget {
  final Car car;
  final BaseConnector connector;
  final bool rentAvailability;

  const CarDetails({super.key, required this.connector, required this.car,
    required this.rentAvailability,});

  @override
  Widget build(BuildContext context) {
    const leftStyle = TextStyle(fontSize: 16,fontWeight: FontWeight.bold);
    const rightStyle = TextStyle(fontSize: 16);
    const hspace = SizedBox(height: 8);
    const wspace = SizedBox(width: 8);

    return  Scaffold(
      appBar: AppBar(
        title: const Text('Car Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text ('Car ID:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      wspace,
                      Text(
                        '${car.id}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  hspace,
                  Row(
                    children: [
                      const Text ('Model:', style : leftStyle),
                      wspace,
                      Text( car.modelName, style : rightStyle),
                    ],
                  ),
                  hspace,
                  Row(
                    children: [
                      const Text ('Brand:', style : leftStyle),
                      wspace,
                      Text(car.carBrandName, style : rightStyle),
                    ],
                  ),
                  hspace,
                  Row(
                    children: [
                      const Text ('Type:', style : leftStyle),
                      wspace,
                      Text(car.carTypeName, style: rightStyle,),
                    ],
                  ),
                  hspace,
                  Row(
                    children: [
                      const Text ('Color:', style : leftStyle),
                      wspace,
                      Text(car.color ?? '?', style: rightStyle),
                    ],
                  ),
                  hspace,
                  Row(
                    children: [
                      const Text ('Gearbox:', style : leftStyle),
                      wspace,
                      Text(car.gearboxType?.name ?? '?', style: rightStyle,),
                    ],
                  ),
                  hspace,
                  Row(
                    children: [
                      const Text ('Fuel Type:', style : leftStyle),
                      wspace,
                      Text(car.fuelType?.name ?? '?', style: rightStyle,
                      ),
                    ],
                  ),
                  hspace,
                  Row(
                    children: [
                      const Text ('Seats:', style : leftStyle),
                      wspace,
                      Text('${car.seatsNumber ?? '?'}', style: rightStyle),
                    ],
                  ),
                  hspace,
                  Row(
                    children: [
                      const Text ('License Type Required:', style : leftStyle),
                      wspace,
                      Text(car.licenceTypeRequired.name, style: rightStyle,
                      ),
                    ],
                  ),
                  hspace,
                  Row(
                    children: [
                      const Text('State:', style : leftStyle),
                      wspace,
                      Text(car.state.name, style: rightStyle,)
                    ],
                  ),
                  hspace,
                  Row(
                    children: [
                      const Text('Position:', style : leftStyle),
                      wspace,
                      Text(
                          '${car.position.longitude} N '
                              '${car.position.latitude} E',
                          style: rightStyle),
                    ],
                  ),
                  hspace,
                  Row(
                    children: [
                      const Text('Fee Rate (PLN/minute):', style : leftStyle),
                      wspace,
                      Text('${car.fee_rate}', style: rightStyle),
                    ],
                  ),
                ],
              )
          ),
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
      ),
    );
  }
}