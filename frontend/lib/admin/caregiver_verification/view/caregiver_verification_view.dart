import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../../caregiver_review/caregiver_review.dart';
import '../cubit/caregiver_verification_cubit.dart';
import '../cubit/caregiver_verification_state.dart';
import 'widgets/caregiver_verification_card.dart';
import 'widgets/verification_filter_chips.dart';
import 'widgets/verification_search_bar.dart';

/// Content body for the Caregiver Verification screen.
class CaregiverVerificationView extends StatelessWidget {
  const CaregiverVerificationView({super.key});

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
                VerificationSearchBar(
                  onChanged: context
                      .read<CaregiverVerificationCubit>()
                      .searchChanged,
                ),
                const SizedBox(height: 24),
                BlocBuilder<CaregiverVerificationCubit,
                    CaregiverVerificationState>(
                  buildWhen: (previous, current) =>
                  previous.filter != current.filter,
                  builder: (context, state) {
                    return VerificationFilterChips(
                      selected: state.filter,
                      onSelected: context
                          .read<CaregiverVerificationCubit>()
                          .filterChanged,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: BlocBuilder<CaregiverVerificationCubit,
                      CaregiverVerificationState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (state.status ==
                          CaregiverVerificationStatus.failure) {
                        return Center(
                          child: Text(
                            state.errorMessage ??
                                'Something went wrong.',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariantLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final caregivers = state.filteredCaregivers;

                      if (caregivers.isEmpty) {
                        return Center(
                          child: Text(
                            'No caregivers match your search.',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariantLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: context
                            .read<CaregiverVerificationCubit>()
                            .loadCaregivers,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: caregivers.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final caregiver = caregivers[index];
                            return CaregiverVerificationCard(
                              caregiver: caregiver,
                              onTap: () {
                                Navigator.of(context).push(
                                  CaregiverReviewPage.route(
                                    applicationId: caregiver.id,
                                  ),
                                );
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
