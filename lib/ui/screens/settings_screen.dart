import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/modern_widgets.dart';
import '../widgets/app_drawer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 800 : double.infinity),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isWide ? 32 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Account Section
                  _buildSectionCard(
                    context,
                    title: 'Account',
                    icon: Icons.person_outline,
                    children: [
                      _buildInfoRow(
                        Icons.email_outlined,
                        'Email',
                        authProvider.user?.email ?? 'Not logged in',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        Icons.verified_user_outlined,
                        'User ID',
                        authProvider.userId ?? 'N/A',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Preferences Section
                  _buildSectionCard(
                    context,
                    title: 'Preferences',
                    icon: Icons.tune,
                    children: [
                      _buildSwitchRow(
                        context,
                        Icons.notifications_outlined,
                        'Push Notifications',
                        true,
                        (val) {},
                      ),
                      const Divider(),
                      _buildSwitchRow(
                        context,
                        Icons.volume_up_outlined,
                        'Sound Effects',
                        true,
                        (val) {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // About Section
                  _buildSectionCard(
                    context,
                    title: 'About',
                    icon: Icons.info_outline,
                    children: [
                      _buildInfoRow(Icons.code, 'Version', '1.0.0'),
                      const Divider(),
                      _buildInfoRow(
                        Icons.business,
                        'Company',
                        'SarvaSoft (OPC) Private Limited',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  GradientButton(
                    text: 'Logout',
                    icon: Icons.logout,
                    onPressed: () async {
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Danger Zone
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber, color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Text(
                              'Danger Zone',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Account'),
                                content: const Text(
                                  'Are you sure you want to delete your account? This action cannot be undone.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // TODO: Implement account deletion
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Account deletion not implemented'),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Delete Account'),
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
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: AppTheme.elevatedCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.primaryPurple),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTheme.cardTitle,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: AppTheme.bodyMedium),
          const Spacer(),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    BuildContext context,
    IconData icon,
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTheme.bodyMedium)),
          Switch(
            value: value,
            activeColor: AppTheme.primaryPurple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
