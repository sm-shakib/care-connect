import 'package:frontend/core/network/api_client.dart';
import '../../models/central_fund_models.dart';

class CentralFundRepository {
  final ApiClient _apiClient;

  CentralFundRepository(this._apiClient);

  Future<FundStats> getFundStats() async {
    final response = await _apiClient.get('/fund/stats');
    return FundStats.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<DonationModel>> getDonations() async {
    final response = await _apiClient.get('/fund/admin/donations'); 
    return (response.data as List)
        .map((json) => DonationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<AidRequestModel>> getAidRequests({String? status}) async {
    final queryParams = status != null ? {'status': status} : null;
    final response = await _apiClient.get('/fund/admin/requests', queryParameters: queryParams);
    return (response.data as List)
        .map((json) => AidRequestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> reviewAidRequest(int id, {required String status, double? approvedAmount, String? notes}) async {
    await _apiClient.patch(
      '/fund/admin/requests/$id/review',
      data: {
        'status': status,
        if (approvedAmount != null) 'approved_amount': approvedAmount,
        if (notes != null) 'admin_notes': notes,
      },
    );
  }

  Future<void> donate({required double amount, required String method, String? transactionId}) async {
    await _apiClient.post(
      '/fund/donate',
      data: {
        'amount': amount,
        'payment_method': method,
        if (transactionId != null) 'transaction_id': transactionId,
      },
    );
  }

  Future<void> requestAid({required String caregiverType, required String reason, String? documentUrl}) async {
    await _apiClient.post(
      '/fund/request-aid',
      data: {
        'caregiver_type': caregiverType,
        'reason': reason,
        if (documentUrl != null) 'document_url': documentUrl,
      },
    );
  }
}
