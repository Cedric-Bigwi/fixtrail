import 'package:cloud_firestore/cloud_firestore.dart';

/// Sample campus incidents used to populate Firestore for demos/screenshots.
/// Every document carries `seeded: true` so it can be removed in one tap.
class DemoData {
  static const _students = [
    'Amina Hassan',
    'Kevin Mugisha',
    'Grace Uwase',
    'Daniel Okello',
    'Fatou Diallo',
    'Samuel Tesfaye',
  ];

  // title, description, category, location, status, hours ago, reporter idx,
  // anonymous, "me too" count
  static const _rows = <List<Object>>[
    ['Water shortage', 'There has been no water supply at the Social Commons restrooms since this morning. It is affecting most people on the upper floor.', 'water', 'Social Commons', 'inProgress', 5, 0, false, 7],
    ['Broken classroom projector', 'The projector in a Learning Commons classroom shows a blank screen. Lectures are being delayed.', 'facilities', 'Learning Commons', 'submitted', 2, 1, false, 4],
    ['Overflowing bin', 'The bins next to the Food Court entrance are overflowing and attracting flies.', 'sanitation', 'Food Court', 'resolved', 72, 2, false, 2],
    ['Power outage in computer lab', 'Half of the lab in Enterprise Commons has had no electricity since yesterday afternoon.', 'electricity', 'Enterprise Commons', 'inProgress', 26, 3, false, 9],
    ['Broken chairs on library 2nd floor', 'At least five chairs are wobbling or missing backs. Some are unsafe to sit on.', 'furniture', 'Library', 'submitted', 8, 4, false, 3],
    ['Poor lighting along Collab Street', 'The lights along Collab Street are off in the evening. It feels unsafe after 7pm.', 'safety', 'Collab Street', 'submitted', 30, 5, true, 12],
    ['Leaking sink in Fab Lab', 'The sink in the Fab Lab has been dripping continuously and flooding the floor.', 'water', 'Fab Lab', 'resolved', 120, 1, false, 1],
    ['Blocked drain after rain', 'Rainwater is pooling outside the Event Spaces because the drain is blocked.', 'sanitation', 'Event Spaces', 'inProgress', 50, 2, false, 5],
    ['Elevator out of service', 'The elevator at the Leadership Center has an out-of-order sign. People with mobility needs cannot reach upper floors.', 'facilities', 'Leadership Center', 'submitted', 4, 3, false, 6],
    ['ID card reader not working', 'The card reader at the Leadership Center entrance does not open with ID cards, causing queues.', 'safety', 'Leadership Center', 'resolved', 144, 4, false, 8],
    ['Flickering lights in the library', 'Lights on the first floor keep flickering and are giving people headaches.', 'electricity', 'Library', 'submitted', 70, 0, false, 5],
    ['Cracked glass panel', 'A glass panel near the Social Commons seating area is cracked and could break.', 'facilities', 'Social Commons', 'inProgress', 12, 5, true, 2],
  ];

  static String _team(String category) {
    switch (category) {
      case 'safety':
        return 'Security Desk';
      case 'sanitation':
        return 'Sanitation Crew';
      default:
        return 'Facilities Office';
    }
  }

  static List<Map<String, dynamic>> build() {
    final now = DateTime.now();
    Timestamp ts(DateTime d) => Timestamp.fromDate(d);

    return _rows.map((r) {
      final title = r[0] as String;
      final desc = r[1] as String;
      final category = r[2] as String;
      final location = r[3] as String;
      final status = r[4] as String;
      final hoursAgo = r[5] as int;
      final idx = r[6] as int;
      final anonymous = r[7] as bool;
      final meToo = r[8] as int;

      final created = now.subtract(Duration(hours: hoursAgo));
      final totalMin = hoursAgo * 60;
      final started = created.add(Duration(minutes: (totalMin * 0.25).round()));
      final finished = created.add(Duration(minutes: (totalMin * 0.6).round()));
      final team = _team(category);
      final name = _students[idx];

      final timeline = <Map<String, dynamic>>[
        {
          'status': 'submitted',
          'at': ts(created),
          'by': anonymous ? 'Reporter' : name,
          'note': 'Report submitted',
        },
      ];
      var last = created;
      if (status == 'inProgress' || status == 'resolved') {
        timeline.add({
          'status': 'inProgress',
          'at': ts(started),
          'by': team,
          'note': 'Team assigned and on the way',
        });
        last = started;
      }
      if (status == 'resolved') {
        timeline.add({
          'status': 'resolved',
          'at': ts(finished),
          'by': team,
          'note': 'Issue fixed. Thanks for reporting!',
        });
        last = finished;
      }

      return {
        'title': title,
        'description': desc,
        'category': category,
        'status': status,
        'location': location,
        'photoUrl': null,
        'anonymous': anonymous,
        'reporterId': 'demo_user_$idx',
        'reporterName': name,
        'affectedBy': List.generate(meToo, (i) => 'demo_affected_$i'),
        'timeline': timeline,
        'createdAt': ts(created),
        'updatedAt': ts(last),
        'seeded': true,
      };
    }).toList();
  }
}
