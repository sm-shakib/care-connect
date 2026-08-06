import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../../complaint_detail/complaint_detail.dart';
import '../cubit/complaint_management_cubit.dart';
import '../cubit/complaint_management_state.dart';
import 'widgets/complaint_card.dart';
import 'widgets/complaint_filter_chips.dart';
import 'widgets/complaint_search_bar.dart';

/// Content body for the Complaint Management screen.
class ComplaintManagementView extends StatelessWidget {
  const ComplaintManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _horizontalPadding(context),
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ComplaintSearchBar(
                  onChanged: context
                      .read<ComplaintManagementCubit>()
                      .searchChanged,
                ),
                const SizedBox(height: 16),
                BlocBuilder<ComplaintManagementCubit,
                    ComplaintManagementState>(
                  buildWhen: (previous, current) =>
                  previous.filter != current.filter,
                  builder: (context, state) {
                    return ComplaintFilterChips(
                      selected: state.filter,
                      onSelected: context
                          .read<ComplaintManagementCubit>()
                          .filterChanged,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<ComplaintManagementCubit,
                      ComplaintManagementState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state.status ==
                          ComplaintManagementStatus.failure) {
                        return Center(
                          child: Text(
                            state.errorMessage ?? 'Something went wrong.',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariantLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final complaints = state.filteredComplaints;

                      if (complaints.isEmpty) {
                        return Center(
                          child: Text(
                            'No complaints match your search.',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariantLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: context
                            .read<ComplaintManagementCubit>()
                            .loadComplaints,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: complaints.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final complaint = complaints[index];
                            return ComplaintCard(
                              complaint: complaint,
                              onView: () {
                                Navigator.of(context).push(
                                  ComplaintDetailPage.route(
                                    complaintId: complaint.id,
                                  ),
                                );
                              },
                              onResolve: () {
                                context
                                    .read<ComplaintManagementCubit>()
                                    .resolve(complaint.id);
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 360 ? 16 : 20;
  }
}
