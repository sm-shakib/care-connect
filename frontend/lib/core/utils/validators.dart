final RegExp _emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$');
final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

String? validateRequired(String? value, {String fieldName = 'This field'}) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required.';
  }
  return null;
}

String? validateName(String? value) {
  final requiredError = validateRequired(value, fieldName: 'Name');
  if (requiredError != null) return requiredError;
  if (value!.trim().length < 2) {
    return 'Enter a valid name.';
  }
  return null;
}

String? validateEmail(String? value) {
  final requiredError = validateRequired(value, fieldName: 'Email');
  if (requiredError != null) return requiredError;
  if (!_emailRegex.hasMatch(value!.trim())) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? validatePhone(String? value) {
  final requiredError = validateRequired(value, fieldName: 'Phone number');
  if (requiredError != null) return requiredError;
  if (!_phoneRegex.hasMatch(value!.trim())) {
    return 'Enter a valid phone number.';
  }
  return null;
}

String? validateEmailOrPhone(String? value) {
  final requiredError = validateRequired(value, fieldName: 'This field');
  if (requiredError != null) return requiredError;
  final trimmed = value!.trim();
  final isEmail = trimmed.contains('@');
  final valid = isEmail
      ? _emailRegex.hasMatch(trimmed)
      : _phoneRegex.hasMatch(trimmed);
  return valid ? null : 'Enter a valid email or phone number.';
}

String? validatePassword(String? value, {int minLength = 8}) {
  final requiredError = validateRequired(value, fieldName: 'Password');
  if (requiredError != null) return requiredError;
  if (value!.length < minLength) {
    return 'Password must be at least $minLength characters.';
  }
  return null;
}

String? validateConfirmPassword(String? password, String? confirmPassword) {
  final requiredError =
  validateRequired(confirmPassword, fieldName: 'Confirm password');
  if (requiredError != null) return requiredError;
  if (confirmPassword != password) {
    return 'Passwords do not match.';
  }
  return null;
}

String? validateAddress(String? value) {
  return validateRequired(value, fieldName: 'Address');
}

String? validateHourlyRate(String? value) {
  final requiredError = validateRequired(value, fieldName: 'Hourly rate');
  if (requiredError != null) return requiredError;
  final parsed = double.tryParse(value!.trim());
  if (parsed == null || parsed <= 0) {
    return 'Enter a valid amount.';
  }
  return null;
}

String? validateDateOfBirth(DateTime? value) {
  if (value == null) {
    return 'Date of birth is required.';
  }
  final age = DateTime.now().difference(value).inDays / 365.25;
  if (age < 18) {
    return 'You must be at least 18 years old.';
  }
  if (age > 120) {
    return 'Enter a valid date of birth.';
  }
  return null;
}

String? validateExperienceYears(String? value) {
  final requiredError = validateRequired(value, fieldName: 'Experience');
  if (requiredError != null) return requiredError;
  final parsed = int.tryParse(value!.trim());
  if (parsed == null || parsed < 0 || parsed > 60) {
    return 'Enter a valid number of years.';
  }
  return null;
}