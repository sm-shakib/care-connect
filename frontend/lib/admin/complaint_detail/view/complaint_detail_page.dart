import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/complaint_detail_cubit.dart';
import 'complaint_detail_view.dart';

/// Route-level entry point for the admin Complaint Details feature.
/// Provides [ComplaintDetailCubit] scoped to [complaintId] and kicks
/// off the initial load.
class ComplaintDetailPage extends StatelessWidget {
  const ComplaintDetailPage({required this.complaintId, super.key});

  final String complaintId;

  static Route<void> route({required String complaintId}) {
    return MaterialPageRoute<void>(
      builder: (_) => ComplaintDetailPage(complaintId: complaintId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      ComplaintDetailCubit(complaintId: complaintId)..loadComplaint(),
      child: const ComplaintDetailView(),
    );
  }
}