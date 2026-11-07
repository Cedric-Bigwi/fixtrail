import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_painter.dart';
import '../../widgets/incident_card.dart';
import '../reports/report_form_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenReports;
  const HomeScreen({super.key, required this.onOpenReports});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().profile;
    if (user == null) return const SizedBox.shrink();
    final p = context.watch<IncidentProvider>();
    final mine = p.mine;
    final recent = p.all.take(4).toList();
    final open = p.all.length - p.count(p.all, IncidentStatus.resolved);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
        children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Hello, ${user.firstName}', style: AppText.display(30)),
                const SizedBox(height: 6),
                Text(
                    user.isStaff
                        ? 'Staff account - you can update report statuses.'
                        : 'Help make our campus better.',
                    style: TextStyle(color: AppColors.muted)),
              ]),
            ),
            UserAvatar(name: user.name, size: 50),
          ]),
          const SizedBox(height: 20),
          _Hero(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ReportFormScreen())),
          ),
          const SizedBox(height: 26),
          SectionHeader(title: 'My summary', action: 'See all', onAction: onOpenReports),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: StatTile(
                    icon: Icons.description_outlined,
                    value: mine.length,
                    label: 'My reports',
                    color: AppColors.teal)),
            const SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    icon: Icons.send_rounded,
                    value: p.count(mine, IncidentStatus.submitted),
                    label: 'Submitted',
                    color: AppColors.saffron)),
            const SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    icon: Icons.handyman_rounded,
                    value: p.count(mine, IncidentStatus.inProgress),
                    label: 'In progress',
                    color: AppColors.lilac)),
            const SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    icon: Icons.check_circle_outline_rounded,
                    value: p.count(mine, IncidentStatus.resolved),
                    label: 'Resolved',
                    color: AppColors.moss)),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.sand, borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              Icon(Icons.insights_rounded, color: AppColors.teal),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                    '$open open issues on campus - ${p.resolvedThisWeek} fixed in the last 7 days',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
              ),
            ]),
          ),
          const SizedBox(height: 26),
          SectionHeader(title: 'Happening on campus', action: 'See all', onAction: onOpenReports),
          const SizedBox(height: 12),
          if (p.loading)
            Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: CircularProgressIndicator(color: AppColors.teal)))
          else if (recent.isEmpty)
            const SizedBox(
                height: 220,
                child: EmptyState(
                    icon: Icons.celebration_outlined,
                    title: 'All quiet',
                    message: 'No reports yet. Spot something? Be the first to report it.'))
          else
            for (final i in recent) ...[
              IncidentCard(incident: i),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final VoidCallback onTap;
  const _Hero({required this.onTap});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [AppColors.tealDeep, AppColors.teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),
          child: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: HeroPainter())),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('See something\nbroken?', style: AppText.display(26, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Report it. Track the fix.',
                    style: TextStyle(color: tint(Colors.white, 0.8))),
                const Spacer(),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        color: AppColors.persimmon,
                        borderRadius: BorderRadius.circular(16)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Report an issue',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      );
}
