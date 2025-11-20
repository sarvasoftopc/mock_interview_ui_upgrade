import 'package:flutter/material.dart';
class CareerCoachScreen extends StatelessWidget {
  const CareerCoachScreen({super.key});

  final List<Map<String, dynamic>> coachOptions = const [
    {"title": "Resume Review", "desc": "AI reviews your resume and gives feedback", "icon": Icons.description},
    {"title": "Skill Gap Analysis", "desc": "AI compares your skills to target roles", "icon": Icons.analytics},
    {"title": "Career Path Guidance", "desc": "AI suggests next steps for growth", "icon": Icons.trending_up},
    {"title": "Interview Readiness", "desc": "AI highlights your weak areas", "icon": Icons.check_circle},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Career Coach")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: coachOptions.length,
        itemBuilder: (context, index) {
          final option = coachOptions[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(option['icon'], color: Colors.green, size: 32),
              title: Text(option['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(option['desc']),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Trigger career coach AI analysis flow
              },
            ),
          );
        },
      ),
    );
  }
}
