import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cv_jd_provider.dart';
import '../../providers/profile_provider.dart';

/// Reusable app drawer. Keep navigation logic here so UIs stay clean.
class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _loading = false;

  Widget _drawerItem(BuildContext context, IconData icon, String title, String route,
      {bool replace = false}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(context).pop();
        if (replace) {
          Navigator.pushReplacementNamed(context, route);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }

  Future<void> _onSkillDashboardTap(BuildContext context) async {
    if (_loading) return;
    setState(() => _loading = true);

    // Capture navigator & scaffold messenger BEFORE awaiting anything.
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Capture provider before awaiting
    final provider = context.read<CvJdProvider>();

    bool ok = false;
    try {
      // If you have prepareSkillDashboard() on provider, use it instead:
      ok = await provider.prepareSkillDashboard(context);
    } catch (e, st) {
      debugPrint('[AppDrawer] prepareSkillDashboard/fetchLastAnalysis failed: $e\n$st');
      ok = false;
    }

    // If widget got unmounted while we awaited, bail out.
    if (!mounted) return;

    // Close drawer (use captured navigator)
    try {
      navigator.pop();
    } catch (e) {
      // ignore - navigator may already be popping
    }

    if (ok) {
      // Navigate to skills
      navigator.pushNamed('/skills');
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Failed to prepare Skill Dashboard')),
      );
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _onProfileTap(BuildContext context) async {
    if (_loading) return;
    setState(() => _loading = true);

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final profileProvider = context.read<ProfileProvider>();
    try {
      final ok = await profileProvider.loadFromServer();
      // close drawer BEFORE navigation
      navigator.pop();

      if (ok) {
        navigator.pushNamed('/profile');
      } else {
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Profile not found or not loaded')));
      }
    } catch (e) {
      // network/server error
      navigator.pop();
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.indigo,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Menu', style: TextStyle(color: Colors.white, fontSize: 20)),
                  SizedBox(height: 8),
                  // TODO: Replace with user avatar, name, email
                  // CircleAvatar(...), Text(userName), etc.
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _drawerItem(context, Icons.dashboard, "Home", '/dashboard', replace: true),
                  // Custom Skill Dashboard item
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text("Skill Dashboard"),
                    trailing: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : null,
                    onTap: () => _onSkillDashboardTap(context),
                  ),
                  _drawerItem(context, Icons.access_time_filled_sharp, "Sessions", '/sessions', replace: true),
                  _drawerItem(context, Icons.mic, "Mock Interview", '/mock'),
                  _drawerItem(context, Icons.report, "Reports", '/reports'),
                  _drawerItem(context, Icons.report, "Your Insights", '/insights'),
                  _drawerItem(context, Icons.article, "Resume Builder", '/resumeBuilder'),
                  _drawerItem(context, Icons.settings, "Settings", '/settings'),


                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Profile"),
                    trailing: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : null,
                    onTap: () => _onProfileTap(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.logout_outlined),
                      label: const Text('Logout'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        // TODO: call sign out logic
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
