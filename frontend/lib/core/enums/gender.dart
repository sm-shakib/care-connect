import 'package:flutter/widgets.dart';
import 'package:frontend/l10n/l10n.dart';

enum Gender { male, female }

extension GenderLabel on Gender {
  String label(BuildContext context) {
    switch (this) {
      case Gender.male:
        return context.l10n.genderMale;
      case Gender.female:
        return context.l10n.genderFemale;
    }
  }
}