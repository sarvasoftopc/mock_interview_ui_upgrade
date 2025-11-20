// lib/screens/candidate_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/profile.dart';
import '../../providers/profile_provider.dart';


class CandidateProfileScreen extends StatelessWidget {
  const CandidateProfileScreen({super.key});

  Widget _labelValue(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value == null || value.isEmpty ? '—' : value)),
        ],
      ),
    );
  }

  Widget _chipsRow(String label, List<String>? items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            child: (items == null || items.isEmpty)
                ? const Text('—')
                : Container(
              // bound height so long lists scroll instead of overflow
              constraints: const BoxConstraints(maxHeight: 180),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items.map((s) => Chip(label: Text(s))).toList(),
                ),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          TextButton.icon(
            onPressed: () {
              // Navigate to edit/create profile screen
              Navigator.pushNamed(context, '/createProfile');
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text('Edit', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
        child: profile == null
            ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No profile found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/createProfile'),
                child: const Text('Create Profile'),
              )
            ],
          ),
        )
            : LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final left = <Widget>[
            // left column (basic info)
            _labelValue('Full name', profile.fullName),
            _labelValue('Email', profile.email),
            _labelValue('Headline', profile.headline),
            _labelValue('Location', profile.location),
            _labelValue('Years experience', profile.yearsExperience?.toString()),
            _labelValue('Public profile', profile.publicProfile == true ? 'Yes' : 'No'),
          ];

          final right = <Widget>[
            // right column (roles, skills, CV)
            _chipsRow('Preferred roles', profile.preferredRoles),
            _chipsRow('Skills', profile.skills.map((e) => e.toString()).toList()),
            _labelValue('CV file', profile.cvFilename),
          ];

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Card(
                        child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: left),
                              ),
                            )
                ),
                const SizedBox(width: 14),
                Expanded(child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: right),
                  ),
                )),
              ],
            );
          } else {
            return ListView(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: left),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: right),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/createProfile'),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}
