import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/donation/models/donation.dart';

class DonationRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> submitDonation({
    required double amount,
    required String paymentMethod,
    String? transactionId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/donations/',
      data: {
        'amount': amount,
        'payment_method': paymentMethod,
        'transaction_id': transactionId,
      },
    );
    return response.data!;
  }

  Future<String> initializeDonationBkashPayment(int donationId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/donations/$donationId/bkash/create',
    );
    return response.data!['bkashURL'] as String;
  }

  Future<void> executeDonationBkashPayment(int donationId, String paymentId) async {
    await _apiClient.post(
      '/donations/$donationId/bkash/execute',
      data: {'paymentID': paymentId},
    );
  }

  Future<List<Map<String, dynamic>>> getMyDonationHistory() async {
    final response = await _apiClient.get<List<dynamic>>('/donations/me');
    return List<Map<String, dynamic>>.from(response.data!);
  }

  Future<Map<String, dynamic>> getAdminDonationStats() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/donations/admin/stats');
    return response.data!;
  }
}
