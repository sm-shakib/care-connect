import 'package:flutter/material.dart';
import 'package:frontend/admin/central_fund/data/repositories/central_fund_repository.dart';
import 'package:frontend/admin/central_fund/models/central_fund_models.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/theme/app_colors.dart';

class DonationHistoryPage extends StatefulWidget {
  const DonationHistoryPage({super.key});

  @override
  State<DonationHistoryPage> createState() => _DonationHistoryPageState();
}

class _DonationHistoryPageState extends State<DonationHistoryPage> {
  final _repository = CentralFundRepository(ApiClient());
  List<DonationModel>? _history;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final history = await _repository.getMyDonations();
      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Donation History'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $_error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadHistory,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_history == null || _history!.isEmpty) {
      return const Center(child: Text('No donations yet.'));
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history!.length,
        itemBuilder: (context, index) {
          final item = _history![index];
          return Card(
            color: AppColors.paleMint.withValues(alpha: 0.25),
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.outlineVariantLight),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.paleMint,
                child: Icon(Icons.volunteer_activism, color: AppColors.darkTeal),
              ),
              title: Text(item.amount,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(
                  'Via ${item.paymentMethod.toUpperCase()} on ${item.date.split('T')[0]}'),
              trailing: _buildStatusBadge(item.status),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final Color color;
    final String label;

    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        label = 'SUCCESS';
      case 'pending':
        color = Colors.grey;
        label = 'CANCELLED';
      case 'failed':
        color = Colors.red;
        label = 'FAILED';
      default:
        color = Colors.grey;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
