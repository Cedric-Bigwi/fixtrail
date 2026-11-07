import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/hero_painter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _dept = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _register = false;
  bool _hide = true;

  @override
  void dispose() {
    for (final c in [_name, _dept, _email, _pass, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    final err = _register
        ? await auth.register(
            name: _name.text,
            email: _email.text,
            password: _pass.text,
            department: _dept.text)
        : await auth.signIn(_email.text, _pass.text);
    if (err != null && mounted) showToast(context, err, error: true);
  }

  Future<void> _forgot() async {
    final v = Validators.aluEmail(_email.text);
    if (v != null) {
      showToast(context, 'Enter your ALU email above first.', error: true);
      return;
    }
    final err = await context.read<AuthProvider>().resetPassword(_email.text);
    if (mounted) {
      showToast(context, err ?? 'Password reset email sent.', error: err != null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthProvider>().busy;
    return Scaffold(
      backgroundColor: AppColors.tealDeep,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          SizedBox(
            height: 170,
            child: Stack(children: [
              Positioned.fill(child: CustomPaint(painter: HeroPainter())),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                          color: AppColors.persimmon,
                          borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.handyman_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(AppConstants.appName,
                        style: AppText.display(32, color: Colors.white)),
                  ]),
                  const SizedBox(height: 14),
                  Text(AppConstants.tagline,
                      style: TextStyle(color: tint(Colors.white, 0.8), fontSize: 14.5)),
                ]),
              ),
            ]),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Form(
                  key: _form,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _Toggle(
                        register: _register,
                        onChanged: (v) => setState(() => _register = v)),
                    const SizedBox(height: 22),
                    Text(_register ? 'Create your account' : 'Welcome back',
                        style: AppText.display(26)),
                    const SizedBox(height: 4),
                    Text(
                        _register
                            ? 'Use your ALU email. We will send a verification link.'
                            : 'Sign in with your verified ALU email.',
                        style: TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 20),
                    if (_register) ...[
                      TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                            hintText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline_rounded)),
                        validator: (v) => Validators.minLength(v, 3, 'Name'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dept,
                        decoration: const InputDecoration(
                            hintText: 'Programme / department (optional)',
                            prefixIcon: Icon(Icons.school_outlined)),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                          hintText: 'name@alustudent.com',
                          prefixIcon: Icon(Icons.alternate_email_rounded)),
                      validator: Validators.aluEmail,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pass,
                      obscureText: _hide,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_hide
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _hide = !_hide),
                        ),
                      ),
                      validator: _register
                          ? Validators.password
                          : (v) => Validators.required(v, 'Password'),
                    ),
                    if (_register) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirm,
                        obscureText: _hide,
                        decoration: const InputDecoration(
                            hintText: 'Confirm password',
                            prefixIcon: Icon(Icons.lock_reset_rounded)),
                        validator: (v) => Validators.confirm(v, _pass.text),
                      ),
                    ],
                    if (!_register)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: _forgot, child: const Text('Forgot password?')),
                      ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: _register ? 'Create account' : 'Sign in',
                      loading: busy,
                      onPressed: _submit,
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool register;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.register, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget seg(String t, bool active, VoidCallback onTap) => Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.teal : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(t,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : AppColors.muted)),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: AppColors.sand, borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        seg('Sign in', !register, () => onChanged(false)),
        seg('Register', register, () => onChanged(true)),
      ]),
    );
  }
}
