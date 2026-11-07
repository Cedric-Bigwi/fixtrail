import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants.dart';
import '../models/app_user.dart';

/// Thin wrapper around Firebase Auth + the `users` collection.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get userChanges => _auth.userChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String department = '',
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    final user = cred.user!;
    await user.updateDisplayName(name.trim());
    await _db.collection('users').doc(user.uid).set({
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'department': department.trim(),
      'role': 'student', // staff role can only be granted in the Firebase console
      'createdAt': FieldValue.serverTimestamp(),
    });
    if (AppConstants.requireEmailVerification) {
      await user.sendEmailVerification();
    }
  }

  /// Safety net: creates a student profile if a verified user has none.
  Future<void> createProfile(User u) => _db.collection('users').doc(u.uid).set({
        'name': u.displayName ?? (u.email ?? 'Student').split('@').first,
        'email': (u.email ?? '').toLowerCase(),
        'department': '',
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });

  Stream<AppUser?> watchProfile(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((s) => s.exists ? AppUser.fromDoc(s) : null);

  Future<void> sendVerification() => _auth.currentUser!.sendEmailVerification();

  Future<void> reload() async {
    await _auth.currentUser?.reload();
    // Refresh the ID token so Firestore rules see email_verified == true.
    await _auth.currentUser?.getIdToken(true);
  }

  Future<void> updateName(String uid, String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    await _db.collection('users').doc(uid).update({'name': name});
  }

  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();
}
