class RentalOrder{
  final int id;
  bool isFinished;
  double price;
  final DateTime startTime;
  DateTime? endTime;
  final int carId;
  int? invoiceID;

  RentalOrder({
    required this.id,
    required this.isFinished,
    required this.price,
    required this.startTime,
    this.endTime,
    required this.carId,
    this.invoiceID
  });
}