import 'package:flutter_test/flutter_test.dart';
import 'package:fixtrail/models/incident.dart';

Incident make(String id, String title, IncidentCategory c, IncidentStatus s,
        {String location = 'Block A'}) =>
    Incident(
      id: id,
      title: title,
      description: 'desc',
      category: c,
      status: s,
      location: location,
      reporterId: 'u1',
      reporterName: 'Amina',
      createdAt: DateTime(2026, 10, 1),
      updatedAt: DateTime(2026, 10, 1),
    );

void main() {
  final list = [
    make('1', 'Water shortage', IncidentCategory.water, IncidentStatus.submitted,
        location: 'Student Residence'),
    make('2', 'Broken projector', IncidentCategory.facilities, IncidentStatus.inProgress),
    make('3', 'Overflowing bin', IncidentCategory.sanitation, IncidentStatus.resolved,
        location: 'Cafeteria'),
  ];

  test('filters by status', () {
    final f = IncidentFilter()..status = IncidentStatus.resolved;
    expect(f.apply(list).map((e) => e.id), ['3']);
  });

  test('filters by category', () {
    final f = IncidentFilter()..category = IncidentCategory.water;
    expect(f.apply(list).single.id, '1');
  });

  test('search matches title and location', () {
    expect((IncidentFilter()..query = 'projector').apply(list).single.id, '2');
    expect((IncidentFilter()..query = 'cafeteria').apply(list).single.id, '3');
  });

  test('combined filters + clear', () {
    final f = IncidentFilter()
      ..status = IncidentStatus.submitted
      ..category = IncidentCategory.facilities;
    expect(f.apply(list), isEmpty);
    f.clear();
    expect(f.apply(list).length, 3);
    expect(f.active, isFalse);
  });

  test('status parsing falls back safely', () {
    expect(IncidentStatus.parse('inProgress'), IncidentStatus.inProgress);
    expect(IncidentStatus.parse('???'), IncidentStatus.submitted);
  });
}
