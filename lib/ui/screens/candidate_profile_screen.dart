import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/modern_widgets.dart';
import '../widgets/app_drawer.dart';

class CandidateProfileScreen extends StatelessWidget {
  const CandidateProfileScreen({super.key});

  Widget _labelValue(String label, String? value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ..[
            Icon(icon, size: 20, color: AppTheme.primaryPurple),
            const SizedBox(width: 12),
          ],
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value == null || value.isEmpty ? '—' : value,
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipsRow(String label, List<String>? items, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ..[
                Icon(icon, size: 20, color: AppTheme.primaryPurple),
                const SizedBox(width: 12),
              ],
              Text(
                label,
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          (items == null || items.isEmpty)
              ? Text('—', style: AppTheme.bodyMedium)
              : Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: items
                          .map(
                            (s) => Chip(
                              label: Text(s),
                              backgroundColor: AppTheme.primaryLight,
                              labelStyle: const TextStyle(
                                color: AppTheme.primaryPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final Profile? profile = provider.profile;
    final isWide = MediaQuery.of(context).size.width > 900;
    final isTablet = MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width <= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/createProfile');
            },
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: profile == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryLight,
                      ),
                      child: Icon(
                        Icons.person_outline,
                        size: 64,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No profile found',
                      style: AppTheme.pageTitle,
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      text: 'Create Profile',
                      icon: Icons.add,
                      onPressed: () => Navigator.pushNamed(context, '/createProfile'),
                    ),
                  ],
                ),
              )
            : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 1200 : double.infinity),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isWide ? 32 : 16),
                    child: Column(
                      children: [
                        // Header Card with Avatar
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          padding: const EdgeInsets.all(32),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white, width: 4),
                                ),
                                child: Center(
                                  child: Text(
                                    profile.fullName?.isNotEmpty == true
                                        ? profile.fullName![0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryPurple,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.fullName ?? 'No Name',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      profile.headline ?? 'No headline',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Content Cards
                        if (isWide || isTablet)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildInfoCard([
                                  _labelValue('Email', profile.email, icon: Icons.email_outlined),
                                  const Divider(),
                                  _labelValue('Location', profile.location, icon: Icons.location_on_outlined),
                                  const Divider(),
                                  _labelValue('Years of Experience', profile.yearsExperience?.toString(), icon: Icons.work_outline),
                                  const Divider(),
                                  _labelValue(
                                    'Public Profile',
                                    profile.publicProfile == true ? 'Yes' : 'No',
                                    icon: Icons.public,
                                  ),
                                ]),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInfoCard([
                                  _chipsRow(
                                    'Preferred Roles',
                                    profile.preferredRoles,
                                    icon: Icons.stars,
                                  ),
                                  const Divider(),
                                  _chipsRow(
                                    'Skills',
                                    profile.skills.map((e) => e.toString()).toList(),
                                    icon: Icons.code,
                                  ),
                                  const Divider(),
                                  _labelValue('CV File', profile.cvFilename, icon: Icons.description),
                                ]),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildInfoCard([
                                _labelValue('Email', profile.email, icon: Icons.email_outlined),
                                const Divider(),
                                _labelValue('Location', profile.location, icon: Icons.location_on_outlined),
                                const Divider(),
                                _labelValue('Years of Experience', profile.yearsExperience?.toString(), icon: Icons.work_outline),
                                const Divider(),
                                _labelValue(
                                  'Public Profile',
                                  profile.publicProfile == true ? 'Yes' : 'No',
                                  icon: Icons.public,
                                ),
                              ]),
                              const SizedBox(height: 16),
                              _buildInfoCard([
                                _chipsRow(
                                  'Preferred Roles',
                                  profile.preferredRoles,
                                  icon: Icons.stars,
                                ),
                                const Divider(),
                                _chipsRow(
                                  'Skills',
                                  profile.skills.map((e) => e.toString()).toList(),
                                  icon: Icons.code,
                                ),
                                const Divider(),
                                _labelValue('CV File', profile.cvFilename, icon: Icons.description),
                              ]),
                            ],
                          ),
                        const SizedBox(height: 24),
                        // Edit Button
                        SizedBox(
                          width: isWide ? 300 : double.infinity,
                          child: GradientButton(
                            text: 'Edit Profile',
                            icon: Icons.edit,
                            onPressed: () => Navigator.pushNamed(context, '/createProfile'),
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

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: AppTheme.elevatedCardDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
