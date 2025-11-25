import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../widgets/app_drawer.dart';

class StarStoryScreen extends StatelessWidget {
  const StarStoryScreen({super.key});

  final List<Map<String, dynamic>> starCategories = const [
    {
      "title": "Leadership",
      "desc": "Stories about leading teams/projects",
      "icon": Icons.leaderboard,
      "color": Color(0xFF667EEA),
    },
    {
      "title": "Conflict Resolution",
      "desc": "Handling tough situations",
      "icon": Icons.handshake,
      "color": Color(0xFFF5576C),
    },
    {
      "title": "Problem Solving",
      "desc": "Overcoming technical/strategic challenges",
      "icon": Icons.build,
      "color": Color(0xFF4FACFE),
    },
    {
      "title": "Achievements",
      "desc": "Highlighting impact and results",
      "icon": Icons.star,
      "color": Color(0xFF43E97B),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final isTablet =
        MediaQuery.of(context).size.width > 600 &&
        MediaQuery.of(context).size.width <= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text("STAR Story Bank"),
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
                crossAxisCount: isWide ? 2 : (isTablet ? 2 : 1),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isWide ? 2.5 : (isTablet ? 2.0 : 2.5),
              ),
              itemCount: starCategories.length,
              itemBuilder: (context, index) {
                final cat = starCategories[index];
                return GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${cat['title']} - Coming soon!'),
                        backgroundColor: AppTheme.primaryPurple,
                      ),
                    );
                  },
                  child: Container(
                    decoration: AppTheme.elevatedCard.copyWith(
                      border: Border.all(
                        color: (cat['color'] as Color).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (cat['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMd,
                            ),
                          ),
                          child: Icon(
                            cat['icon'] as IconData,
                            color: cat['color'] as Color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                cat['title'] as String,
                                style: AppTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cat['desc'] as String,
                                style: AppTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: AppTheme.textLight,
                          size: 16,
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
