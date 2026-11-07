import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident.dart';
import 'demo_data.dart';
import 'photo_storage_service.dart';

/// Firestore + Storage access for incident reports (the "repository" layer).
class IncidentService {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('incidents');
  final PhotoStorageService _photos = PhotoStorageService();

  /// READ (real-time). Newest first. Filtering is done client-side so no
  /// composite Firestore indexes are required.
  Stream<List<Incident>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .limit(300)
      .snapshots()
      .map((s) => s.docs.map(Incident.fromDoc).toList());

  Future<String> uploadPhoto(Uint8List bytes, String uid) =>
      _photos.upload(bytes, uid);

  Future<void> deletePhoto(String? url) => _photos.delete(url);

  /// CREATE
  Future<void> create(Map<String, dynamic> data) => _col.add(data);

  /// UPDATE (owner edits while still "submitted")
  Future<void> updateDetails(String id, Map<String, dynamic> data) =>
      _col.doc(id).update({...data, 'updatedAt': FieldValue.serverTimestamp()});

  /// UPDATE (staff only - enforced by security rules)
  Future<void> updateStatus(
          String id, IncidentStatus status, TimelineEntry entry) =>
      _col.doc(id).update({
        'status': status.name,
        'timeline': FieldValue.arrayUnion([entry.toMap()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  /// "Me too" toggle
  Future<void> setAffected(String id, String uid, bool affected) =>
      _col.doc(id).update({
        'affectedBy': affected
            ? FieldValue.arrayUnion([uid])
            : FieldValue.arrayRemove([uid]),
      });

  /// DELETE
  Future<void> delete(String id) => _col.doc(id).delete();

  /// After a profile rename, keep the author name on the user's own reports.
  Future<void> renameReporter(String uid, String name) async {
    final snap = await _col.where('reporterId', isEqualTo: uid).get();
    if (snap.docs.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final d in snap.docs) {
      batch.update(d.reference, {'reporterName': name});
    }
    await batch.commit();
  }

  /// Demo data (staff only - see rules). Returns how many reports were added.
  Future<int> seedDemo() async {
    await clearDemo(); // replace any older demo reports (e.g. old locations)
    final batch = FirebaseFirestore.instance.batch();
    final docs = DemoData.build();
    for (final d in docs) {
      batch.set(_col.doc(), d);
    }
    await batch.commit();
    return docs.length;
  }

  Future<int> clearDemo() async {
    final snap = await _col.where('seeded', isEqualTo: true).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
    return snap.docs.length;
  }
}
