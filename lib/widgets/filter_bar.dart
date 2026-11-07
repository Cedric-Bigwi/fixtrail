import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/incident.dart';
import '../providers/incident_provider.dart';
import 'ui_ext.dart';

/// Search + status chips + category chips. Writes into IncidentProvider so the
/// filter survives tab switches.
class FilterBar extends StatefulWidget {
  final ListScope scope;
  const FilterBar({super.key, required this.scope});

  @override
  State<FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends State<FilterBar> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: context.read<IncidentProvider>().filterOf(widget.scope).query);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    final f = p.filterOf(widget.scope);
    if (!f.active && _ctrl.text.isNotEmpty) _ctrl.clear();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          controller: _ctrl,
          onChanged: (v) => p.setQuery(widget.scope, v),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search title, place or category',
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.muted),
            suffixIcon: f.active
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _ctrl.clear();
                      p.clearFilters(widget.scope);
                    })
                : null,
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _Chip(
                label: 'All',
                selected: f.status == null,
                onTap: () => p.setStatus(widget.scope, null)),
            for (final s in IncidentStatus.values)
              _Chip(
                  label: s.label,
                  selected: f.status == s,
                  onTap: () => p.setStatus(widget.scope, f.status == s ? null : s)),
          ],
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            for (final c in IncidentCategory.values)
              _Chip(
                  label: c.label,
                  icon: c.icon,
                  color: c.color,
                  selected: f.category == c,
                  onTap: () => p.setCategory(widget.scope, f.category == c ? null : c)),
          ],
        ),
      ),
    ]);
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? colorOverride;
  final bool selected;
  final VoidCallback onTap;
  const _Chip(
      {required this.label,
      required this.selected,
      required this.onTap,
      this.icon,
      Color? color})
      : colorOverride = color;

  @override
  Widget build(BuildContext context) {
    final color = colorOverride ?? AppColors.teal;
    return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? color : AppColors.field,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: selected ? color : AppColors.line),
            ),
            child: Row(children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: selected ? Colors.white : color),
                const SizedBox(width: 5),
              ],
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.ink)),
            ]),
          ),
        ),
      );
  }
}
