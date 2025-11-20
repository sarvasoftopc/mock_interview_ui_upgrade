import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarvasoft_moc_interview/models/mock_interview_session.dart';
import '../../config/app_theme.dart';
import '../../providers/cv_jd_provider.dart';
import '../../providers/interview_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/modern_components.dart';

class MockInterviewSkillPage extends StatefulWidget {
  const MockInterviewSkillPage({super.key});

  @override
  State<MockInterviewSkillPage> createState() => _MockInterviewSkillPageState();
}

class _MockInterviewSkillPageState extends State<MockInterviewSkillPage> {
  final TextEditingController _skillController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedSkills = {};
  double _difficulty = 1.0;
  bool _useVoice = true;
  bool _includeBehavioral = true;
  bool _showCvSkills = true;

  @override
  void dispose() {
    _skillController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addSkillFromText() {
    final t = _skillController.text.trim();
    if (t.isNotEmpty && !_selectedSkills.contains(t)) {
      setState(() {
        _selectedSkills.add(t);
        _skillController.clear();
      });
    }
  }

  void _startSkillInterview(BuildContext context) async {
    final provider = context.read<InterviewProvider>();
    final cvJdProvider = context.read<CvJdProvider>();

    await cvJdProvider.startSkillSession(
      skills: _selectedSkills.toList(),
      difficulty: _difficulty.toInt(),
      useVoice: _useVoice,
      includeBehavioral: _includeBehavioral,
      role: "",
      mode: 'skill'
    );

    provider.loadQuestions(cvJdProvider.questions);
    provider.startSession(cvJdProvider.sessionId, SessionType.normal);

    Navigator.of(context).pushNamed('/question');
  }

  Widget _skillChip(String label) {
    final selected = _selectedSkills.contains(label);
    return FilterChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppTheme.primaryPurple,
      checkmarkColor: Colors.white,
      onSelected: (val) {
        setState(() {
          if (val) {
            _selectedSkills.add(label);
          } else {
            _selectedSkills.remove(label);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profileSkills = (profileProvider.profile?.skills ?? []).map((e) => e.toString()).toList();

    final defaultPopular = <String>[
      'Data Structures',
      'Algorithms',
      'System Design',
      'Flutter',
      'React',
      'Python',
      'SQL',
      'Testing'
    ];

    final size = MediaQuery.of(context).size;
    final isWide = size.width > 860;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Skill-Based Interview'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 16, vertical: 18),
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
                        const Icon(Icons.code, color: Colors.white, size: 32),
                        const SizedBox(width: AppTheme.space3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Skill-Based Interview',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Focus on specific technical skills',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.space8),

                  // CV Skills
                  if (profileSkills.isNotEmpty)
                    ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: SectionHeader(
                                  title: 'Your CV Skills',
                                  subtitle: 'Select from your profile',
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _showCvSkills ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                ),
                                onPressed: () => setState(() => _showCvSkills = !_showCvSkills),
                              )
                            ],
                          ),
                          AnimatedCrossFade(
                            firstChild: Container(
                              constraints: const BoxConstraints(maxHeight: 160),
                              child: SingleChildScrollView(
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: profileSkills.map((s) => _skillChip(s)).toList(),
                                ),
                              ),
                            ),
                            secondChild: const SizedBox.shrink(),
                            crossFadeState: _showCvSkills ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 250),
                          ),
                        ],
                      ),
                    ),

                  if (profileSkills.isNotEmpty) const SizedBox(height: AppTheme.space6),

                  // Popular Skills
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Popular Skills'),
                        const SizedBox(height: AppTheme.space4),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 160),
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: defaultPopular.map((s) => _skillChip(s)).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.space6),

                  // Add Custom Skill
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Add Custom Skill'),
                        const SizedBox(height: AppTheme.space4),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _skillController,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _addSkillFromText(),
                                decoration: AppTheme.inputDecoration('Skill name').copyWith(
                                  hintText: 'e.g. API Design',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    onPressed: _addSkillFromText,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                        
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(AppTheme.space3),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundGray,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                ),
                                child: Row(
                                  children: [
                                    Switch(
                                      value: _useVoice,
                                      activeColor: AppTheme.primaryPurple,
                                      onChanged: (v) => setState(() => _useVoice = v),
                                    ),
                                    const SizedBox(width: AppTheme.space2),
                                    const Text('Voice Mode', style: AppTheme.bodyMedium),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.space3),
                            Expanded(
                              child: Container(
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
                                    const Text('Behavioral', style: AppTheme.bodyMedium),
                                  ],
                                ),
                              ),
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
                        if (_selectedSkills.isEmpty)
                          const Text('No skills selected yet.', style: AppTheme.bodyMedium)
                        else
                          Container(
                            constraints: const BoxConstraints(maxHeight: 150),
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
                    onPressed: _selectedSkills.isEmpty ? null : () => _startSkillInterview(context),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
