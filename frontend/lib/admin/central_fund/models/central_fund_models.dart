class DonationModel {
  final String donorName;
  final String date;
  final String paymentMethod;
  final String amount;
  final String imageUrl;

  const DonationModel({
    required this.donorName,
    required this.date,
    required this.paymentMethod,
    required this.amount,
    required this.imageUrl,
  });
}

class AidRequestModel {
  final String requesterName;
  final String requestTitle;
  final String note;
  final String date;
  final String amount;
  final String status; // PENDING, APPROVED

  const AidRequestModel({
    required this.requesterName,
    required this.requestTitle,
    required this.note,
    required this.date,
    required this.amount,
    required this.status,
  });
}

enum TransactionType { disbursement, donation }

class TransactionModel {
  final String title;
  final String subtitle;
  final String amount;
  final String status;
  final TransactionType type;

  const TransactionModel({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    required this.type,
  });
}