import 'package:flutter/material.dart';
import 'package:frontend/l10n/l10n.dart';

import '../../../../theme/app_colors.dart';

/// Header of the elderly dashboard: a time-of-day greeting for
/// [userName] plus a one-tap SOS button for emergencies.
class GreetingsSection extends StatelessWidget {
  const GreetingsSection({
    required this.userName,
    this.onSosTap,
    super.key,
  });

  final String userName;
  final VoidCallback? onSosTap;

  String _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour < 12) return context.l10n.greetingMorning;
    if (hour < 17) return context.l10n.greetingAfternoon;
    return context.l10n.greetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greeting(context)}, $userName',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.greetingSummary,
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _SosButton(onTap: onSosTap),
      ],
    );
  }
}

class _SosButton extends StatelessWidget {
  const _SosButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warningRed,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 80,
          height: 68,
          alignment: Alignment.center,
          child: Text(
            context.l10n.sosLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
