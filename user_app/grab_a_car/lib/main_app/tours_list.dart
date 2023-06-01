import 'package:flutter/material.dart';
import 'package:grab_a_car/database/base_connector.dart';
import '../data/invoice.dart';
import '../data/rental_order.dart';
import '../data/car.dart';
import 'connector_utils.dart';
import 'car_details.dart';
import 'invoice_details.dart';

class ToursList extends StatelessWidget {
  final BaseConnector connector;

  const ToursList({super.key, required this.connector});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: <Widget>[
              Tab(text: 'present',),
              Tab(text: 'finished',),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            __RentalOrderList(connector: connector, whichOrders: true),
            __RentalOrderList(connector: connector, whichOrders: false),
          ],
        ),
      ),
    );
  }
}

class __RentalOrderList extends StatefulWidget {
  final BaseConnector connector;
  final bool whichOrders; // true for present, false for finished

  const __RentalOrderList({required this.connector, required this.whichOrders});

  @override
  State<__RentalOrderList> createState() => __RentalOrderListState();
}

class __RentalOrderListState extends State<__RentalOrderList> {
  List<RentalOrder> orders = [];

  @override
  initState(){
    super.initState();
    initOrders();
  }

  void initOrders(){
    orders = widget.whichOrders ?
    widget.connector.presentOrders.values.toList() :
    widget.connector.finishedOrders.values.toList();
    orders.sort((RentalOrder a, RentalOrder b) => b.startTime.compareTo(a.startTime));
  }

    @override
    Widget build(BuildContext context) {
      return ListView.builder(
        itemCount: orders.length,
        itemBuilder: (BuildContext context, int index) {
          RentalOrder order = orders[index];
          return ListTile(
            title: Text('Order ID: ${order.id}'),
            subtitle: Text('Start Time: ${order.startTime}'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>  __RentalOrderDetails(order: order, connector: widget.connector,),
            ),).then((value) =>
              setState((){
                initOrders();
              })
            ),
          );
        },
      );
    }
}

class __RentalOrderDetails extends StatelessWidget {
  final RentalOrder order;
  final BaseConnector connector;

  const __RentalOrderDetails({required this.order, required this.connector});

  @override
  Widget build(BuildContext context) {
    const TextStyle styleLeft = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    const TextStyle styleRight = TextStyle(fontSize: 16);
    const hspace = SizedBox(height: 8);
    const wspace = SizedBox(width: 4);

    final Column infoColumn = Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Order ID: ', style: styleLeft),
                wspace,
                Text('${order.id}', style: styleRight),
              ],
            ),
            hspace,
            Row(
              children: [
                const Text('Is Finished: ', style: styleLeft),
                wspace,
                Text(order.isFinished ? 'Yes' : 'No', style: styleRight),
              ],
            ),
            hspace,
            Row(
              children: [
                const Text('Fee Rate: ', style: styleLeft),
                wspace,
                Text('${order.feeRate}', style: styleRight),
              ],
            ),
            hspace,
            Row(
              children: [
                const Text('Start Time: ', style: styleLeft),
                wspace,
                Text('${order.startTime}', style: styleRight),
              ],
            ),
            hspace,
            Row(
              children: [
                const Text('End Time: ', style: styleLeft),
                wspace,
                Text('${order.endTime ?? 'Not available'}', style: styleRight),
              ],
            ),
            hspace,
            Row(
              children: [
                const Text('Car ID: ', style: styleLeft),
                wspace,
                Text('${order.carId}', style: styleRight),
              ],
            ),
            hspace,
            Row(
              children: [
                const Text('Invoice ID: ', style: styleLeft),
                wspace,
                Text('${order.invoiceID ?? 'Not assigned'}', style: styleRight),
              ],
            ),
          ],
        ),
        if(!order.isFinished)
          OutlinedButton(
            onPressed: () {
              Future<bool> future = connector.finishRentalOrder(order.id);
              showFutureDialog(
                  future: future,
                  context: context,
                  progressInfo: 'Finishing tour, please wait',
                  failedInfo: 'Unable to finish tour. Please check your internet connection and try again later',
                  successInfo: 'Tour finished');
            },
            child: Text('Finish Tour'),
          )
      ],
    );

    List<Widget> buttons = [];

    Car? car = connector.cars[order.carId];
    if(car != null){
      buttons.add(
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CarDetails(
                  car: car,
                  connector: connector,
                  rentAvailability: false,
                ),
              ),
            ),
            child: const Text('See car info'),
          )
      );
    }

    if(order.invoiceID != null){
      Invoice? invoice = connector.invoices[order.invoiceID];
      if(invoice != null){
        buttons.add(
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>  InvoiceDetails(invoice: invoice),
                ),
              ),
              child: const Text('See Invoice'),
            )
        );
      }
    }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Order Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(child: infoColumn),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: buttons,
              )
            ],
          )
        ),
      );
  }
}






