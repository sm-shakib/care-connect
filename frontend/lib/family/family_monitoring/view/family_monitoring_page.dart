import 'package:flutter/material.dart';

import '../../models/elder.dart';
import 'family_monitoring_view.dart';

class FamilyMonitoringPage extends StatelessWidget {
  const FamilyMonitoringPage({
    super.key,
    required this.elder,
  });

  final Elder elder;

  @override
  Widget build(BuildContext context) {
    return FamilyMonitoringView(
      elder: elder,
    );
  }
}