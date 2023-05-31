class Invoice{
  final int invoiceId;
  final double total;
  final int nip;
  final String customerName;
  final  String customerSurname;

  Invoice({
    required this.invoiceId,
    required this.total,
    required this.nip,
    required this.customerName,
    required this.customerSurname
  });
}