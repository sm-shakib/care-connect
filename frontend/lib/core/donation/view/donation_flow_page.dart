import 'package:flutter/material.dart';
import 'package:frontend/admin/central_fund/data/repositories/central_fund_repository.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/theme/app_colors.dart';
import './fund_bkash_webview_page.dart';

class DonationFlowPage extends StatefulWidget {
  const DonationFlowPage({super.key});

  @override
  State<DonationFlowPage> createState() => _DonationFlowPageState();
}

class _DonationFlowPageState extends State<DonationFlowPage> {
  double? _selectedAmount;
  final _amountController = TextEditingController();
  final List<double> _quickAmounts = [100, 200, 500, 1000, 2000];
  
  static const Color bkashPink = Color(0xFFD12053);

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountSelected(double amt) {
    setState(() {
      _selectedAmount = amt;
      _amountController.text = amt.toStringAsFixed(0);
    });
  }

  Future<void> _startPayment() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: bkashPink)),
    );

    try {
      final repository = CentralFundRepository(ApiClient());
      final paymentData = await repository.initializeBkashDonation(amount);
      
      if (mounted) {
        Navigator.pop(context); // Close loader

        final bool? success = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => FundBkashWebViewPage(
              bkashUrl: paymentData['bkashURL'] as String,
              donationId: paymentData['donation_id'] as int,
            ),
          ),
        );

        if (success == true) {
          _showSuccessDialog(amount);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loader
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text('Donation Successful!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Thank you for your generous contribution of ৳${amount.toStringAsFixed(0)} to the Central Fund.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Exit flow
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkTeal, foregroundColor: Colors.white),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Donation Amount', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: bkashPink,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // bKash Header Style
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: const BoxDecoration(
              color: bkashPink,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.volunteer_activism, size: 50, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Enter Donation Amount',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: bkashPink),
                    decoration: const InputDecoration(
                      hintText: '0',
                      border: InputBorder.none,
                      prefixText: '৳ ',
                      prefixStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: bkashPink),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Quick Amount',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _quickAmounts.map((amt) {
                      final isSelected = _selectedAmount == amt;
                      return GestureDetector(
                        onTap: () => _onAmountSelected(amt),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? bkashPink : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? bkashPink : Colors.grey.shade300),
                          ),
                          child: Text(
                            '৳ ${amt.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Your contribution directly supports caregiver support for elderly citizens in our community.',
                    style: TextStyle(color: Colors.grey, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bkashPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue to Payment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
