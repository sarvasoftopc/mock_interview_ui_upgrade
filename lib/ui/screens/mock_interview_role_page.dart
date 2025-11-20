import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarvasoft_moc_interview/models/mock_interview_session.dart';
import '../../config/app_theme.dart';
import '../../providers/cv_jd_provider.dart';
import '../../providers/interview_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/modern_components.dart';

class MockInterviewRolePage extends StatefulWidget {
  const MockInterviewRolePage({super.key});

  @override
  State<MockInterviewRolePage> createState() => _MockInterviewRolePageState();
}

class _MockInterviewRolePageState extends State<MockInterviewRolePage> {
  String? _selectedRole;
  final List<String> _roles = [
    'Frontend Developer',
    'Backend Developer',
    'Fullstack Developer',
    'Data Scientist',
    'Product Manager',
    'QA Engineer',
    'DevOps Engineer',
    'Mobile Developer',
    'AI/ML Engineer',
    'UI/UX Designer'
  ];

  bool _includeBehavioral = true;
  double _difficulty = 2;
  final _notesController = TextEditingController();

  List<String> _profileSkills = [];
  final Set<String> _selectedSkills = <String>{};
  bool _loadingProfile = false;
  bool _showProfileSkills = true;

  @override
  void initState() {
    super.initState();
    _ensureProfileLoaded();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _ensureProfileLoaded() async {
    final provider = context.read<ProfileProvider>();
    if (provider.profile == null) {
      setState(() => _loadingProfile = true);
      try {
        await provider.loadFromServer();
      } catch (e) {
        // ignore
      } finally {
        if (!mounted) return;
        setState(() {
          _loadingProfile = false;
          _profileSkills = provider.profile?.skills.map((e) => e.toString()).toList() ?? [];
          final initial = _profileSkills.take(4).toList();
          _selectedSkills.clear();
          _selectedSkills.addAll(initial);
        });
      }
    } else {
      final providerProfile = provider.profile!;
      _profileSkills = providerProfile.skills.map((e) => e.toString()).toList();
      final initial = _profileSkills.take(4).toList();
      _selectedSkills.clear();
      _selectedSkills.addAll(initial);
    }
  }

  void _toggleSkill(String s, bool add) {
    setState(() {
      if (add)
        _selectedSkills.add(s);
      else
        _selectedSkills.remove(s);
    });
  }

  void _addCustomSkill(String label) {
    final s = label.trim();
    if (s.isEmpty) return;
    if (!_profileSkills.contains(s)) {
      setState(() {
        _profileSkills.insert(0, s);
        _selectedSkills.add(s);
      });
    } else {
      setState(() {
        _selectedSkills.add(s);
      });
    }
  }

  Future<void> _startRoleInterview(BuildContext context) async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a role first'), backgroundColor: AppTheme.warning)
      );
      return;
    }
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one skill to practice'), backgroundColor: AppTheme.warning)
      );
      return;
    }

    final provider = context.read<InterviewProvider>();
    final cvJdProvider = context.read<CvJdProvider>();

    await cvJdProvider.startSkillSession(
      skills: _selectedSkills.toList(),
      difficulty: _difficulty.toInt(),
      useVoice: true,
      includeBehavioral: _includeBehavioral,
      mode: "role",
      role: _selectedRole
    );

    provider.loadQuestions(cvJdProvider.questions);
    provider.startSession(cvJdProvider.sessionId, SessionType.normal);

    Navigator.of(context).pushNamed('/question');
  }

  Widget _skillChip(String label) {
    final isSelected = _selectedSkills.contains(label);
    return FilterChip(
      label: SizedBox(width: 160, child: Text(label, overflow: TextOverflow.ellipsis)),
      selected: isSelected,
      selectedColor: AppTheme.primaryPurple,
      checkmarkColor: Colors.white,
      onSelected: (val) => _toggleSkill(label, val),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 920;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Role-Based Interview'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 48 : 16,
          vertical: 18,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 800 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(AppTheme.space6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.work_outline, color: Colors.white, size: 32),
                      const SizedBox(width: AppTheme.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Role-Based Interview',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Practice for specific job positions',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.space8),

                // Role Selection
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Select Role',
                        subtitle: 'Choose the position you\'re preparing for',
                      ),
                      const SizedBox(height: AppTheme.space4),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        hint: const Text('Choose a role'),
                        items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                        onChanged: (v) => setState(() => _selectedRole = v),
                        decoration: AppTheme.inputDecoration('Select Role').copyWith(
                          prefixIcon: const Icon(Icons.work),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.space6),

                // Settings
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Interview Settings'),
                      const SizedBox(height: AppTheme.space4),
                      
                      Row(
                        children: [
                          const Text('Difficulty:', style: AppTheme.titleSmall),
                          Expanded(
                            child: Slider(
                              value: _difficulty,
                              min: 1,
                              max: 3,
                              divisions: 2,
                              activeColor: AppTheme.primaryPurple,
                              label: _difficulty == 1 ? 'Easy' : (_difficulty == 2 ? 'Medium' : 'Hard'),
                              onChanged: (v) => setState(() => _difficulty = v),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            ),
                            child: Text(
                              _difficulty == 1 ? 'Easy' : (_difficulty == 2 ? 'Medium' : 'Hard'),
                              style: AppTheme.labelMedium.copyWith(color: AppTheme.primaryPurple),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space3),
                      Container(
                        padding: const EdgeInsets.all(AppTheme.space3),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundGray,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: Row(
                          children: [
                            Switch(
                              value: _includeBehavioral,
                              activeColor: AppTheme.primaryPurple,
                              onChanged: (v) => setState(() => _includeBehavioral = v),
                            ),
                            const SizedBox(width: AppTheme.space2),
                            const Expanded(
                              child: Text('Include Behavioral Questions', style: AppTheme.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.space6),

                // Skills Section
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: SectionHeader(
                              title: 'Skills from Your Profile',
                              subtitle: 'Select skills to practice',
                            ),
                          ),
                          if (_loadingProfile)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          IconButton(
                            icon: Icon(
                              _showProfileSkills ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            ),
                            onPressed: () => setState(() => _showProfileSkills = !_showProfileSkills),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.space4),
                      AnimatedCrossFade(
                        firstChild: _buildProfileSkillsBox(),
                        secondChild: const SizedBox.shrink(),
                        crossFadeState: _showProfileSkills ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 200),
                      ),
                      const SizedBox(height: AppTheme.space3),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () => setState(() => _selectedSkills.addAll(_profileSkills)),
                            icon: const Icon(Icons.select_all),
                            label: const Text('Select All'),
                          ),
                          TextButton.icon(
                            onPressed: () => setState(() => _selectedSkills.clear()),
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear'),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                              final added = await _showAddSkillDialog();
                              if (added != null && added.trim().isNotEmpty) _addCustomSkill(added);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Skill'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.space6),

                // Selected Skills
                ModernCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Selected Skills'),
                      const SizedBox(height: AppTheme.space4),
                      _selectedSkills.isEmpty
                          ? const Text(
                              'No skills selected yet. Choose from your profile skills above.',
                              style: AppTheme.bodyMedium,
                            )
                          : Container(
                              constraints: const BoxConstraints(maxHeight: 110),
                              child: SingleChildScrollView(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _selectedSkills
                                      .map((s) => ModernBadge(label: s, color: AppTheme.primaryPurple))
                                      .toList(),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.space8),

                // Start Button
                ModernButton(
                  text: 'Start Interview',
                  icon: Icons.play_arrow,
                  isFullWidth: true,
                  onPressed: _selectedSkills.isEmpty ? null : () => _startRoleInterview(context),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSkillsBox() {
    if (_loadingProfile) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_profileSkills.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: Text('No skills found in your profile. Upload CV on your Profile page to extract skills.'),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      padding: const EdgeInsets.only(top: 8),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _profileSkills.map((s) => _skillChip(s)).toList(),
        ),
      ),
    );
  }

  Future<String?> _showAddSkillDialog() {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        title: const Text('Add Skill'),
        content: TextField(
          controller: ctrl,
          decoration: AppTheme.inputDecoration('Skill name').copyWith(
            hintText: 'e.g. API Design',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          ModernButton(
            text: 'Add',
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
          ),
        ],
      ),
    );
  }
}
