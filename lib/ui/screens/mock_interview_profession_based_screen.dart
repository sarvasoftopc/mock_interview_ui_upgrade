import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../widgets/app_drawer.dart';

class MockInterviewScreen extends StatelessWidget {
  const MockInterviewScreen({super.key});

  final List<Map<String, dynamic>> roles = const [
    {
      "title": "Frontend Engineer",
      "icon": Icons.web_asset,
      "color": Color(0xFF667EEA),
    },
    {
      "title": "Backend Engineer",
      "icon": Icons.dns,
      "color": Color(0xFF764BA2),
    },
    {
      "title": "Fullstack Engineer",
      "icon": Icons.layers,
      "color": Color(0xFFF5576C),
    },
    {
      "title": "Data Scientist",
      "icon": Icons.bar_chart,
      "color": Color(0xFF4FACFE),
    },
    {
      "title": "Product Manager",
      "icon": Icons.lightbulb,
      "color": Color(0xFF43E97B),
    },
    {"title": "HR Interview", "icon": Icons.people, "color": Color(0xFFF093FB)},
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final isTablet =
        MediaQuery.of(context).size.width > 600 &&
        MediaQuery.of(context).size.width <= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mock Interview"),
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
              maxWidth: isWide ? 1000 : double.infinity,
            ),
            child: GridView.builder(
              padding: EdgeInsets.all(isWide ? 32 : 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 3 : (isTablet ? 2 : 1),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isWide ? 1.1 : (isTablet ? 1.2 : 1.8),
              ),
              itemCount: roles.length,
              itemBuilder: (context, index) {
                final role = roles[index];
                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Starting mock for ${role['title']}"),
                        backgroundColor: AppTheme.primaryPurple,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          role['color'] as Color,
                          (role['color'] as Color).withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: AppTheme.shadowSm,
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            role['icon'] as IconData,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          role['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Simulate a full role-based interview",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
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
