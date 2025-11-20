import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../widgets/modern_widgets.dart';
import '../widgets/app_drawer.dart';

/// Modern Practice Hub Screen with upgraded UI
/// Preserves all existing functionality
class PracticeHubScreen extends StatelessWidget {
  const PracticeHubScreen({super.key});

  final List<Map<String, dynamic>> skills = const [
    {"name": "React", "icon": Icons.web, "color": 0xFF61DAFB},
    {"name": "Java", "icon": Icons.coffee, "color": 0xFFF89820},
    {"name": "Python", "icon": Icons.memory, "color": 0xFF3776AB},
    {"name": "SQL", "icon": Icons.storage, "color": 0xFF4479A1},
    {"name": "System Design", "icon": Icons.account_tree, "color": 0xFF667EEA},
    {"name": "Algorithms", "icon": Icons.functions, "color": 0xFF764BA2},
    {"name": "Behavioral", "icon": Icons.people_alt, "color": 0xFF667EEA},
    {"name": "HR / Soft Skills", "icon": Icons.record_voice_over, "color": 0xFF764BA2},
  ];

  int _columnsForWidth(double width) {
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Practice Hub"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: LayoutBuilder(builder: (context, constraints) {
          final crossAxis = _columnsForWidth(constraints.maxWidth);
          final padding = EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 1000 ? 32 : 16,
            vertical: 16,
          );

          return SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Choose a skill to practice',
                    style: AppTheme.sectionTitle,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: skills.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxis,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: crossAxis == 1 ? 2.5 : 1.3,
                  ),
                  itemBuilder: (context, index) {
                    final skill = skills[index];
                    return _SkillCard(
                      icon: skill['icon'] as IconData,
                      title: skill['name'] as String,
                      color: Color(skill['color'] as int),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Practice: ${skill['name']}")),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _SkillCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.elevatedCardDecoration.copyWith(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Tap to practice',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
