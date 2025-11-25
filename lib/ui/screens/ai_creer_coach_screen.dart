import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../widgets/app_drawer.dart';

class CareerCoachScreen extends StatelessWidget {
  const CareerCoachScreen({super.key});

  final List<Map<String, dynamic>> coachOptions = const [
    {
      "title": "Resume Review",
      "desc": "AI reviews your resume and gives feedback",
      "icon": Icons.description,
      "gradient": [Color(0xFF667EEA), Color(0xFF764BA2)],
    },
    {
      "title": "Skill Gap Analysis",
      "desc": "AI compares your skills to target roles",
      "icon": Icons.analytics,
      "gradient": [Color(0xFFF093FB), Color(0xFFF5576C)],
    },
    {
      "title": "Career Path Guidance",
      "desc": "AI suggests next steps for growth",
      "icon": Icons.trending_up,
      "gradient": [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    },
    {
      "title": "Interview Readiness",
      "desc": "AI highlights your weak areas",
      "icon": Icons.check_circle,
      "gradient": [Color(0xFF43E97B), Color(0xFF38F9D7)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Career Coach"),
        centerTitle: true,
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWide ? 900 : double.infinity,
            ),
            child: ListView.builder(
              padding: EdgeInsets.all(isWide ? 32 : 16),
              itemCount: coachOptions.length,
              itemBuilder: (context, index) {
                final option = coachOptions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${option['title']} - Coming soon!'),
                          backgroundColor: AppTheme.primaryPurple,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: option['gradient'] as List<Color>,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        boxShadow: AppTheme.cardDecoration.boxShadow,
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMd,
                              ),
                            ),
                            child: Icon(
                              option['icon'] as IconData,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option['title'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  option['desc'] as String,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
