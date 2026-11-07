import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_user.dart';

enum IncidentStatus {
  submitted,
  inProgress,
  resolved;

  String get label {
    switch (this) {
      case IncidentStatus.submitted:
        return 'Submitted';
      case IncidentStatus.inProgress:
        return 'In progress';
      case IncidentStatus.resolved:
        return 'Resolved';
    }
  }

  static IncidentStatus parse(String? v) => IncidentStatus.values
      .firstWhere((e) => e.name == v, orElse: () => IncidentStatus.submitted);
}

enum IncidentCategory {
  facilities,
  water,
  electricity,
  safety,
  sanitation,
  furniture,
  other;

  String get label {
    switch (this) {
      case IncidentCategory.facilities:
        return 'Facilities';
      case IncidentCategory.water:
        return 'Water';
      case IncidentCategory.electricity:
        return 'Electricity';
      case IncidentCategory.safety:
        return 'Safety';
      case IncidentCategory.sanitation:
        return 'Sanitation';
      case IncidentCategory.furniture:
        return 'Furniture';
      case IncidentCategory.other:
        return 'Other';
    }
  }

  static IncidentCategory parse(String? v) => IncidentCategory.values
      .firstWhere((e) => e.name == v, orElse: () => IncidentCategory.other);
}

class TimelineEntry {
  final IncidentStatus status;
  final DateTime at;
  final String by;
  final String note;

  const TimelineEntry({
    required this.status,
    required this.at,
    required this.by,
    this.note = '',
  });

  Map<String, dynamic> toMap() => {
        'status': status.name,
        'at': Timestamp.fromDate(at),
        'by': by,
        'note': note,
      };

  factory TimelineEntry.fromMap(Map<String, dynamic> m) => TimelineEntry(
        status: IncidentStatus.parse(m['status']),
        at: (m['at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        by: m['by'] ?? '',
        note: m['note'] ?? '',
      );
}

class Incident {
  final String id;
  final String title;
  final String description;
  final IncidentCategory category;
  final IncidentStatus status;
  final String location;
  final String? photoUrl;
  final String reporterId;
  final String reporterName;
  final bool anonymous;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TimelineEntry> timeline;
  final List<String> affectedBy;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.location,
    required this.reporterId,
    required this.reporterName,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    this.anonymous = false,
    this.timeline = const [],
    this.affectedBy = const [],
  });

  int get affectedCount => affectedBy.length;

  /// Name shown to [viewer]. Anonymous reports hide the author from students;
  /// staff can still see who filed it (for follow-up / misuse handling).
  String reporterLabel(AppUser viewer) {
    if (!anonymous) return reporterName;
    if (viewer.isStaff) return '$reporterName (anonymous)';
    if (viewer.uid == reporterId) return '$reporterName (hidden from others)';
    return 'Anonymous student';
  }

  DateTime? timeFor(IncidentStatus s) {
    final m = timeline.where((e) => e.status == s).toList();
    return m.isEmpty ? null : m.last.at;
  }

  /// Owners can edit their report until staff mark it resolved.
  bool canEdit(AppUser u) =>
      u.uid == reporterId && status != IncidentStatus.resolved;

  /// Owners can delete their own report; staff can delete any report.
  bool canDelete(AppUser u) => u.isStaff || u.uid == reporterId;

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    DateTime ts(dynamic v) => (v as Timestamp?)?.toDate() ?? DateTime.now();
    return Incident(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      category: IncidentCategory.parse(d['category']),
      status: IncidentStatus.parse(d['status']),
      location: d['location'] ?? '',
      photoUrl: d['photoUrl'],
      reporterId: d['reporterId'] ?? '',
      reporterName: d['reporterName'] ?? 'Student',
      anonymous: d['anonymous'] ?? false,
      createdAt: ts(d['createdAt']),
      updatedAt: ts(d['updatedAt']),
      timeline: ((d['timeline'] ?? []) as List)
          .map((e) => TimelineEntry.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      affectedBy: List<String>.from(d['affectedBy'] ?? []),
    );
  }

  static Map<String, dynamic> createMap({
    required String title,
    required String description,
    required IncidentCategory category,
    required String location,
    required bool anonymous,
    required AppUser reporter,
    String? photoUrl,
  }) =>
      {
        'title': title.trim(),
        'description': description.trim(),
        'category': category.name,
        'status': IncidentStatus.submitted.name,
        'location': location,
        'photoUrl': photoUrl,
        'anonymous': anonymous,
        'reporterId': reporter.uid,
        'reporterName': reporter.name,
        'affectedBy': <String>[],
        'timeline': [
          TimelineEntry(
            status: IncidentStatus.submitted,
            at: DateTime.now(),
            by: anonymous ? 'Reporter' : reporter.name,
            note: 'Report submitted',
          ).toMap()
        ],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}

/// Which list a screen shows; each scope keeps its own filters.
enum ListScope { campus, mine, staff }

class IncidentFilter {
  String query = '';
  IncidentStatus? status;
  IncidentCategory? category;

  bool get active => query.isNotEmpty || status != null || category != null;

  void clear() {
    query = '';
    status = null;
    category = null;
  }

  List<Incident> apply(List<Incident> input) {
    final q = query.trim().toLowerCase();
    return input.where((i) {
      if (status != null && i.status != status) return false;
      if (category != null && i.category != category) return false;
      if (q.isEmpty) return true;
      return i.title.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q) ||
          i.location.toLowerCase().contains(q) ||
          i.category.label.toLowerCase().contains(q);
    }).toList();
  }
}
