import 'package:flutter/material.dart';

class PanelInterviewScreen extends StatelessWidget {
  const PanelInterviewScreen({super.key});

  final List<Map<String, dynamic>> panelTypes = const [
    {"title": "Tech Panel", "desc": "2-3 AI interviewers for technical rounds", "icon": Icons.computer},
    {"title": "Behavioral Panel", "desc": "HR + Manager panel style questions", "icon": Icons.people},
    {"title": "Mixed Panel", "desc": "Combination of technical & behavioral", "icon": Icons.group},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Panel Interview")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: panelTypes.length,
        itemBuilder: (context, index) {
          final panel = panelTypes[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(panel['icon'], color: Colors.deepPurple, size: 32),
              title: Text(panel['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(panel['desc']),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Trigger multi-AI panel interview flow
              },
            ),
          );
        },
      ),
    );
  }
}
