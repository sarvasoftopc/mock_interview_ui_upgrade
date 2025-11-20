import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import 'package:sarvasoft_moc_interview/models/mock_interview_session.dart';

import '../../providers/cv_jd_provider.dart';
import '../../providers/interview_provider.dart';
import '../../providers/profile_provider.dart'; // now uses ProfileProvider

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
  bool _showCvSkills = true; // collapsible toggle

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


      // fetch analysis & questions (provider handles repeated calls / caching)
      await cvJdProvider.startSkillSession(skills: _selectedSkills.toList(), difficulty: _difficulty.toInt(),useVoice: _useVoice,includeBehavioral: _includeBehavioral,role:"", mode: 'skill');

      debugPrint("current session with session id:${cvJdProvider.sessionId}");
      provider.loadQuestions(cvJdProvider.questions);
      provider.startSession(cvJdProvider.sessionId,SessionType.normal);

      Navigator.of(context).pushNamed('/question');
    //Navigator.pushNamed(context, '/mockInterview', arguments: args);
  }

  Widget _skillChip(String label) {
    final selected = _selectedSkills.contains(label);
    return FilterChip(
      label: Text(label),
      selected: selected,
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
    final profileSkills =
    (profileProvider.profile?.skills ?? []).map((e) => e.toString()).toList();

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

    final isWide = MediaQuery.of(context).size.width > 860;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skill-based Mock Interview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select or type skills you want to practice. Your CV skills appear below — you can toggle which ones to include.',
        ),
        const SizedBox(height: 14),

        // 🔹 Collapsible CV skills section
        if (profileSkills.isNotEmpty)
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Your CV Skills',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _showCvSkills
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                        onPressed: () =>
                            setState(() => _showCvSkills = !_showCvSkills),
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
                          children:
                          profileSkills.map((s) => _skillChip(s)).toList(),
                        ),
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                    crossFadeState: _showCvSkills
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 250),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 14),

        // 🔹 Popular/common skills
        const Text('Popular Skills',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
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

        const SizedBox(height: 18),
        const Text('Add a custom skill'),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _skillController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addSkillFromText(),
                decoration: InputDecoration(
                  hintText: 'e.g. API Design',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addSkillFromText,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // 🔹 Difficulty and options
        Row(
          children: [
            const Text('Difficulty:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            Expanded(
              child: Slider(
                value: _difficulty,
                min: 1,
                max: 3,
                divisions: 2,
                label: _difficulty == 1
                    ? 'Easy'
                    : (_difficulty == 2 ? 'Medium' : 'Hard'),
                onChanged: (v) => setState(() => _difficulty = v),
              ),
            ),
            Text(
              _difficulty == 1
                  ? 'Easy'
                  : (_difficulty == 2 ? 'Medium' : 'Hard'),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Switch(
              value: _useVoice,
              onChanged: (v) => setState(() => _useVoice = v),
            ),
            const Text('Use Voice (TTS/STT)'),
            const Spacer(),
            Switch(
              value: _includeBehavioral,
              onChanged: (v) => setState(() => _includeBehavioral = v),
            ),
            const Text('Include Behavioral'),
          ],
        ),
        const SizedBox(height: 16),

        // 🔹 Selected skills summary
        const Text('Selected Skills',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        if (_selectedSkills.isEmpty)
          const Text('No skills selected yet.')
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                _selectedSkills.map((s) => Chip(label: Text(s))).toList(),
              ),
            ),
          ),

        const SizedBox(height: 24),

        // 🔹 Start button
        Center(
          child: ElevatedButton.icon(
            onPressed: _selectedSkills.isEmpty
                ? null
                : () => _startSkillInterview(context),
            icon: const Icon(Icons.play_arrow),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Text('Start Interview'),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Skill Mock Interview')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 48 : 16,
            vertical: 18,
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: content,
          ),
        ),
      ),
    );
  }
}

