import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/incident.dart';
import '../../widgets/filter_bar.dart';
import '../../widgets/incident_list_view.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Row(children: [
              Text('Reports', style: AppText.display(30)),
            ]),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: AppColors.sand, borderRadius: BorderRadius.circular(18)),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                  color: AppColors.teal, borderRadius: BorderRadius.circular(14)),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.muted,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              tabs: const [Tab(text: 'Campus'), Tab(text: 'My reports')],
            ),
          ),
          const SizedBox(height: 14),
          const Expanded(
            child: TabBarView(children: [
              _ScopePage(scope: ListScope.campus),
              _ScopePage(scope: ListScope.mine),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ScopePage extends StatelessWidget {
  final ListScope scope;
  const _ScopePage({required this.scope});

  @override
  Widget build(BuildContext context) => Column(children: [
        FilterBar(scope: scope),
        Expanded(child: IncidentListView(scope: scope)),
      ]);
}
