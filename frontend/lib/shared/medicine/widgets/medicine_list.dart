import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/app/cubit/locale_cubit.dart';
import 'package:frontend/shared/medicine/models/medicine.dart';
import 'package:frontend/shared/medicine/widgets/medicine_card.dart';
import 'package:intl/intl.dart';

/// Today's date/day header followed by a list of medicine cards.
class MedicineList extends StatelessWidget {
  const MedicineList({
    required this.medicines,
    this.isElderly = false,
    this.onTapMedicine,
    this.onTakeMedicine,
    super.key,
  });

  final List<Medicine> medicines;
  final bool isElderly;
  final ValueChanged<Medicine>? onTapMedicine;
  final ValueChanged<Medicine>? onTakeMedicine;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final locale = context.read<LocaleCubit>().state.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, MMMM d', locale).format(today),
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ...medicines.map(
          (medicine) => Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: MedicineCard(
              medicine: medicine,
              isElderly: isElderly,
              onTap: onTapMedicine == null
                  ? null
                  : () => onTapMedicine!(medicine),
              onTakeMedicine: onTakeMedicine == null
                  ? null
                  : () => onTakeMedicine!(medicine),
            ),
          ),
        ),
      ],
    );
  }
}
