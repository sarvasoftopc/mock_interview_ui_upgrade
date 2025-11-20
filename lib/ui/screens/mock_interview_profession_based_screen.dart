import 'package:flutter/material.dart';

/// ===============================
/// MOCK INTERVIEW SCREEN
/// ===============================
class MockInterviewScreen extends StatelessWidget {
  const MockInterviewScreen({super.key});

  final List<Map<String, dynamic>> roles = const [
    {"title": "Frontend Engineer", "icon": Icons.web_asset},
    {"title": "Backend Engineer", "icon": Icons.dns},
    {"title": "Fullstack Engineer", "icon": Icons.layers},
    {"title": "Data Scientist", "icon": Icons.bar_chart},
    {"title": "Product Manager", "icon": Icons.lightbulb},
    {"title": "HR Interview", "icon": Icons.people},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mock Interview"),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: roles.length,
        itemBuilder: (context, index) {
          final role = roles[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: Icon(role['icon'], color: Colors.pinkAccent, size: 32),
              title: Text(
                role['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("Simulate a full role-based interview"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Trigger role-based mock interview flow
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Starting mock for ${role['title']}")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}