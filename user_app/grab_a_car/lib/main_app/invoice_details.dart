import 'package:flutter/material.dart';
import '../data/invoice.dart';

class InvoiceDetails extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetails({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    const leftStyle = TextStyle(fontSize: 16,fontWeight: FontWeight.bold);
    const rightStyle = TextStyle(fontSize: 16);
    const hspace = SizedBox(height: 8);
    const wspace = SizedBox(width: 8);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                children: [
                  const Text (
                      'Invoice ID: ',
                      style : TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  wspace,
                  Text(
                      '${invoice.invoiceId}',
                      style : const TextStyle(fontSize: 18, fontWeight: FontWeight.normal)
                  ),
                ]
            ),
            hspace,
            Row(
                children: [
                  const Text ('Total: ', style : leftStyle),
                  wspace,
                  Text('${invoice.total}', style : rightStyle),
                ]
            ),
            hspace,
            Row(
              children: [
                const Text ('NIP: ', style : leftStyle),
                wspace,
                Text('${invoice.nip}', style : rightStyle),
              ],
            ),
            hspace,
            Row(
                children: [
                  const Text ('Customer Name: ', style : leftStyle),
                  wspace,
                  Text( invoice.customerName, style : rightStyle),
                ]
            ),
            hspace,
            Row(
                children: [
                  const Text ('Customer Surname: ', style : leftStyle),
                  wspace,
                  Text( invoice.customerSurname, style : rightStyle),
                ]
            ),
          ],
        ),
      ),
    );
  }
}
