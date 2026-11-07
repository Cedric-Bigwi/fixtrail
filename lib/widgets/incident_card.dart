import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../core/theme.dart';
import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../screens/reports/incident_detail_screen.dart';
import 'common.dart';
import 'network_photo.dart';
import 'ui_ext.dart';

class IncidentCard extends StatelessWidget {
  final Incident incident;
  final bool showReporter;
  const IncidentCard({super.key, required this.incident, this.showReporter = false});

  @override
  Widget build(BuildContext context) {
    final me = context.read<AuthProvider>().profile;
    if (me == null) return const SizedBox.shrink();
    final i = incident;
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => IncidentDetailScreen(incidentId: i.id))),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Thumb(incident: i),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(i.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.place_outlined, size: 14, color: AppColors.muted),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(i.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  ),
                ]),
                if (showReporter) ...[
                  const SizedBox(height: 2),
                  Text('by ${i.reporterLabel(me)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.muted, fontSize: 12)),
                ],
                const SizedBox(height: 8),
                Row(children: [
                  StatusBadge(i.status),
                  const Spacer(),
                  if (i.affectedCount > 0) ...[
                    Icon(Icons.groups_2_outlined, size: 15, color: AppColors.muted),
                    const SizedBox(width: 3),
                    Text('${i.affectedCount}',
                        style: TextStyle(color: AppColors.muted, fontSize: 12)),
                    const SizedBox(width: 10),
                  ],
                  Text(timeago.format(i.createdAt),
                      style: TextStyle(color: AppColors.muted, fontSize: 12)),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final Incident incident;
  const _Thumb({required this.incident});

  @override
  Widget build(BuildContext context) {
    final c = incident.category;
    final fallback = Container(
      width: 72,
      height: 72,
      decoration:
          BoxDecoration(color: tint(c.color, 0.14), borderRadius: BorderRadius.circular(16)),
      child: Icon(c.icon, color: c.color, size: 30),
    );
    final url = incident.photoUrl;
    if (url == null) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: NetworkPhoto(
        url: url,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        fallback: fallback,
      ),
    );
  }
}
