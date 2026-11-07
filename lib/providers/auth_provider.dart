import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

enum AuthStatus { loading, signedOut, needsVerification, ready }

String friendlyAuthError(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment.';
    }
  }
  return 'Something went wrong. Please try again.';
}

/// Holds the auth session: signed-out / needs email verification / ready.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _userSub = _service.userChanges.listen(_onUser);
  }

  final AuthService _service;
  StreamSubscription<User?>? _userSub;
  StreamSubscription<AppUser?>? _profileSub;

  AuthStatus _status = AuthStatus.loading;
  User? _user;
  AppUser? _profile;
  bool _busy = false;
  bool _creatingProfile = false;
  bool _registering = false;

  AuthStatus get status => _status;
  User? get firebaseUser => _user;
  AppUser? get profile => _profile;
  bool get busy => _busy;
  bool get isStaff => _profile?.isStaff ?? false;
  String get email => _user?.email ?? '';

  void _onUser(User? u) {
    // Ignore repeated emissions (token refresh) while already signed in, so the
    // UI is not torn down and rebuilt.
    if (u != null && _status == AuthStatus.ready && u.uid == _user?.uid) {
      _user = u;
      return;
    }
    _profileSub?.cancel();
    _profileSub = null;
    _user = u;
    if (u == null) {
      _profile = null;
      _status = AuthStatus.signedOut;
    } else if (AppConstants.requireEmailVerification && !u.emailVerified) {
      _profile = null;
      _status = AuthStatus.needsVerification;
    } else {
      _status = AuthStatus.loading;
      _profileSub = _service.watchProfile(u.uid).listen(_onProfile, onError: (_) {
        _status = AuthStatus.signedOut;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  Future<void> _onProfile(AppUser? p) async {
    if (p == null) {
      if (!_creatingProfile && !_registering && _user != null) {
        _creatingProfile = true;
        try {
          await _service.createProfile(_user!);
        } catch (_) {}
        _creatingProfile = false;
      }
      return;
    }
    _profile = p;
    _status = AuthStatus.ready;
    notifyListeners();
  }

  Future<String?> _run(Future<void> Function() action) async {
    _busy = true;
    notifyListeners();
    try {
      await action();
      return null;
    } catch (e) {
      return friendlyAuthError(e);
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Each returns an error message, or null on success.
  Future<String?> signIn(String email, String password) =>
      _run(() => _service.signIn(email, password));

  Future<String?> register(
      {required String name,
      required String email,
      required String password,
      String department = ''}) async {
    // While registering we write the profile ourselves, so the "missing
    // profile" fallback must not overwrite the name/department.
    _registering = true;
    final err = await _run(() => _service.register(
        name: name, email: email, password: password, department: department));
    _registering = false;
    if (err != null && _user != null && _profile == null) {
      try {
        await _service.createProfile(_user!);
      } catch (_) {}
    }
    return err;
  }

  Future<String?> updateName(String name) =>
      _run(() => _service.updateName(_user!.uid, name.trim()));

  Future<String?> resendVerification() => _run(_service.sendVerification);

  Future<String?> resetPassword(String email) =>
      _run(() => _service.resetPassword(email));

  /// Returns true when the email is now verified.
  Future<bool> checkVerified() async {
    bool ok = false;
    await _run(() async {
      await _service.reload();
      final u = _service.currentUser;
      if (u != null && u.emailVerified) {
        ok = true;
        _onUser(u);
      }
    });
    return ok;
  }

  Future<void> signOut() => _service.signOut();

  @override
  void dispose() {
    _userSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
