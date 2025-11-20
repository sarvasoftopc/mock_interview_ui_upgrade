import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/modern_widgets.dart';
import 'email_confirmation_pending.dart';

/// Modern Sign Up Screen with upgraded UI
/// Preserves all existing functionality
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  Future<void> _signUp() async {
    final auth = context.read<AuthProvider>();

    setState(() => _loading = true);
    await auth.signUp(_emailCtrl.text.trim(), _passCtrl.text);
    setState(() => _loading = false);

    if (auth.userId != null) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => EmailConfirmationPendingScreen(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: isWide ? null : AppTheme.backgroundGradient,
          ),
          child: Row(
            children: [
              if (isWide)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'InterviewAI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'AI-driven Mock Interview Platform',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Wrap(spacing: 12, runSpacing: 12, children: const [
                          _BrandFeature(icon: Icons.mic, label: 'Voice Interviews'),
                          _BrandFeature(icon: Icons.psychology_alt, label: 'AI Adaptive'),
                          _BrandFeature(icon: Icons.school, label: 'Skill Practice'),
                          _BrandFeature(icon: Icons.analytics, label: 'Insights'),
                        ]),
                        const SizedBox(height: 30),
                        const Text('SarvaSoft (OPC) Private Limited',
                            style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: isWide ? 40 : 20, vertical: 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isWide) ..[
                            const SizedBox(height: 6),
                            const Text(
                              'InterviewAI',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryPurple,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'AI-driven Mock Interview Platform',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 18),
                          ],
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusLarge)),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text('Create your account',
                                      style: TextStyle(
                                          fontSize: 20, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailCtrl,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: AppTheme.inputDecoration('Email')
                                        .copyWith(
                                            prefixIcon:
                                                const Icon(Icons.email_outlined)),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passCtrl,
                                    obscureText: _obscure,
                                    decoration: AppTheme.inputDecoration('Password')
                                        .copyWith(
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscure
                                            ? Icons.visibility_off
                                            : Icons.visibility),
                                        onPressed: () =>
                                            setState(() => _obscure = !_obscure),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (auth.errorMessage != null)
                                    Text(auth.errorMessage!,
                                        style: const TextStyle(color: Colors.red)),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 50,
                                    child: GradientButton(
                                      text: 'Sign Up',
                                      onPressed: _signUp,
                                      isLoading: _loading,
                                      icon: Icons.person_add,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                        'Already have an account? Log in',
                                        style: TextStyle(color: AppTheme.primaryPurple)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Center(
                            child: Text(
                              'By creating an account you agree to our Terms & Privacy.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandFeature extends StatelessWidget {
  final IconData icon;
  final String label;
  const _BrandFeature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
