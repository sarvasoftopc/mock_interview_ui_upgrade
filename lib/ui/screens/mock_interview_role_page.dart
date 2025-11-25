import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import 'package:sarvasoft_moc_interview/models/mock_interview_session.dart';

import '../../providers/cv_jd_provider.dart';
import '../../providers/interview_provider.dart';
import '../../providers/profile_provider.dart';
//
// class MockInterviewRolePage extends StatefulWidget {
//   const MockInterviewRolePage({super.key});
//
//   @override
//   State<MockInterviewRolePage> createState() => _MockInterviewRolePageState();
// }
//
// class _MockInterviewRolePageState extends State<MockInterviewRolePage> {
//   String? _selectedRole;
//   //TODO : Get them from backend
//   final List<String> _roles = [
//     'Frontend Developer',
//     'Backend Developer',
//     'Fullstack Developer',
//     'Data Scientist',
//     'Product Manager',
//     'QA Engineer',
//     'DevOps Engineer',
//     'Mobile Developer'
//   ];
//   bool _useCvJdMatch = true;
//   bool _useVoice = true;
//   int _rounds = 3;
//   final _notesController = TextEditingController();
//
//   @override
//   void dispose() {
//     _notesController.dispose();
//     super.dispose();
//   }
//
//   void _startRoleInterview(BuildContext context, CvJdProvider provider) {
//     final mappedSkills = _useCvJdMatch ? provider.overlapSkills?.take(8).toList() ?? [] : [];
//     final args = {
//       'mode': 'role',
//       'role': _selectedRole,
//       'rounds': _rounds,
//       'useVoice': _useVoice,
//       'cvJdSkills': mappedSkills,
//       'notes': _notesController.text.trim(),
//     };
//
//     Navigator.pushNamed(context, '/mockInterview', arguments: args);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final cvJdProvider = context.watch<CvJdProvider>();
//     final isWide = MediaQuery.of(context).size.width > 920;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Role-based Mock Interview')),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 16, vertical: 18),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             const Text('Role-based Interview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             const Text('Select a role to practice for. We will auto-pick topics and mix behavioral + technical questions.'),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               value: _selectedRole,
//               hint: const Text('Choose role'),
//               items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
//               onChanged: (v) => setState(() => _selectedRole = v),
//               decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
//             ),
//             const SizedBox(height: 12),
//             Row(children: [
//               Checkbox(value: _useCvJdMatch, onChanged: (v) => setState(() => _useCvJdMatch = v ?? true)),
//               const SizedBox(width: 6),
//               const Expanded(child: Text('Use CV↔JD matched skills (if available)')),
//             ]),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Text('Rounds:'),
//                 const SizedBox(width: 12),
//                 DropdownButton<int>(value: _rounds, items: [1, 2, 3, 4, 5].map((n) => DropdownMenuItem(value: n, child: Text('$n'))).toList(), onChanged: (v) => setState(() => _rounds = v ?? 3)),
//                 const Spacer(),
//                 Row(children: [
//                   Switch(value: _useVoice, onChanged: (v) => setState(() => _useVoice = v)),
//                   const SizedBox(width: 6),
//                   const Text('Voice Interview'),
//                 ])
//               ],
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _notesController,
//               minLines: 2,
//               maxLines: 4,
//               decoration: InputDecoration(
//                 hintText: 'Extra instructions for the interviewer (optional)',
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//             ),
//             const SizedBox(height: 14),
//             Row(children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: (_selectedRole == null) ? null : () => _startRoleInterview(context, cvJdProvider),
//                   child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Start Role Interview')),
//                 ),
//               ),
//             ]),
//             const SizedBox(height: 14),
//             if (_useCvJdMatch && (cvJdProvider.overlapSkills?.isNotEmpty ?? false))
//               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 const Text('Skills from CV↔JD analysis (preview):', style: TextStyle(fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 8),
//                 Wrap(spacing: 6, runSpacing: 6, children: cvJdProvider.overlapSkills!.map((s) => Chip(label: Text(s))).toList()),
//               ])
//           ]),
//           ]),lo
//         ),
//       ),
//     );
//   }
// }

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
    'UI/UX Designer',
  ];

  bool _includeBehavioral = true;
  double _difficulty = 2;
  final _notesController = TextEditingController();

  // skills from profile and selected by user
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
        // ignore - we'll show empty skills
      } finally {
        if (!mounted) return;
        setState(() {
          _loadingProfile = false;
          _profileSkills =
              provider.profile?.skills.map((e) => e.toString()).toList() ?? [];
          // default: pre-select top 4 skills (or all if less)
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
      if (add) {
        _selectedSkills.add(s);
      } else {
        _selectedSkills.remove(s);
      }
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
        const SnackBar(content: Text('Please choose a role first')),
      );
      return;
    }
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one skill to practice')),
      );
      return;
    }
    //
    // final args = {
    //   'mode': 'role',
    //   'role': _selectedRole,
    //   'difficulty': _difficulty.toInt(),
    //   'useVoice': true, // always true per requirement
    //   'includeBehavioral': _includeBehavioral,
    //   // pass selected skills from profile
    //   'skills': _selectedSkills.toList(),
    //   'notes': _notesController.text.trim(),
    // };
    final provider = context.read<InterviewProvider>();
    final cvJdProvider = context.read<CvJdProvider>();

    // fetch analysis & questions (provider handles repeated calls / caching)
    await cvJdProvider.startSkillSession(
      skills: _selectedSkills.toList(),
      difficulty: _difficulty.toInt(),
      useVoice: true,
      includeBehavioral: _includeBehavioral,
      mode: "role",
      role: _selectedRole,
    );

    debugPrint("current session with session id:${cvJdProvider.sessionId}");
    provider.loadQuestions(cvJdProvider.questions);
    provider.startSession(cvJdProvider.sessionId, SessionType.normal);

    Navigator.of(context).pushNamed('/question');
  }

  Widget _skillChip(String label) {
    final isSelected = _selectedSkills.contains(label);
    return FilterChip(
      label: SizedBox(
        width: 160, // avoid very long chips pushing layout
        child: Text(label, overflow: TextOverflow.ellipsis),
      ),
      selected: isSelected,
      onSelected: (val) => _toggleSkill(label, val),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 920;

    return Scaffold(
      appBar: AppBar(title: const Text('Role-based Mock Interview')),
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
                  'Role-based Interview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select a role and the skills (from your profile) you want to practice. The interview will use voice + text.',
                ),
                const SizedBox(height: 14),

                // Role selector
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  hint: const Text('Choose role'),
                  items: _roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedRole = v),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Difficulty slider and behavioral
                Row(
                  children: [
                    const Text(
                      'Difficulty:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
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

                const SizedBox(height: 8),
                Row(
                  children: [
                    Switch(
                      value: _includeBehavioral,
                      onChanged: (v) => setState(() => _includeBehavioral = v),
                    ),
                    const SizedBox(width: 8),
                    const Text('Include Behavioral Questions'),
                  ],
                ),

                const SizedBox(height: 16),

                // Profile skills section
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
                              'Skills from your Profile',
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
                          firstChild: _buildProfileSkillsBox(),
                          secondChild: const SizedBox.shrink(),
                          crossFadeState: _showProfileSkills
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 200),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                // select all
                                setState(
                                  () => _selectedSkills.addAll(_profileSkills),
                                );
                              },
                              child: const Text('Select all'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => _selectedSkills.clear());
                              },
                              child: const Text('Clear selection'),
                            ),
                            const Spacer(),
                            // quick add UI small
                            TextButton.icon(
                              onPressed: () async {
                                final added = await _showAddSkillDialog();
                                if (added != null && added.trim().isNotEmpty)
                                  _addCustomSkill(added);
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add skill'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Selected skills summary
                const Text(
                  'Selected Skills',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _selectedSkills.isEmpty
                    ? const Text(
                        'No skills selected yet. Choose from your profile skills above or add a custom one.',
                      )
                    : Container(
                        constraints: const BoxConstraints(maxHeight: 110),
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedSkills
                                .map((s) => Chip(label: Text(s)))
                                .toList(),
                          ),
                        ),
                      ),

                const SizedBox(height: 20),

                // Start button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _selectedSkills.isEmpty
                        ? null
                        : () => _startRoleInterview(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
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
        child: Text(
          'No skills found in your profile. Upload CV on your Profile page to extract skills.',
        ),
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
        title: const Text('Add skill'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'e.g. API Design'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
