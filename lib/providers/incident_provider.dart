import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';

/// App-wide incident state (Provider + ChangeNotifier).
/// Listens to Firestore in real time, so every screen (home, lists, detail,
/// staff desk) updates automatically when a status or report changes.
class IncidentProvider extends ChangeNotifier {
  IncidentProvider(this._service);

  final IncidentService _service;
  AppUser? _user;
  StreamSubscription<List<Incident>>? _sub;

  List<Incident> _all = [];
  bool _loading = false;
  bool _submitting = false;
  String? _streamError;

  final Map<ListScope, IncidentFilter> _filters = {
    for (final s in ListScope.values) s: IncidentFilter(),
  };

  // ---- getters ----
  bool get loading => _loading;
  bool get submitting => _submitting;
  String? get streamError => _streamError;
  List<Incident> get all => _all;
  List<Incident> get mine =>
      _all.where((i) => i.reporterId == _user?.uid).toList();
  IncidentFilter filterOf(ListScope s) => _filters[s]!;

  Incident? byId(String id) {
    for (final i in _all) {
      if (i.id == id) return i;
    }
    return null;
  }

  List<Incident> visible(ListScope scope) =>
      _filters[scope]!.apply(scope == ListScope.mine ? mine : _all);

  int count(List<Incident> list, IncidentStatus s) =>
      list.where((i) => i.status == s).length;

  int get resolvedThisWeek {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return _all
        .where((i) =>
            i.status == IncidentStatus.resolved && i.updatedAt.isAfter(cutoff))
        .length;
  }

  // ---- binding to the signed-in user (called by ProxyProvider) ----
  int _retries = 0;

  void bind(AppUser? user) {
    if (user?.uid == _user?.uid) {
      _user = user;
      return;
    }
    _user = user;
    _sub?.cancel();
    _sub = null;
    _all = [];
    _streamError = null;
    _retries = 0;
    for (final f in _filters.values) {
      f.clear();
    }
    if (user == null) {
      _loading = false;
      return;
    }
    _loading = true;
    _subscribe(user.uid);
  }

  void _subscribe(String uid) {
    _sub?.cancel();
    _sub = _service.watchAll().listen((list) {
      _all = list;
      _loading = false;
      _streamError = null;
      _retries = 0;
      notifyListeners();
    }, onError: (e) {
      debugPrint('incident stream error: $e');
      _loading = false;
      _streamError = 'Could not load reports. Check your connection.';
      notifyListeners();
      if (_retries < 3) {
        _retries++;
        Future.delayed(Duration(seconds: 2 * _retries), () {
          if (_user?.uid == uid) _subscribe(uid);
        });
      }
    });
  }

  /// Manual retry (used by the "Try again" button).
  void retry() {
    final u = _user;
    if (u == null) return;
    _retries = 0;
    _streamError = null;
    _loading = true;
    notifyListeners();
    _subscribe(u.uid);
  }

  Future<void> renameReporter(String name) async {
    final u = _user;
    if (u == null) return;
    try {
      await _service.renameReporter(u.uid, name);
    } catch (e) {
      debugPrint('renameReporter skipped: $e');
    }
  }

  // ---- filters ----
  void setQuery(ListScope s, String q) {
    _filters[s]!.query = q;
    notifyListeners();
  }

  void setStatus(ListScope s, IncidentStatus? st) {
    _filters[s]!.status = st;
    notifyListeners();
  }

  void setCategory(ListScope s, IncidentCategory? c) {
    _filters[s]!.category = c;
    notifyListeners();
  }

  void clearFilters(ListScope s) {
    _filters[s]!.clear();
    notifyListeners();
  }

  // ---- CRUD ----
  static const _failMsg = 'Could not save. Check your connection and try again.';

  Future<String?> submit({
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    required bool anonymous,
    Uint8List? photo,
  }) async {
    final user = _user;
    if (user == null) return 'You are signed out.';
    _submitting = true;
    notifyListeners();
    try {
      String? url;
      if (photo != null) url = await _service.uploadPhoto(photo, user.uid);
      await _service.create(Incident.createMap(
        title: title,
        description: description,
        category: category,
        location: location,
        anonymous: anonymous,
        reporter: user,
        photoUrl: url,
      ));
      return null;
    } catch (e) {
      debugPrint('submit error: $e');
      return _failMsg;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  Future<String?> updateReport(
    Incident old, {
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    required bool anonymous,
    Uint8List? newPhoto,
    bool removePhoto = false,
  }) async {
    final user = _user;
    if (user == null) return 'You are signed out.';
    _submitting = true;
    notifyListeners();
    try {
      String? url = old.photoUrl;
      if (newPhoto != null) {
        url = await _service.uploadPhoto(newPhoto, user.uid);
        await _service.deletePhoto(old.photoUrl);
      } else if (removePhoto) {
        await _service.deletePhoto(old.photoUrl);
        url = null;
      }
      await _service.updateDetails(old.id, {
        'title': title.trim(),
        'description': description.trim(),
        'category': category.name,
        'location': location,
        'anonymous': anonymous,
        'photoUrl': url,
      });
      return null;
    } catch (e) {
      debugPrint('update error: $e');
      return _failMsg;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  /// Staff only (also enforced by Firestore rules).
  Future<String?> updateStatus(Incident i, IncidentStatus s, String note) async {
    final user = _user;
    if (user == null || !user.isStaff) return 'Only staff can update status.';
    try {
      await _service.updateStatus(
        i.id,
        s,
        TimelineEntry(
            status: s,
            at: DateTime.now(),
            by: user.name,
            note: note.trim().isEmpty ? 'Status changed to ${s.label}' : note.trim()),
      );
      return null;
    } catch (e) {
      debugPrint('status error: $e');
      return _failMsg;
    }
  }

  Future<String?> toggleAffected(Incident i) async {
    final user = _user;
    if (user == null) return 'You are signed out.';
    try {
      await _service.setAffected(i.id, user.uid, !i.affectedBy.contains(user.uid));
      return null;
    } catch (e) {
      return _failMsg;
    }
  }

  Future<String?> delete(Incident i) async {
    try {
      await _service.delete(i.id);
      await _service.deletePhoto(i.photoUrl);
      return null;
    } catch (e) {
      return _failMsg;
    }
  }

  /// Staff-only developer helpers (enforced by security rules too).
  Future<String> seedDemo() async {
    if (!(_user?.isStaff ?? false)) return 'Only staff can load demo data.';
    try {
      final n = await _service.seedDemo();
      return 'Loaded $n fresh demo reports';
    } catch (e) {
      debugPrint('seed error: $e');
      return 'Could not add demo data. Check your Firestore rules.';
    }
  }

  Future<String> clearDemo() async {
    if (!(_user?.isStaff ?? false)) return 'Only staff can remove demo data.';
    try {
      final n = await _service.clearDemo();
      return 'Removed $n demo reports';
    } catch (e) {
      debugPrint('clear error: $e');
      return 'Could not remove demo data.';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
