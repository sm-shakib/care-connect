import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../../complaint_detail/complaint_detail.dart';
import '../cubit/complaint_management_cubit.dart';
import '../cubit/complaint_management_state.dart';
//import 'widgets/complaint_bottom_nav_bar.dart';
import 'widgets/complaint_card.dart';
import 'widgets/complaint_filter_chips.dart';
import 'widgets/complaint_search_bar.dart';

/// Presentational scaffold for the Complaints screen. Reads state from
/// [ComplaintManagementCubit] via [BlocBuilder] and stays responsive by
/// centering content with a max width on larger screens.
///
/// No back button in the app bar — this is a bottom-nav-level tab
/// screen in the design, not a pushed detail page.
class ComplaintManagementView extends StatelessWidget {
  const ComplaintManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: _buildAppBar(context),
      //bottomNavigationBar: const ComplaintBottomNavBar(),
      body: SafeArea(
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
                                  //print('Complaint ID: ${complaint.id}');
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      shape: Border(
        bottom: BorderSide(color: AppColors.outlineVariantLight),
      ),
      title: Text(
        'Complaints',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryLight,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications,
            color: AppColors.primaryLight,
          ),
          onPressed: () {},
        ),
      ],
    );
  }


  double _horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 360 ? 16 : 20;
  }
}