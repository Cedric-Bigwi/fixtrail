import 'constants.dart';

class Validators {
  static String? required(String? v, [String field = 'This field']) =>
      (v == null || v.trim().isEmpty) ? '$field is required' : null;

  static String? minLength(String? v, int n, String field) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return '$field is required';
    if (t.length < n) return '$field must be at least $n characters';
    return null;
  }

  /// Email must be syntactically valid AND belong to an ALU domain.
  static String? aluEmail(String? v) {
    final value = (v ?? '').trim().toLowerCase();
    if (value.isEmpty) return 'Enter your ALU email';
    final m = RegExp(r'^[^@\s]+@([^@\s]+\.[^@\s]+)$').firstMatch(value);
    if (m == null) return 'Enter a valid email address';
    if (!AppConstants.allowedDomains.contains(m.group(1))) {
      return 'Use your ALU email (@alustudent.com or @alueducation.com)';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Enter a password';
    if (v.length < 8) return 'Use at least 8 characters';
    return null;
  }

  static String? confirm(String? v, String original) =>
      v != original ? 'Passwords do not match' : null;
}
