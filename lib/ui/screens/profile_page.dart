import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarvasoft_moc_interview/utils/file_util.dart';

import '../../models/profile.dart';
import '../../providers/profile_provider.dart';
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
      // Initialize selected skills to everything extracted by default
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

      // Show a non-dismissible "Processing" dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
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
        // Update cached provider profile copy
        final profile = provider.profile;
        if (profile != null) {
          profile.cvFilename = _cvFileName;
          profile.cvText = profile.cvText; // updated in provider
          profile.skills = _skills;
        //  await provider.createOrUpdateProfile(profile);
        } else {
          // create a minimal profile if none exists

         // provider.profile = Profile(userId: userId, fullName: _nameCtrl.text, email: _emailCtrl.text, skills: _skills, cvFilename: _cvFileName);
          //await provider.createOrUpdateProfile(newProfile);

        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CV analysis complete')));

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Analyze failed: $e')));
        }
      } finally {
        setState(() { _loading = false; });
        // Close the processing dialog if still open
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  void _addSkillFromField(String value) {
    final s = value.trim();
    if (s.isEmpty) return;
    if (!_skills.contains(s)) setState(() => _skills.add(s));
  }

  void _removeSkill(String s) => setState(() => _skills.remove(s));

  Future<void> _saveProfile() async {
    // show "Creating profile" dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
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
    if(userId == null){
      userId = "demo_user"; // replace by real user id
    }
    final uid = userId; // replace by real user id
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
      // close dialog then navigate to profile screen
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // close saving dialog
        // Show success toast then navigate
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
        Navigator.pushReplacementNamed(context, '/profile');
      }
    } catch (e) {
      // close dialog and show error
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    return Scaffold(
      appBar: CustomAppBar(context: context, titleText: "Create Profile"),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full name')),
          TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 8),
          TextField(controller: _headlineCtrl, decoration: const InputDecoration(labelText: 'Headline / Target role')),
          TextField(controller: _locationCtrl, decoration: const InputDecoration(labelText: 'Location')),
          TextField(controller: _yearsCtrl, decoration: const InputDecoration(labelText: 'Years of experience'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _roleCtrl, decoration: const InputDecoration(labelText: 'Add preferred role'))),
            IconButton(icon: const Icon(Icons.add), onPressed: () {
              final r = _roleCtrl.text.trim();
              if (r.isNotEmpty && !_preferredRoles.contains(r)) {
                setState(() { _preferredRoles.add(r); _roleCtrl.clear(); });
              }
            })
          ]),
          Wrap(spacing: 8, children: _preferredRoles.map((r) => Chip(label: Text(r), onDeleted: () { setState(() { _preferredRoles.remove(r); }); })).toList()),
          const SizedBox(height: 16),
          const Text('Skills', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

// Bounded scrollable area for many skills (prevents overflow)
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: _skills.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('No extracted skills yet. Upload your CV to extract.'),
            )
                : SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills.map((s) {
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
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 12),
// Manual add / Upload row (keeps existing functionality)
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(hintText: 'Add skill manually'),
                  onSubmitted: (v) {
                    final s = v.trim();
                    if (s.isEmpty) return;
                    if (!_skills.contains(s)) {
                      setState(() {
                        _skills.add(s);
                        _selectedSkills.add(s);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _pickCvAndAnalyze,
                icon: const Icon(Icons.upload_file),
                label: Text(_cvFileName == null ? 'Upload CV & Extract' : 'Re-extract'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            Checkbox(value: provider.profile?.publicProfile ?? false, onChanged: (v) {
              final p = provider.profile;
              if (p != null) {
                p.publicProfile = v ?? false;
                provider.createOrUpdateProfile(p);
              }
            }),
            const Text('Public profile (visible to recruiters)')
          ]),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _loading ? null : _saveProfile, child: Text(_loading ? 'Saving...' : 'Save Profile')),
        ]),
      ),
    );
  }
}
