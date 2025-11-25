import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/profile_provider.dart';

class MockInterviewAdaptivePage extends StatefulWidget {
  const MockInterviewAdaptivePage({super.key});

  @override
  State<MockInterviewAdaptivePage> createState() =>
      _MockInterviewAdaptivePageState();
}

class _MockInterviewAdaptivePageState extends State<MockInterviewAdaptivePage> {
  double _initialDifficulty = 2; // Medium
  int _maxQuestions = 10;
  double _adaptiveness = 0.7; // new control: how quickly AI adapts
  bool _recordSession = true;
  bool _enableEmotionHints = true;
  String _feedbackStyle = 'Encouraging';

  final List<String> _feedbackStyles = [
    'Encouraging',
    'Neutral',
    'Challenging',
  ];
  bool _showProfileSkills = true;
  final Set<String> _selectedSkills = {};
  List<String> _profileSkills = [];
  bool _loadingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadProfileSkills();
  }

  Future<void> _loadProfileSkills() async {
    final profileProvider = context.read<ProfileProvider>();
    setState(() => _loadingProfile = true);
    try {
      await profileProvider.loadFromServer();
    } catch (_) {}
    final skills =
        profileProvider.profile?.skills.map((e) => e.toString()).toList() ?? [];
    setState(() {
      _loadingProfile = false;
      _profileSkills = skills;
      _selectedSkills.addAll(skills.take(5)); // preselect first few
    });
  }

  void _startAdaptiveInterview(BuildContext context) {
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select at least one skill to begin.")),
      );
      return;
    }

    final args = {
      'initialDifficulty': _initialDifficulty.toInt(),
      'adaptiveness': _adaptiveness,
      'maxQuestions': _maxQuestions,
      'feedbackStyle': _feedbackStyle,
      'skills': _selectedSkills.toList(),
      'recordSession': _recordSession,
    };

    Navigator.pushNamed(
      context,
      '/mockInterviewAdaptiveSession',
      arguments: args,
    );
  }

  Widget _skillChip(String s) {
    final selected = _selectedSkills.contains(s);
    return FilterChip(
      label: Text(s, overflow: TextOverflow.ellipsis),
      selected: selected,
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
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Adaptive Interview')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 48 : 16,
            vertical: 18,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Adaptive Interview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This mode dynamically adjusts difficulty and follow-up tone based on your answers and emotions. Voice is always enabled.',
                ),
                const SizedBox(height: 20),

                // Initial difficulty
                Row(
                  children: [
                    const Text('Initial Difficulty:'),
                    Expanded(
                      child: Slider(
                        value: _initialDifficulty,
                        min: 1,
                        max: 3,
                        divisions: 2,
                        label: _initialDifficulty == 1
                            ? 'Easy'
                            : (_initialDifficulty == 2 ? 'Medium' : 'Hard'),
                        onChanged: (v) =>
                            setState(() => _initialDifficulty = v),
                      ),
                    ),
                    Text(
                      _initialDifficulty == 1
                          ? 'Easy'
                          : (_initialDifficulty == 2 ? 'Medium' : 'Hard'),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Adaptiveness level
                Row(
                  children: [
                    const Text('Adaptiveness:'),
                    Expanded(
                      child: Slider(
                        value: _adaptiveness,
                        min: 0.3,
                        max: 1.0,
                        divisions: 7,
                        label: _adaptiveness < 0.5
                            ? 'Slow'
                            : (_adaptiveness < 0.8 ? 'Moderate' : 'High'),
                        onChanged: (v) => setState(() => _adaptiveness = v),
                      ),
                    ),
                    Text(
                      _adaptiveness < 0.5
                          ? 'Slow'
                          : (_adaptiveness < 0.8 ? 'Moderate' : 'High'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Max questions dropdown
                Row(
                  children: [
                    const Text('Max Questions:'),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: _maxQuestions,
                      items: [5, 8, 10, 15]
                          .map(
                            (n) =>
                                DropdownMenuItem(value: n, child: Text('$n')),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _maxQuestions = v ?? 10),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Feedback style dropdown
                Row(
                  children: [
                    const Text('Feedback Style:'),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _feedbackStyle,
                      items: _feedbackStyles
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _feedbackStyle = v ?? 'Encouraging'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Switches
                Row(
                  children: [
                    Switch(
                      value: _recordSession,
                      onChanged: (v) => setState(() => _recordSession = v),
                    ),
                    const Text('Record Session'),
                    const Spacer(),
                    Switch(
                      value: _enableEmotionHints,
                      onChanged: (v) => setState(() => _enableEmotionHints = v),
                    ),
                    const Text('Emotion Hints'),
                  ],
                ),

                const SizedBox(height: 20),

                // Skills from profile
                Card(
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Your Profile Skills',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            if (_loadingProfile)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            IconButton(
                              icon: Icon(
                                _showProfileSkills
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                              ),
                              onPressed: () => setState(
                                () => _showProfileSkills = !_showProfileSkills,
                              ),
                            ),
                          ],
                        ),
                        AnimatedCrossFade(
                          firstChild: _buildSkillSection(),
                          secondChild: const SizedBox.shrink(),
                          crossFadeState: _showProfileSkills
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 250),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Start button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _selectedSkills.isEmpty
                        ? null
                        : () => _startAdaptiveInterview(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      child: Text('Start Adaptive Interview'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillSection() {
    if (_loadingProfile) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_profileSkills.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          'No skills found in your profile. Upload CV to extract them.',
        ),
      );
    }
    return Container(
      constraints: const BoxConstraints(maxHeight: 180),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _profileSkills.map((s) => _skillChip(s)).toList(),
        ),
      ),
    );
  }
}
