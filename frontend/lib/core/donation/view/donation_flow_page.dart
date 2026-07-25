import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import '../models/donation.dart';

class DonationFlowPage extends StatefulWidget {
  const DonationFlowPage({super.key});

  @override
  State<DonationFlowPage> createState() => _DonationFlowPageState();
}

class _DonationFlowPageState extends State<DonationFlowPage> {
  int _currentStep = 0;
  double? _selectedAmount;
  PaymentMethod? _selectedMethod;
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();

  final List<double> _quickAmounts = [200, 500, 1000, 2000, 5000];

  void _nextStep() {
    setState(() {
      if (_currentStep < 2) _currentStep++;
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) _currentStep--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Central Fund Donation', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepCancel: _previousStep,
        controlsBuilder: (context, details) => const SizedBox.shrink(),
        steps: [
          Step(
            title: const Text('Amount'),
            isActive: _currentStep >= 0,
            content: _buildAmountStep(),
          ),
          Step(
            title: const Text('Method'),
            isActive: _currentStep >= 1,
            content: _buildMethodStep(),
          ),
          Step(
            title: const Text('Payment'),
            isActive: _currentStep >= 2,
            content: _buildPaymentStep(),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select or Enter Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          children: _quickAmounts.map((amt) {
            final isSelected = _selectedAmount == amt;
            return ChoiceChip(
              label: Text('৳ $amt'),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  _selectedAmount = val ? amt : null;
                  if (val) _amountController.text = amt.toString();
                });
              },
              selectedColor: AppColors.darkTeal,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Custom Amount (৳)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixText: '৳ ',
          ),
          onChanged: (val) {
            setState(() {
              _selectedAmount = double.tryParse(val);
            });
          },
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _selectedAmount != null && _selectedAmount! > 0 ? _nextStep : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkTeal, foregroundColor: Colors.white),
            child: const Text('Continue to Payment Method'),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Donating: ৳ $_selectedAmount', style: const TextStyle(fontSize: 16, color: AppColors.darkTeal, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const Text('Choose Payment Gateway', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildMethodTile(PaymentMethod.bkash, 'bKash', Icons.mobile_friendly, Colors.pink),
        _buildMethodTile(PaymentMethod.nagad, 'Nagad', Icons.account_balance_wallet, Colors.orange),
        _buildMethodTile(PaymentMethod.rocket, 'Rocket', Icons.rocket_launch, Colors.deepPurple),
        _buildMethodTile(PaymentMethod.bank, 'Bank Transfer', Icons.account_balance, Colors.blue),
        _buildMethodTile(PaymentMethod.cash, 'Cash Deposit', Icons.payments, Colors.green),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: _previousStep, child: const Text('Back'))),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedMethod != null ? _nextStep : null,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkTeal, foregroundColor: Colors.white),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodTile(PaymentMethod method, String name, IconData icon, Color color) {
    final isSelected = _selectedMethod == method;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? AppColors.darkTeal : AppColors.outlineVariantLight, width: isSelected ? 2 : 1),
      ),
      child: ListTile(
        onTap: () => setState(() => _selectedMethod = method),
        leading: Icon(icon, color: color),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.darkTeal) : null,
      ),
    );
  }

  Widget _buildPaymentStep() {
    if (_selectedMethod == PaymentMethod.cash || _selectedMethod == PaymentMethod.bank) {
      return _buildOfflineInstructions();
    }

    String methodName = _selectedMethod == PaymentMethod.bkash ? 'bKash' : (_selectedMethod == PaymentMethod.nagad ? 'Nagad' : 'Rocket');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              const Icon(Icons.security, size: 48, color: AppColors.darkTeal),
              const SizedBox(height: 12),
              Text('Secure $methodName Payment', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: '$methodName Wallet Number',
            hintText: '01XXXXXXXXX',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Enter PIN',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: _previousStep, child: const Text('Back'))),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkTeal, foregroundColor: Colors.white),
                child: const Text('Pay Now'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOfflineInstructions() {
    return Column(
      children: [
        const Icon(Icons.info_outline, size: 64, color: AppColors.primaryLight),
        const SizedBox(height: 20),
        Text(
          _selectedMethod == PaymentMethod.bank ? 'Bank Transfer Details' : 'Cash Deposit Instructions',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.paleMint, borderRadius: BorderRadius.circular(12)),
          child: Text(
            _selectedMethod == PaymentMethod.bank 
              ? 'Bank: Dutch Bangla Bank\nAccount Name: CareConnect Fund\nAccount No: 123.456.78910\nBranch: Dhaka Main'
              : 'Please visit our central office at:\nHouse 45, Road 12, Sector 4, Uttara, Dhaka.\nOffice Hours: 9:00 AM - 6:00 PM',
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkTeal, foregroundColor: Colors.white),
            child: const Text('I Understand'),
          ),
        ),
      ],
    );
  }

  void _processPayment() {
    if (_phoneController.text.isEmpty || _pinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter phone number and PIN')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.darkTeal)),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loader
      _showSuccessDialog();
    });
  }

  void _showSuccessDialog() {
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
            Text('Thank you for your generous contribution of ৳$_selectedAmount to the Central Fund.', textAlign: TextAlign.center),
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
}
