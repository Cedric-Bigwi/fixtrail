import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { student, staff }

class AppUser {
  final String uid;
  final String email;
  final String name;
  final String department;
  final UserRole role;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.department = '',
  });

  bool get isStaff => role == UserRole.staff;
  String get firstName => name.trim().isEmpty ? 'there' : name.trim().split(' ').first;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      email: d['email'] ?? '',
      name: d['name'] ?? '',
      department: d['department'] ?? '',
      role: d['role'] == 'staff' ? UserRole.staff : UserRole.student,
    );
  }
}
