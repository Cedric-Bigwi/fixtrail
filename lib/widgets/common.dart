import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/incident.dart';
import 'ui_ext.dart';

void showToast(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.persimmon : AppColors.ink,
    ));
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  const PrimaryButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.loading = false,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
          : Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label),
            ]),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(title, style: AppText.display(21))),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!,
                style: const TextStyle(
                    color: AppColors.persimmon, fontWeight: FontWeight.w700)),
          ),
      ]);
}

class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  const UserAvatar({super.key, required this.name, this.size = 46});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(RegExp(r'\s+')).take(2).map((e) => e[0].toUpperCase()).join();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
            colors: [AppColors.persimmon, AppColors.saffron],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
      ),
      child: Text(initials,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * 0.36)),
    );
  }
}

class StatTile extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;
  const StatTile(
      {super.key,
      required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: tint(color, 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text('$value', style: AppText.display(24)),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
        ]),
      );
}

class StatusBadge extends StatelessWidget {
  final IncidentStatus status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration:
            BoxDecoration(color: status.bg, borderRadius: BorderRadius.circular(30)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: status.fg, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(status.label,
              style: TextStyle(
                  color: status.fg, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  const EmptyState(
      {super.key, required this.icon, required this.title, required this.message, this.action});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration:
                  BoxDecoration(color: AppColors.sand, shape: BoxShape.circle),
              child: Icon(icon, size: 34, color: AppColors.teal),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppText.display(20), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, height: 1.4)),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ]),
        ),
      );
}

/// A tappable form field that opens a bottom sheet of options.
class PickerField extends FormField<String> {
  PickerField({
    super.key,
    required String label,
    required List<String> options,
    required IconData icon,
    String? initial,
    required ValueChanged<String> onChanged,
    super.validator,
  }) : super(
          initialValue: initial,
          builder: (state) {
            final ctx = state.context;
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  final picked = await showModalBottomSheet<String>(
                    context: ctx,
                    backgroundColor: AppColors.card,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
                    builder: (c) => SafeArea(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                            child: Text(label, style: AppText.display(20)),
                          ),
                          for (final o in options)
                            ListTile(
                              title: Text(o),
                              trailing: o == state.value
                                  ? Icon(Icons.check_circle, color: AppColors.teal)
                                  : null,
                              onTap: () => Navigator.pop(c, o),
                            ),
                        ],
                      ),
                    ),
                  );
                  if (picked != null) {
                    state.didChange(picked);
                    onChanged(picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.field,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: state.hasError ? AppColors.persimmon : AppColors.line),
                  ),
                  child: Row(children: [
                    Icon(icon, color: AppColors.teal, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(state.value ?? 'Select $label',
                          style: TextStyle(
                              color: state.value == null
                                  ? AppColors.muted
                                  : AppColors.ink)),
                    ),
                    Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.muted),
                  ]),
                ),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 14, top: 6),
                  child: Text(state.errorText!,
                      style: const TextStyle(color: AppColors.persimmon, fontSize: 12)),
                ),
            ]);
          },
        );
}
