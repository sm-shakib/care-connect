import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/app_colors.dart';
import '../cubit/medicine_cubit.dart';
import '../cubit/medicine_state.dart';
import '../models/medicine.dart';
import '../widgets/medicine_list.dart';
import 'add_medicine_page.dart';
import 'medicine_details_page.dart';

/// Medicine list content: empty state, list of medicine cards, and an
/// "Add Medicine" entry point. Reads [MedicineCubit] from context, so it
/// must be used under a [BlocProvider]<[MedicineCubit]>.
///
/// Set [isElderly] to show the "Take Medicine" action on each card.
class MedicineView extends StatelessWidget {
  const MedicineView({this.isElderly = false, super.key});

  final bool isElderly;

  Future<void> _openAddMedicine(BuildContext context) async {
    final cubit = context.read<MedicineCubit>();
    final created = await Navigator.push<Medicine>(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicinePage()),
    );
    if (created != null) cubit.addMedicine(created);
  }

  Future<void> _openDetails(BuildContext context, Medicine medicine) async {
    final cubit = context.read<MedicineCubit>();
    final updated = await Navigator.push<Medicine>(
      context,
      MaterialPageRoute(builder: (_) => MedicineDetailsPage(medicine: medicine)),
    );
    if (updated != null) cubit.updateMedicine(updated);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicineCubit, MedicineState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == MedicineStatus.failure) {
          return Center(
            child: Text(
              state.errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: context.read<MedicineCubit>().loadMedicines,
          child: state.medicines.isEmpty
              ? _EmptyMedicineState(onAddMedicine: () => _openAddMedicine(context))
              : ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    MedicineList(
                      medicines: state.medicines,
                      isElderly: isElderly,
                      onTapMedicine: (medicine) => _openDetails(context, medicine),
                      onTakeMedicine: (medicine) =>
                          context.read<MedicineCubit>().markTaken(medicine.id),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _openAddMedicine(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.onPrimaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Add Medicine',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _EmptyMedicineState extends StatelessWidget {
  const _EmptyMedicineState({required this.onAddMedicine});

  final VoidCallback onAddMedicine;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainerLight.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.medication_outlined,
                      size: 56,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No medicines added yet',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTeal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your medicines to keep track of dosage, schedule, and refills.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: onAddMedicine,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: AppColors.onPrimaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Add Medicine',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
