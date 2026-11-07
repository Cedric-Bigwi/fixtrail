import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants.dart';
import '../../core/validators.dart';
import '../../models/app_user.dart';
import '../../widgets/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final p = context.watch<IncidentProvider>();
    final u = auth.profile;
    if (u == null) return const SizedBox.shrink();
    final mine = p.mine;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
        children: [
          Text('Profile', style: AppText.display(30)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.line)),
            child: Column(children: [
              Row(children: [
                UserAvatar(name: u.name, size: 62),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Flexible(child: Text(u.name, style: AppText.display(22))),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Edit name',
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        color: AppColors.muted,
                        onPressed: () => _editName(context, u),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: u.isStaff
                              ? tint(AppColors.persimmon, 0.15)
                              : tint(AppColors.teal, 0.12),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(u.isStaff ? 'Campus staff' : 'Student',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: u.isStaff ? AppColors.persimmon : AppColors.teal)),
                    ),
                  ]),
                ),
              ]),
              const SizedBox(height: 16),
              _row(Icons.alternate_email_rounded, u.email),
              if (u.department.isNotEmpty) _row(Icons.school_outlined, u.department),
              _row(
                  Icons.verified_outlined,
                  auth.firebaseUser?.emailVerified == true
                      ? 'Email verified'
                      : AppConstants.requireEmailVerification
                          ? 'Email not verified'
                          : 'ALU email account'),
            ]),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
                child: StatTile(
                    icon: Icons.description_outlined,
                    value: mine.length,
                    label: 'Total',
                    color: AppColors.teal)),
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
          const SizedBox(height: 18),
          Material(
            color: AppColors.card,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppColors.line)),
            child: SwitchListTile(
              value: context.watch<ThemeProvider>().isDark,
              onChanged: (v) => context.read<ThemeProvider>().setDark(v),
              secondary: Icon(
                  context.watch<ThemeProvider>().isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: AppColors.saffron),
              title: const Text('Dark mode',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Remembered on this device',
                  style: TextStyle(fontSize: 12.5)),
            ),
          ),
          if (u.isStaff) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.line)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Developer tools', style: AppText.display(18)),
                const SizedBox(height: 4),
                Text('Fill the app with sample reports for demos and screenshots.',
                    style: TextStyle(color: AppColors.muted, fontSize: 13)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(minimumSize: const Size(0, 46)),
                      onPressed: () async {
                        final msg = await context.read<IncidentProvider>().seedDemo();
                        if (context.mounted) showToast(context, msg);
                      },
                      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: const Text('Load demo data'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        side: BorderSide(color: AppColors.line),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    onPressed: () async {
                      final msg = await context.read<IncidentProvider>().clearDemo();
                      if (context.mounted) showToast(context, msg);
                    },
                    child: const Text('Remove'),
                  ),
                ]),
              ]),
            ),
          ],
          const SizedBox(height: 26),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.persimmon,
                side: const BorderSide(color: AppColors.persimmon),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Sign out?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Sign out')),
                    ],
                  ),
                );
                if (ok == true) await auth.signOut();
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData i, String t) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(children: [
          Icon(i, size: 18, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(child: Text(t, style: const TextStyle(fontSize: 14))),
        ]),
      );
}


Future<void> _editName(BuildContext context, AppUser u) async {
  final ctrl = TextEditingController(text: u.name);
  final formKey = GlobalKey<FormState>();
  final newName = await showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Edit your name'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Full name'),
          validator: (v) => Validators.minLength(v, 3, 'Name'),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) Navigator.pop(c, ctrl.text.trim());
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
  if (newName == null || newName == u.name || !context.mounted) return;
  final err = await context.read<AuthProvider>().updateName(newName);
  if (!context.mounted) return;
  if (err != null) {
    showToast(context, err, error: true);
    return;
  }
  await context.read<IncidentProvider>().renameReporter(newName);
  if (context.mounted) showToast(context, 'Name updated');
}
