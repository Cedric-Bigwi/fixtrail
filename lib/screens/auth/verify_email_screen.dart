import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});
  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  int _cooldown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown <= 1) {
        t.cancel();
      }
      if (mounted) setState(() => _cooldown--);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                  color: tint(AppColors.saffron, 0.3), shape: BoxShape.circle),
              child: Icon(Icons.mark_email_unread_outlined,
                  size: 44, color: AppColors.teal),
            ),
            const SizedBox(height: 24),
            Text('Verify your ALU email', style: AppText.display(32)),
            const SizedBox(height: 10),
            Text(
              'We sent a verification link to\n${auth.email}\n\nOpen it, then come back and tap the button below. This keeps FixTrail limited to the ALU community.',
              style: TextStyle(color: AppColors.muted, height: 1.5, fontSize: 15),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: "I've verified my email",
              icon: Icons.verified_outlined,
              loading: auth.busy,
              onPressed: () async {
                final ok = await auth.checkVerified();
                if (!ok && context.mounted) {
                  showToast(context, 'Not verified yet. Check your inbox and spam folder.',
                      error: true);
                }
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.line),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _cooldown > 0
                    ? null
                    : () async {
                        final err = await auth.resendVerification();
                        if (!context.mounted) return;
                        showToast(context, err ?? 'Verification email sent again.',
                            error: err != null);
                        if (err == null) _startCooldown();
                      },
                child: Text(_cooldown > 0 ? 'Resend in ${_cooldown}s' : 'Resend email'),
              ),
            ),
            const Spacer(),
            Center(
              child: TextButton(
                  onPressed: auth.signOut, child: const Text('Use a different account')),
            ),
          ]),
        ),
      ),
    );
  }
}
