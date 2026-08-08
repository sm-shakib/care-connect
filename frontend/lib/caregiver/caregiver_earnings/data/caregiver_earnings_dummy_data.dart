import '../../models/earnings_record.dart';

class CaregiverEarningsDummyData {
  static List<EarningsRecord> get earnings => [
        EarningsRecord(
          id: 'e1',
          amount: 2000,
          fromWho: 'John Doe',
          patientName: 'Abdul Karim',
          date: DateTime.now().subtract(const Duration(days: 2)),
          paymentMethod: 'bKash',
        ),
        EarningsRecord(
          id: 'e2',
          amount: 1250,
          fromWho: 'Ayesha Akhter',
          patientName: 'Rahima Begum',
          date: DateTime.now().subtract(const Duration(days: 15)),
          paymentMethod: 'Bank Transfer',
        ),
        EarningsRecord(
          id: 'e3',
          amount: 1000,
          fromWho: 'Karim Ullah',
          patientName: 'Mrs. Selina Rahman',
          date: DateTime.now().subtract(const Duration(days: 45)),
          paymentMethod: 'Nagad',
        ),
      ];
}
