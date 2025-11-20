import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/modern_widgets.dart';
import 'home_screen.dart';

class EmailConfirmationPendingScreen extends StatefulWidget {
  final String email;
  final String password;
  const EmailConfirmationPendingScreen({required this.email, required this.password});

  @override
  _EmailConfirmationPendingScreenState createState() => _EmailConfirmationPendingScreenState();
}

class _EmailConfirmationPendingScreenState extends State<EmailConfirmationPendingScreen> {
  bool _checking = false;
  String? _message;
  Color? _messageColor;

  Future<void> _checkIfConfirmed() async {
    setState(() {
      _checking = true;
      _message = null;
    });

    final auth = context.read<AuthProvider>();

    try {
      await auth.signIn(widget.email, widget.password);
      if (auth.isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() {
          _message = 'Could not sign in yet (please confirm your email).';
          _messageColor = Colors.orange;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Not confirmed yet: $e';
        _messageColor = Colors.red;
      });
    } finally {
      setState(() {
        _checking = false;
      });
    }
  }

  Future<void> _resend() async {
    setState(() => _message = null);
    try {
      final auth = context.read<AuthProvider>();
      await auth.signUp(widget.email, widget.password);
      setState(() {
        _message = 'Confirmation email resent. Check your inbox.';
        _messageColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        _message = 'Could not resend: $e';
        _messageColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Your Email'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 80 : 20,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                decoration: AppTheme.cardDecoration,
                padding: EdgeInsets.all(isWide ? 40 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Email Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        boxShadow: AppTheme.cardDecoration.boxShadow,
                      ),
                      child: const Icon(
                        Icons.mark_email_unread,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    const Text(
                      'Check Your Email',
                      style: AppTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // Email Address
                    Text(
                      widget.email,
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Description
                    const Text(
                      'We sent a confirmation link to your email. Click on the link to activate your account.',
                      style: AppTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Check Button
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        text: _checking ? 'Checking...' : 'I Confirmed — Check Now',
                        icon: Icons.check_circle_outline,
                        isLoading: _checking,
                        onPressed: _checking ? () {} : _checkIfConfirmed,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Resend Button
                    TextButton.icon(
                      icon: const Icon(Icons.refresh, color: AppTheme.primaryPurple),
                      label: const Text(
                        'Resend confirmation email',
                        style: TextStyle(color: AppTheme.primaryPurple),
                      ),
                      onPressed: _resend,
                    ),
                    // Message Display
                    if (_message != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _messageColor?.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(
                            color: _messageColor?.withOpacity(0.3) ?? Colors.grey,
                          ),
                        ),
                        child: Text(
                          _message!,
                          style: TextStyle(color: _messageColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Tips
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppTheme.primaryPurple,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tip: Check your spam folder if you don\'t see the email. If the link expired, press resend.',
                              style: AppTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
