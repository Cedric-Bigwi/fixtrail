import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'reports/report_form_screen.dart';
import 'reports/reports_screen.dart';
import 'staff/staff_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static int _lastIndex = 0; // survives the rebuild caused by a theme switch
  int _index = _lastIndex;

  void _go(int i) => setState(() => _index = _lastIndex = i);

  void _openForm() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const ReportFormScreen()));

  @override
  Widget build(BuildContext context) {
    final isStaff = context.select<AuthProvider, bool>((a) => a.isStaff);
    final pages = <Widget>[
      HomeScreen(onOpenReports: () => _go(1)),
      const ReportsScreen(),
      if (isStaff) const StaffScreen(),
      const ProfileScreen(),
    ];
    final index = _index >= pages.length ? 0 : _index;

    // Navigation entries: pageIndex == -1 means the centre "Report" button.
    final entries = <_Nav>[
      const _Nav(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
      const _Nav(1, Icons.list_alt_outlined, Icons.list_alt_rounded, 'Reports'),
      const _Nav(-1, Icons.add_rounded, Icons.add_rounded, 'Report'),
      if (isStaff)
        const _Nav(2, Icons.admin_panel_settings_outlined,
            Icons.admin_panel_settings_rounded, 'Staff'),
      _Nav(isStaff ? 3 : 2, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.line)),
          boxShadow: [
            BoxShadow(
                color: tint(AppColors.ink, 0.06), blurRadius: 18, offset: const Offset(0, -4))
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 80,
            child: Row(children: [
              for (final e in entries)
                Expanded(
                  child: e.page == -1
                      ? _CenterButton(onTap: _openForm)
                      : _NavButton(
                          nav: e,
                          active: index == e.page,
                          onTap: () => _go(e.page)),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Nav {
  final int page;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _Nav(this.page, this.icon, this.activeIcon, this.label);
}

class _NavButton extends StatelessWidget {
  final _Nav nav;
  final bool active;
  final VoidCallback onTap;
  const _NavButton({required this.nav, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.teal : AppColors.muted;
    return InkWell(
      onTap: onTap,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: active ? tint(AppColors.teal, 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(active ? nav.activeIcon : nav.icon, color: color, size: 24),
        ),
        const SizedBox(height: 2),
        Text(nav.label,
            style: TextStyle(
                fontSize: 11.5,
                color: color,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
      ]),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CenterButton({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Transform.translate(
          offset: const Offset(0, -12),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [AppColors.persimmon, Color(0xFFF08A4B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                border: Border.all(color: AppColors.card, width: 4),
                boxShadow: [
                  BoxShadow(
                      color: tint(AppColors.persimmon, 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 6))
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 2),
            const Text('Report',
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.persimmon)),
          ]),
        ),
      );
}
