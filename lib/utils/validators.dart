bool isNonEmpty(String s) => s.trim().isNotEmpty;

bool isValidUsername(String s) => RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(s);

String? passwordStrength(String s) {
  if (s.length < 6) return 'weak';
  final hasLetters = RegExp(r'[A-Za-z]').hasMatch(s);
  final hasDigits = RegExp(r'\d').hasMatch(s);
  final hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(s);
  final score = (hasLetters ? 1 : 0) + (hasDigits ? 1 : 0) + (hasSpecial ? 1 : 0);
  if (score >= 3 && s.length >= 10) return 'strong';
  if (score >= 2) return 'medium';
  return 'weak';
}
