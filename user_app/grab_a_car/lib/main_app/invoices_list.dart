import 'package:flutter/material.dart';
import '../data/invoice.dart';
import '../database/base_connector.dart';

class InvoiceList extends StatelessWidget {
  final List<Invoice> invoices;
  final BaseConnector connector;

  InvoiceList({super.key, required this.connector}):
      invoices = connector.invoices.values.toList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        Invoice invoice = invoices[index];
        return ListTile(
          title: Text('Invoice ID: ${invoice.invoiceId}'),
          subtitle: Text('Total Sum: ${invoice.total.toStringAsFixed(2)}'),
          onTap: (){
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>  __InvoiceDetails(invoice: invoice),
              ),
            );
          },
        );
      },
    );
  }
}


class __InvoiceDetails extends StatelessWidget {
  final Invoice invoice;

  const __InvoiceDetails({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice ID: ${invoice.invoiceId}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Total: ${invoice.total}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'NIP: ${invoice.nip}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Customer Name: ${invoice.customerName}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Customer Surname: ${invoice.customerSurname}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}


