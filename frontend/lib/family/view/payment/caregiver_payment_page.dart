import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/caregiver/models/caregiver.dart';
import 'package:frontend/theme/app_colors.dart';

class CaregiverPaymentPage extends StatefulWidget {
  final Caregiver caregiver;

  const CaregiverPaymentPage({super.key, required this.caregiver});

  @override
  State<CaregiverPaymentPage> createState() => _CaregiverPaymentPageState();
}

enum _PaymentStep { amount, otp, pin, success }

class _CaregiverPaymentPageState extends State<CaregiverPaymentPage> {
  _PaymentStep _currentStep = _PaymentStep.amount;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  
  static const Color bkashPink = Color(0xFFD12053);

  @override
  void dispose() {
    _amountController.dispose();
    _otpController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      if (_currentStep == _PaymentStep.amount) {
        if (_amountController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter amount')),
          );
          return;
        }
        _currentStep = _PaymentStep.otp;
      } else if (_currentStep == _PaymentStep.otp) {
        if (_otpController.text.length < 6) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter 6-digit OTP')),
          );
          return;
        }
        _currentStep = _PaymentStep.pin;
      } else if (_currentStep == _PaymentStep.pin) {
        if (_pinController.text.length < 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter 5-digit PIN')),
          );
          return;
        }
        _processPayment();
      }
    });
  }

  Future<void> _processPayment() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: bkashPink),
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    Navigator.pop(context); // Close loader
    setState(() {
      _currentStep = _PaymentStep.success;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: bkashPink,
        elevation: 0,
        title: Image.network(
          'https://logos-world.net/wp-content/uploads/2022/07/Bkash-Logo.png',
          height: 30,
          errorBuilder: (_, __, ___) => const Text(
            'bKash Payment',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            color: bkashPink.withOpacity(0.05),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: bkashPink,
                  radius: 20,
                  child: const Icon(Icons.person, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.caregiver.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      widget.caregiver.phone,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStepContent(),
            ),
          ),
          if (_currentStep != _PaymentStep.success)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bkashPink,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: Text(
                    _currentStep == _PaymentStep.pin ? 'CONFIRM' : 'NEXT',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case _PaymentStep.amount:
        return _buildAmountStep();
      case _PaymentStep.otp:
        return _buildOtpStep();
      case _PaymentStep.pin:
        return _buildPinStep();
      case _PaymentStep.success:
        return _buildSuccessStep();
    }
  }

  Widget _buildAmountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Payment to Caregiver',
            style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Enter Amount',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: bkashPink),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: bkashPink),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            hintText: '0',
            suffixText: '৳',
            suffixStyle: TextStyle(fontSize: 24),
            border: UnderlineInputBorder(borderSide: BorderSide(color: bkashPink, width: 2)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: bkashPink, width: 2)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: bkashPink, width: 3)),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['500', '1000', '2000', '5000'].map((val) => InkWell(
            onTap: () => setState(() => _amountController.text = val),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: bkashPink.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('৳$val', style: const TextStyle(color: bkashPink, fontWeight: FontWeight.bold)),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.message_outlined, size: 64, color: bkashPink),
        const SizedBox(height: 20),
        const Text(
          'bKash Verification Code',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'A 6-digit code has been sent to your mobile number. Please enter it here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 20),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: '',
            hintText: '******',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {},
          child: const Text('Resend Code', style: TextStyle(color: bkashPink, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPinStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline, size: 64, color: bkashPink),
        const SizedBox(height: 20),
        const Text(
          'Enter PIN',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Enter your 5-digit bKash PIN for confirmation.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          obscureText: true,
          maxLength: 5,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 20),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            counterText: '',
            hintText: '•••••',
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.green,
          child: Icon(Icons.check, color: Colors.white, size: 60),
        ),
        const SizedBox(height: 24),
        const Text(
          'Payment Successful!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _summaryRow('Recipient', widget.caregiver.name),
              const Divider(),
              _summaryRow('Phone', widget.caregiver.phone),
              const Divider(),
              _summaryRow('Amount', '৳${_amountController.text}'),
              const Divider(),
              _summaryRow('Transaction ID', 'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}XT'),
            ],
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('BACK TO PROFILE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
