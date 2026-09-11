import 'package:equatable/equatable.dart';

class FundStats extends Equatable {
  const FundStats({
    required this.balance,
    required this.totalDonations,
    required this.pendingAidsCount,
    required this.aidsDistributedNo,
    required this.aidsDistributedAmount,
  });

  factory FundStats.fromJson(Map<String, dynamic> json) {
    return FundStats(
      balance: (json['balance'] as num).toDouble(),
      totalDonations: (json['total_donations'] as num).toDouble(),
      pendingAidsCount: json['pending_aids_count'] as int,
      aidsDistributedNo: json['aids_distributed_no'] as int,
      aidsDistributedAmount:
          (json['aids_distributed_amount'] as num).toDouble(),
    );
  }

  final double balance;
  final double totalDonations;
  final int pendingAidsCount;
  final int aidsDistributedNo;
  final double aidsDistributedAmount;

  @override
  List<Object?> get props => [
        balance,
        totalDonations,
        pendingAidsCount,
        aidsDistributedNo,
        aidsDistributedAmount,
      ];
}

class DonationModel extends Equatable {
  const DonationModel({
    required this.donorId,
    required this.donorName,
    required this.donorRole,
    required this.date,
    required this.paymentMethod,
    required this.amount,
    required this.imageUrl,
    required this.status,
    this.transactionId,
  });

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      donorId: json['donor_id'].toString(),
      donorName: (json['donor_name'] as String?) ?? 'Anonymous',
      donorRole: (json['donor_role'] as String?) ?? 'family',
      date: json['created_at'] as String,
      paymentMethod: json['payment_method'] as String,
      amount: '৳ ${json['amount']}',
      imageUrl: (json['profile_image_url'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'completed',
      transactionId: (json['transaction_id'] as String?),
    );
  }

  final String donorId;
  final String donorName;
  final String donorRole;
  final String date;
  final String paymentMethod;
  final String amount;
  final String imageUrl;
  final String status;
  final String? transactionId;

  @override
  List<Object?> get props => [
        donorId,
        donorName,
        donorRole,
        date,
        paymentMethod,
        amount,
        imageUrl,
        status,
        transactionId,
      ];
}

class AidRequestModel extends Equatable {
  const AidRequestModel({
    required this.id,
    required this.requesterName,
    required this.caregiverType,
    required this.reason,
    required this.date,
    required this.amount,
    required this.status,
    this.documentUrl,
  });

  factory AidRequestModel.fromJson(Map<String, dynamic> json) {
    return AidRequestModel(
      id: json['id'] as int,
      requesterName: (json['requester_name'] as String?) ?? 'Unknown',
      caregiverType: json['caregiver_type'] as String,
      reason: json['reason'] as String,
      date: json['created_at'] as String,
      amount: '৳ ${json['approved_amount']}',
      status: json['status'] as String,
      documentUrl: json['document_url'] as String?,
    );
  }

  final int id;
  final String requesterName;
  final String caregiverType;
  final String reason;
  final String date;
  final String amount;
  final String status;
  final String? documentUrl;

  @override
  List<Object?> get props => [
        id,
        requesterName,
        caregiverType,
        reason,
        date,
        amount,
        status,
        documentUrl,
      ];
}

enum TransactionType { disbursement, donation }

class TransactionModel extends Equatable {
  const TransactionModel({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    required this.type,
    this.transactionId,
  });

  final String title;
  final String subtitle;
  final String amount;
  final String status;
  final TransactionType type;
  final String? transactionId;

  @override
  List<Object?> get props => [title, subtitle, amount, status, type, transactionId];
}
