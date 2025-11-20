import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
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

  Future<void> _checkIfConfirmed() async {
    setState(() {
      _checking = true;
      _message = null;
    });

    final auth = context.read<AuthProvider>();

    try {
      await auth.signIn(widget.email, widget.password);
      if (auth.isLoggedIn) {
        // preserved navigation
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        setState(() {
          _message = 'Could not sign in yet (please confirm your email).';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Not confirmed yet: $e';
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
      setState(() => _message = 'Confirmation email resent. Check your inbox.');
    } catch (e) {
      setState(() => _message = 'Could not resend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm your email')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 20, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.indigo.shade50,
                            child: const Icon(Icons.email_outlined, color: Colors.indigo),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Confirm your email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 6),
                                Text('We sent a confirmation link to ${widget.email}. Open it to activate your account.',
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        icon: _checking ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check_circle_outline),
                        label: Text(_checking ? 'Checking...' : 'I confirmed — Check now'),
                        onPressed: _checking ? null : _checkIfConfirmed,
                        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Resend confirmation email'),
                        onPressed: _resend,
                      ),
                      if (_message != null) ...[
                        const SizedBox(height: 12),
                        Text(_message!, style: const TextStyle(color: Colors.black87)),
                      ],
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      // Suggestions / Next steps
                      Row(
                        children: [
                          const Icon(Icons.help_outline, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tip: Check spam folder if you don\'t see the email. If the link expired, press resend.',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
