import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/incident.dart';
import '../providers/incident_provider.dart';
import 'common.dart';
import 'incident_card.dart';

class IncidentListView extends StatelessWidget {
  final ListScope scope;
  const IncidentListView({super.key, required this.scope});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    if (p.loading) {
      return Center(child: CircularProgressIndicator(color: AppColors.teal));
    }
    if (p.streamError != null) {
      return EmptyState(
        icon: Icons.wifi_off_rounded,
        title: 'Could not load reports',
        message: p.streamError!,
        action: ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(140, 46)),
          onPressed: () => context.read<IncidentProvider>().retry(),
          child: const Text('Try again'),
        ),
      );
    }
    final items = p.visible(scope);
    if (items.isEmpty) {
      final filtered = p.filterOf(scope).active;
      return EmptyState(
        icon: filtered ? Icons.search_off_rounded : Icons.inbox_outlined,
        title: filtered ? 'No matches' : 'Nothing here yet',
        message: filtered
            ? 'Try a different search or clear the filters.'
            : scope == ListScope.mine
                ? 'Reports you submit will appear here.'
                : 'No incidents have been reported.',
        action: filtered
            ? TextButton(
                onPressed: () => p.clearFilters(scope), child: const Text('Clear filters'))
            : null,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, idx) {
        final inc = items[idx];
        final card = IncidentCard(incident: inc, showReporter: scope == ListScope.staff);
        if (scope != ListScope.staff || inc.status == IncidentStatus.resolved) {
          return card;
        }
        final next = inc.status == IncidentStatus.submitted
            ? IncidentStatus.inProgress
            : IncidentStatus.resolved;
        return Column(children: [
          card,
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                final err = await ctx.read<IncidentProvider>().updateStatus(inc, next, '');
                if (ctx.mounted) {
                  showToast(ctx, err ?? 'Marked as ${next.label}', error: err != null);
                }
              },
              icon: Icon(
                  next == IncidentStatus.inProgress
                      ? Icons.play_arrow_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 18),
              label: Text(next == IncidentStatus.inProgress
                  ? 'Start work'
                  : 'Mark resolved'),
              style: TextButton.styleFrom(foregroundColor: AppColors.teal),
            ),
          ),
        ]);
      },
    );
  }
}
