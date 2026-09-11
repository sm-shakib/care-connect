import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/network/api_client.dart';
import '../../models/central_fund_models.dart';

class CentralFundRepository {
  final ApiClient _apiClient;

  CentralFundRepository(this._apiClient);

  Future<FundStats> getFundStats() async {
    final response = await _apiClient.get(ApiConstants.fundStats);
    return FundStats.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<DonationModel>> getDonations() async {
    final response = await _apiClient.get(ApiConstants.fundAdminDonations); 
    return (response.data as List)
        .map((json) => DonationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<DonationModel>> getMyDonations() async {
    final response = await _apiClient.get(ApiConstants.fundMyDonations); 
    return (response.data as List)
        .map((json) => DonationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<AidRequestModel>> getAidRequests({String? status}) async {
    final queryParams = status != null ? {'status': status} : null;
    final response = await _apiClient.get(ApiConstants.fundAdminRequests, queryParameters: queryParams);
    return (response.data as List)
        .map((json) => AidRequestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> reviewAidRequest(int id, {required String status, double? approvedAmount, String? notes}) async {
    await _apiClient.patch(
      ApiConstants.fundAdminReviewRequest(id),
      data: {
        'status': status,
        if (approvedAmount != null) 'approved_amount': approvedAmount,
        if (notes != null) 'admin_notes': notes,
      },
    );
  }

  Future<void> donate({required double amount, required String method, String? transactionId}) async {
    await _apiClient.post(
      ApiConstants.fundDonate,
      data: {
        'amount': amount,
        'payment_method': method,
        if (transactionId != null) 'transaction_id': transactionId,
      },
    );
  }

  Future<void> requestAid({required String caregiverType, required String reason, String? documentUrl}) async {
    await _apiClient.post(
      ApiConstants.fundRequestAid,
      data: {
        'caregiver_type': caregiverType,
        'reason': reason,
        if (documentUrl != null) 'document_url': documentUrl,
      },
    );
  }

  Future<Map<String, dynamic>> initializeBkashDonation(double amount) async {
    final response = await _apiClient.post(
      ApiConstants.fundBkashCreate,
      data: {'amount': amount, 'payment_method': 'bkash'},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> executeBkashDonation(String paymentId, int donationId) async {
    await _apiClient.post(
      ApiConstants.fundBkashExecute,
      queryParameters: {
        'payment_id': paymentId,
        'donation_id': donationId,
      },
    );
  }
}
