import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:intl/intl.dart';

class FamilyNotificationsPage extends StatefulWidget {
  const FamilyNotificationsPage({super.key});

  @override
  State<FamilyNotificationsPage> createState() => _FamilyNotificationsPageState();
}

class _FamilyNotificationsPageState extends State<FamilyNotificationsPage> {
  List<Map<String, dynamic>> _notifications = const <Map<String, dynamic>>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await ApiClient().get<List<dynamic>>('/notifications/');
      final data = response.data ?? const <dynamic>[];
      if (mounted) {
        setState(() {
          _notifications = data
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
          _isLoading = false;
        });
      }
    } on Exception {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFBFEFC),
        title: const Text('Notifications', style: TextStyle(color: AppColors.darkTeal, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('No new notifications.'))
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        color: AppColors.paleMint.withOpacity(0.18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: AppColors.outlineVariantLight),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.paleMint,
                            child: Icon(
                              Icons.notifications_active,
                              color: AppColors.darkTeal,
                            ),
                          ),
                          title: Text(
                            (item['title'] ?? '').toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text((item['body'] ?? '').toString()),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime((item['created_at'] ?? '').toString()),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _formatTime(String isoDate) {
    try {
      final date = DateTime.parse(isoDate).toLocal();
      return DateFormat.yMMMd().add_jm().format(date);
    } catch (_) {
      return isoDate;
    }
  }
}
