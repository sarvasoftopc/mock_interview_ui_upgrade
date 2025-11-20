import 'package:flutter/material.dart';
class StarStoryScreen extends StatelessWidget {
  const StarStoryScreen({super.key});

  final List<Map<String, dynamic>> starCategories = const [
    {"title": "Leadership", "desc": "Stories about leading teams/projects", "icon": Icons.leaderboard},
    {"title": "Conflict Resolution", "desc": "Handling tough situations", "icon": Icons.handshake},
    {"title": "Problem Solving", "desc": "Overcoming technical/strategic challenges", "icon": Icons.build},
    {"title": "Achievements", "desc": "Highlighting impact and results", "icon": Icons.star},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("STAR Story Bank")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: starCategories.length,
        itemBuilder: (context, index) {
          final cat = starCategories[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Icon(cat['icon'], color: Colors.orange, size: 32),
              title: Text(cat['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(cat['desc']),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // TODO: Trigger STAR story builder for selected category
              },
            ),
          );
        },
      ),
    );
  }
}
