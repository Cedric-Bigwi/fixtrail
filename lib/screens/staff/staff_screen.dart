import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/incident.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/filter_bar.dart';
import '../../widgets/incident_list_view.dart';

/// Staff-only desk. The tab is only built for staff accounts, and Firestore
/// rules independently reject status changes from non-staff users.
class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
          child: Text('Staff desk', style: AppText.display(30)),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Text('Review reports and move them toward resolution.',
              style: TextStyle(color: AppColors.muted)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Expanded(
                child: StatTile(
                    icon: Icons.send_rounded,
                    value: p.count(p.all, IncidentStatus.submitted),
                    label: 'Awaiting',
                    color: AppColors.saffron)),
            const SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    icon: Icons.handyman_rounded,
                    value: p.count(p.all, IncidentStatus.inProgress),
                    label: 'In progress',
                    color: AppColors.lilac)),
            const SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    icon: Icons.check_circle_outline_rounded,
                    value: p.count(p.all, IncidentStatus.resolved),
                    label: 'Resolved',
                    color: AppColors.moss)),
          ]),
        ),
        const SizedBox(height: 16),
        const FilterBar(scope: ListScope.staff),
        const Expanded(child: IncidentListView(scope: ListScope.staff)),
      ]),
    );
  }
}
