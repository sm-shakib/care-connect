import 'package:equatable/equatable.dart';

enum PaymentMethod { bkash, nagad, rocket, bank, cash }

class Donation extends Equatable {
  const Donation({
    required this.id,
    required this.amount,
    required this.method,
    required this.date,
    required this.status,
  });

  final String id;
  final double amount;
  final PaymentMethod method;
  final DateTime date;
  final String status;

  @override
  List<Object?> get props => [id, amount, method, date, status];
}
