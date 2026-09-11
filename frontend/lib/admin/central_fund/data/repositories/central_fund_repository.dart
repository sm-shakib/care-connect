import 'package:frontend/admin/central_fund/models/central_fund_models.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';

class CentralFundRepository {
  const CentralFundRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<FundStats> getFundStats() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.fundStats,
    );
    return FundStats.fromJson(response.data!);
  }

  Future<List<DonationModel>> getDonations() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.fundAdminDonations,
    );
    return response.data!
        .map((json) => DonationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<DonationModel>> getMyDonations() async {
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.fundMyDonations,
    );
    return response.data!
        .map((json) => DonationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<AidRequestModel>> getMyRequests() async {
    final response = await _apiClient.get<List<dynamic>>('/fund/my-requests');
    return response.data!
        .map((json) => AidRequestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<AidRequestModel>> getAidRequests({String? status}) async {
    final queryParams = status != null ? {'status': status} : null;
    final response = await _apiClient.get<List<dynamic>>(
      ApiConstants.fundAdminRequests,
      queryParameters: queryParams,
    );
    return response.data!
        .map((json) => AidRequestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> reviewAidRequest(
    int id, {
    required String status,
    double? approvedAmount,
    String? notes,
  }) async {
    await _apiClient.patch<void>(
      ApiConstants.fundAdminReviewRequest(id),
      data: {
        'status': status,
        if (approvedAmount != null) 'approved_amount': approvedAmount,
        if (notes != null) 'admin_notes': notes,
      },
    );
  }

  Future<void> donate({
    required double amount,
    required String method,
    String? transactionId,
  }) async {
    await _apiClient.post<void>(
      ApiConstants.fundDonate,
      data: {
        'amount': amount,
        'payment_method': method,
        if (transactionId != null) 'transaction_id': transactionId,
      },
    );
  }

  Future<void> requestAid({
    required String caregiverType,
    required String reason,
    String? serviceStartDate,
    String? serviceEndDate,
    String? daysOfWeek,
    String? dailyTimingStart,
    String? dailyTimingEnd,
    String? documentUrl,
  }) async {
    await _apiClient.post<void>(
      ApiConstants.fundRequestAid,
      data: {
        'caregiver_type': caregiverType,
        'reason': reason,
        'service_start_date': serviceStartDate,
        'service_end_date': serviceEndDate,
        'days_of_week': daysOfWeek,
        'daily_timing_start': dailyTimingStart,
        'daily_timing_end': dailyTimingEnd,
        if (documentUrl != null) 'document_url': documentUrl,
      },
    );
  }

  Future<Map<String, dynamic>> initializeBkashDonation(double amount) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.fundBkashCreate,
      data: {'amount': amount, 'payment_method': 'bkash'},
    );
    return response.data!;
  }

  Future<void> executeBkashDonation(String paymentId, int donationId) async {
    await _apiClient.post<void>(
      ApiConstants.fundBkashExecute(donationId),
      data: {
        'paymentID': paymentId,
      },
    );
  }
}
