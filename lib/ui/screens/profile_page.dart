import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarvasoft_moc_interview/utils/file_util.dart';
import '../../config/app_theme.dart';
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/modern_widgets.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_app_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _headlineCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _yearsCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();

  List<String> _skills = [];
  Set<String> _selectedSkills = <String>{};
  List<String> _preferredRoles = [];
  String? _cvFileName;
  String? _cvBase64;
  bool _loading = false;

  get cvBase64 => _cvBase64;
  set cvBase64(value) => _cvBase64 = value;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ProfileProvider>();
    final p = provider.profile;
    if (p != null) {
      _nameCtrl.text = p.fullName ?? "";
      _emailCtrl.text = p.email ?? "";
      _headlineCtrl.text = p.headline ?? "";
      _locationCtrl.text = p.location ?? "";
      _yearsCtrl.text = p.yearsExperience?.toString() ?? "";
      _skills = List.from(p.skills);
      _preferredRoles = List.from(p.preferredRoles);
      _cvFileName = p.cvFilename;
      _selectedSkills = Set<String>.from(_skills);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _headlineCtrl.dispose();
    _locationCtrl.dispose();
    _yearsCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCvAndAnalyze() async {
    final result = await FileUtil.fileSelector(context);
    if (result != null) {
      setState(() {
        _loading = true;
        _cvFileName = result.fileName;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
            content: Row(
              children: const [
                SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 16),
                Expanded(child: Text('Analyzing CV — extracting skills...')),
              ],
            ),
          ),
        ),
      );

      cvBase64 = result.text;
      final provider = context.read<ProfileProvider>();
      try {
        final extractedSkills = await provider.analyzeCvText(_cvFileName!, cvBase64);
        setState(() {
          _skills = extractedSkills;
        });
        final profile = provider.profile;
        if (profile != null) {
          profile.cvFilename = _cvFileName;
          profile.cvText = profile.cvText;
          profile.skills = _skills;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CV analysis complete'), backgroundColor: AppTheme.primaryPurple),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Analyze failed: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        setState(() { _loading = false; });
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  Future<void> _saveProfile() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
          content: Row(
            children: const [
              SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 16),
              Expanded(child: Text('Saving profile...')),
            ],
          ),
        ),
      ),
    );
    setState(() { _loading = true; });
    final provider = context.read<ProfileProvider>();
    String? userId = await provider.getUserId();
    if (userId == null) {
      userId = "demo_user";
    }
    final uid = userId;
    final years = int.tryParse(_yearsCtrl.text);
    final p = Profile(
      userId: uid,
      fullName: _nameCtrl.text,
      email: _emailCtrl.text,
      headline: _headlineCtrl.text,
      location: _locationCtrl.text,
      yearsExperience: years,
      preferredRoles: _preferredRoles,
      cvFilename: _cvFileName,
      skills: _selectedSkills.toList(),
      cvText: _cvBase64,
      publicProfile: provider.profile?.publicProfile ?? false,
    );
    try {
      await provider.createOrUpdateProfile(p);
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved'), backgroundColor: AppTheme.primaryPurple),
        );
        Navigator.pushReplacementNamed(context, '/profile');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: CustomAppBar(context: context, titleText: "Create Profile"),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 800 : double.infinity),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isWide ? 32 : 16),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isWide ? 32 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: const Icon(Icons.person_outline, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Build Your Professional Profile',
                              style: AppTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Basic Info Section
                      _buildSectionHeader('Basic Information', Icons.info_outline),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: AppTheme.inputDecoration('Full Name').copyWith(
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: AppTheme.inputDecoration('Email').copyWith(
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _headlineCtrl,
                        decoration: AppTheme.inputDecoration('Headline / Target Role').copyWith(
                          prefixIcon: const Icon(Icons.work_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _locationCtrl,
                              decoration: AppTheme.inputDecoration('Location').copyWith(
                                prefixIcon: const Icon(Icons.location_on_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _yearsCtrl,
                              decoration: AppTheme.inputDecoration('Years of Experience').copyWith(
                                prefixIcon: const Icon(Icons.calendar_today),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Preferred Roles Section
                      _buildSectionHeader('Preferred Roles', Icons.star_outline),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _roleCtrl,
                              decoration: AppTheme.inputDecoration('Add Preferred Role').copyWith(
                                prefixIcon: const Icon(Icons.add_circle_outline),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GradientButton(
                            text: 'Add',
                            icon: Icons.add,
                            onPressed: () {
                              final r = _roleCtrl.text.trim();
                              if (r.isNotEmpty && !_preferredRoles.contains(r)) {
                                setState(() {
                                  _preferredRoles.add(r);
                                  _roleCtrl.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _preferredRoles
                            .map(
                              (r) => Chip(
                                label: Text(r),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() {
                                    _preferredRoles.remove(r);
                                  });
                                },
                                backgroundColor: AppTheme.primaryLight,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24),

                      // Skills Section
                      _buildSectionHeader('Skills & Expertise', Icons.lightbulb_outline),
                      const SizedBox(height: 16),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 220),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3), width: 2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          color: AppTheme.primaryLight.withOpacity(0.3),
                        ),
                        child: _skills.isEmpty
                            ? const Center(
                                child: Text(
                                  'No skills yet. Upload your CV or add manually.',
                                  style: AppTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : SingleChildScrollView(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _skills.map((s) {
                                    final selected = _selectedSkills.contains(s);
                                    return FilterChip(
                                      label: Text(s, overflow: TextOverflow.ellipsis),
                                      selected: selected,
                                      selectedColor: AppTheme.primaryPurple,
                                      checkmarkColor: Colors.white,
                                      backgroundColor: Colors.white,
                                      onSelected: (val) {
                                        setState(() {
                                          if (val) {
                                            _selectedSkills.add(s);
                                          } else {
                                            _selectedSkills.remove(s);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: AppTheme.inputDecoration('Add Skill Manually').copyWith(
                                prefixIcon: const Icon(Icons.code),
                              ),
                              // onSubmitted: (v) {
                              //   final s = v.trim();
                              //   if (s.isEmpty) return;
                              //   if (!_skills.contains(s)) {
                              //     setState(() {
                              //       _skills.add(s);
                              //       _selectedSkills.add(s);
                              //     });
                              //   }
                              // },
                            ),
                          ),
                          const SizedBox(width: 8),
                          GradientButton(
                            text: _cvFileName == null ? 'Upload CV' : 'Re-upload',
                            icon: Icons.upload_file,
                            onPressed: _pickCvAndAnalyze,
                          ),
                        ],
                      ),
                      if (_cvFileName != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'CV uploaded: $_cvFileName',
                                  style: TextStyle(color: Colors.green.shade700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Public Profile Toggle
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.public, color: AppTheme.primaryPurple),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Make profile public (visible to recruiters)',
                                style: AppTheme.bodyMedium,
                              ),
                            ),
                            Switch(
                              value: provider.profile?.publicProfile ?? false,
                              activeColor: AppTheme.primaryPurple,
                              onChanged: (v) {
                                final p = provider.profile;
                                if (p != null) {
                                  p.publicProfile = v;
                                  provider.createOrUpdateProfile(p);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: GradientButton(
                          text: _loading ? 'Saving...' : 'Save Profile',
                          icon: Icons.save,
                          isLoading: _loading,
                          onPressed: _loading ? () {} : _saveProfile,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryPurple, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(color: AppTheme.primaryPurple),
        ),
      ],
    );
  }
}
