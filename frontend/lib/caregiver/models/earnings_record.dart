import 'package:equatable/equatable.dart';

class EarningsRecord extends Equatable {
  const EarningsRecord({
    required this.id,
    required this.amount,
    required this.fromWho,
    required this.patientName,
    required this.date,
    required this.paymentMethod,
  });

  final String id;
  final double amount;
  final String fromWho;
  final String patientName;
  final DateTime date;
  final String paymentMethod;

  @override
  List<Object?> get props => [id, amount, fromWho, patientName, date, paymentMethod];
}
