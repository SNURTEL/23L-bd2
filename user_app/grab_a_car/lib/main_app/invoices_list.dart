import 'package:flutter/material.dart';
import '../data/invoice.dart';
import '../database/base_connector.dart';
import 'invoice_details.dart';

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
                builder: (context) =>  InvoiceDetails(invoice: invoice),
              ),
            );
          },
        );
      },
    );
  }
}