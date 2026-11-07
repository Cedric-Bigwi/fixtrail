import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/network_photo.dart';
import 'photo_viewer_screen.dart';
import '../../widgets/ui_ext.dart';
import 'report_form_screen.dart';

class IncidentDetailScreen extends StatelessWidget {
  final String incidentId;
  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    final me = context.watch<AuthProvider>().profile;
    if (me == null) return const Scaffold(body: SizedBox.shrink());
    final i = p.byId(incidentId);

    if (i == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Report not found',
            message: 'This report was removed or is no longer available.'),
      );
    }

    final fmt = DateFormat('MMM d, yyyy - h:mm a');
    final affected = i.affectedBy.contains(me.uid);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: i.photoUrl != null ? 340 : null,
            backgroundColor: AppColors.paper,
            surfaceTintColor: Colors.transparent,
            title: i.photoUrl == null ? const Text('Incident details') : null,
            leading: i.photoUrl == null
                ? null
                : Padding(
                    padding: const EdgeInsets.all(6),
                    child: CircleAvatar(
                      backgroundColor: tint(Colors.black, 0.45),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
            actions: [
              if (i.canEdit(me) || i.canDelete(me))
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: CircleAvatar(
                    backgroundColor:
                        i.photoUrl != null ? tint(Colors.black, 0.45) : Colors.transparent,
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded,
                          color: i.photoUrl != null ? Colors.white : AppColors.ink),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onSelected: (v) {
                        if (v == 'edit') _edit(context, i);
                        if (v == 'delete') _delete(context, p, i);
                      },
                      itemBuilder: (_) => [
                        if (i.canEdit(me))
                          const PopupMenuItem(value: 'edit', child: Text('Edit report')),
                        if (i.canDelete(me))
                          const PopupMenuItem(value: 'delete', child: Text('Delete report')),
                      ],
                    ),
                  ),
                ),
            ],
            flexibleSpace: i.photoUrl == null
                ? null
                : FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PhotoViewerScreen(url: i.photoUrl!))),
                      child: Stack(fit: StackFit.expand, children: [
                        NetworkPhoto(url: i.photoUrl!, fit: BoxFit.cover),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: [tint(Colors.black, 0.45), Colors.transparent],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 14,
                          bottom: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                                color: tint(Colors.black, 0.5),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.zoom_out_map_rounded, size: 14, color: Colors.white),
                              SizedBox(width: 5),
                              Text('Tap to enlarge',
                                  style: TextStyle(color: Colors.white, fontSize: 12)),
                            ]),
                          ),
                        ),
                      ]),
                    ),
                  ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: tint(i.category.color, 0.14),
                    borderRadius: BorderRadius.circular(30)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(i.category.icon, size: 14, color: i.category.color),
                  const SizedBox(width: 5),
                  Text(i.category.label,
                      style: TextStyle(
                          color: i.category.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ]),
              ),
              const SizedBox(width: 8),
              StatusBadge(i.status),
            ]),
            const SizedBox(height: 12),
            Text(i.title, style: AppText.display(27)),
            const SizedBox(height: 12),
            _meta(Icons.place_outlined, i.location),
            _meta(Icons.calendar_today_outlined, 'Submitted ${fmt.format(i.createdAt)}'),
            _meta(Icons.person_outline_rounded, 'Reported by ${i.reporterLabel(me)}'),
            const SizedBox(height: 22),
            Text('Status timeline', style: AppText.display(20)),
            const SizedBox(height: 14),
            _Stepper(incident: i),
            const SizedBox(height: 24),
            Text('Description', style: AppText.display(20)),
            const SizedBox(height: 8),
            Text(i.description, style: const TextStyle(height: 1.5, fontSize: 15)),
            if (i.reporterId == me.uid) ...[
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: i.canEdit(me) ? () => _edit(context, i) : null,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit report'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      foregroundColor: AppColors.teal,
                      side: BorderSide(color: AppColors.line),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _delete(context, p, i),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      foregroundColor: AppColors.persimmon,
                      side: const BorderSide(color: AppColors.persimmon),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ]),
              if (!i.canEdit(me))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Resolved reports can no longer be edited.',
                      style: TextStyle(color: AppColors.muted, fontSize: 12)),
                ),
            ],
            const SizedBox(height: 24),
            // "Me too": lets students flag that they are affected too (helps staff prioritise)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line)),
              child: Row(children: [
                Icon(Icons.groups_2_outlined, color: AppColors.teal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                      i.affectedCount == 0
                          ? 'Affected by this too?'
                          : '${i.affectedCount} ${i.affectedCount == 1 ? 'person is' : 'people are'} affected',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () async {
                    final err = await p.toggleAffected(i);
                    if (err != null && context.mounted) {
                      showToast(context, err, error: true);
                    }
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: affected ? AppColors.teal : tint(AppColors.teal, 0.1),
                      foregroundColor: affected ? Colors.white : AppColors.teal),
                  child: Text(affected ? 'Me too \u2713' : 'Me too'),
                ),
              ]),
            ),
            if (i.timeline.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Activity', style: AppText.display(20)),
              const SizedBox(height: 10),
              for (final e in i.timeline.reversed)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.line)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    CircleAvatar(
                        radius: 14,
                        backgroundColor: e.status.bg,
                        child: Icon(e.status.icon, size: 15, color: e.status.fg)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.note.isEmpty ? e.status.label : e.note,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('${e.by} - ${fmt.format(e.at)}',
                            style: TextStyle(color: AppColors.muted, fontSize: 12)),
                      ]),
                    ),
                  ]),
                ),
            ],
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: me.isStaff
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: PrimaryButton(
                  label: 'Update status',
                  icon: Icons.published_with_changes_rounded,
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: AppColors.card,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                    builder: (_) => _StatusSheet(incident: i),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  void _edit(BuildContext context, Incident i) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => ReportFormScreen(editing: i)));

  Future<void> _delete(BuildContext context, IncidentProvider p, Incident i) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete this report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Delete', style: TextStyle(color: AppColors.persimmon))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final err = await p.delete(i);
    if (err == null) nav.pop();
    messenger.showSnackBar(SnackBar(
        content: Text(err ?? 'Report deleted'),
        backgroundColor: err == null ? AppColors.ink : AppColors.persimmon));
  }

  Widget _meta(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Icon(icon, size: 16, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: TextStyle(color: AppColors.muted, fontSize: 13.5))),
        ]),
      );
}

class _Stepper extends StatelessWidget {
  final Incident incident;
  const _Stepper({required this.incident});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, h:mm a');
    Widget step(IncidentStatus s) {
      final reached = s.index <= incident.status.index;
      final t = incident.timeFor(s);
      return SizedBox(
        width: 84,
        child: Column(children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: reached ? s.fg : AppColors.sand,
            ),
            child: Icon(reached && s != incident.status ? Icons.check_rounded : s.icon,
                size: 18, color: reached ? Colors.white : AppColors.muted),
          ),
          const SizedBox(height: 6),
          Text(s.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: reached ? AppColors.ink : AppColors.muted)),
          Text(t == null ? '-' : fmt.format(t),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
        ]),
      );
    }

    Widget line(bool on) => Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Container(
                height: 4,
                decoration: BoxDecoration(
                    color: on ? AppColors.teal : AppColors.sand,
                    borderRadius: BorderRadius.circular(4))),
          ),
        );

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      step(IncidentStatus.submitted),
      line(incident.status.index >= 1),
      step(IncidentStatus.inProgress),
      line(incident.status.index >= 2),
      step(IncidentStatus.resolved),
    ]);
  }
}

class _StatusSheet extends StatefulWidget {
  final Incident incident;
  const _StatusSheet({required this.incident});
  @override
  State<_StatusSheet> createState() => _StatusSheetState();
}

class _StatusSheetState extends State<_StatusSheet> {
  late IncidentStatus _status = widget.incident.status;
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 22, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Update status', style: AppText.display(22)),
        const SizedBox(height: 14),
        Wrap(spacing: 8, children: [
          for (final s in IncidentStatus.values)
            ChoiceChip(
              label: Text(s.label),
              selected: _status == s,
              selectedColor: s.bg,
              labelStyle: TextStyle(
                  color: _status == s ? s.fg : AppColors.ink, fontWeight: FontWeight.w700),
              onSelected: (_) => setState(() => _status = s),
            ),
        ]),
        const SizedBox(height: 14),
        TextField(
          controller: _note,
          maxLines: 3,
          decoration: const InputDecoration(
              hintText: 'Add a note for the reporter (optional)'),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Save update',
          loading: _saving,
          onPressed: () async {
            setState(() => _saving = true);
            final err = await context
                .read<IncidentProvider>()
                .updateStatus(widget.incident, _status, _note.text);
            if (!context.mounted) return;
            final messenger = ScaffoldMessenger.of(context);
            Navigator.pop(context);
            messenger.showSnackBar(SnackBar(
                content: Text(err ?? 'Status updated'),
                backgroundColor: err == null ? AppColors.ink : AppColors.persimmon));
          },
        ),
      ]),
    );
  }
}
