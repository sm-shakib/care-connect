import 'package:flutter/material.dart';

import 'package:frontend/theme/app_colors.dart';


class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        // Even indices are dots, odd indices are connecting lines.
        if (i.isEven) {
          final stepIndex = i ~/ 2;
          final isDone = stepIndex < currentStep;
          final isActive = stepIndex == currentStep;
          final isReached = isDone || isActive;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isReached
                      ? AppColors.darkTeal
                      : colorScheme.surfaceContainerLow,
                  border: Border.all(
                    color: isReached
                        ? AppColors.darkTeal
                        : colorScheme.outlineVariant,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                  '${stepIndex + 1}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? Colors.white
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 72,
                child: Text(
                  steps[stepIndex],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isReached
                        ? AppColors.darkTeal
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          );
        } else {
          final lineStepIndex = i ~/ 2;
          final isDone = lineStepIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 18),
              color: isDone
                  ? AppColors.darkTeal
                  : colorScheme.outlineVariant,
            ),
          );
        }
      }),
    );
  }
}