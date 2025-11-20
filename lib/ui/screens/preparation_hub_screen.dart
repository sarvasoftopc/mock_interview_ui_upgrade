import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../generated/l10n.dart';
import '../../widgets/modern_widgets.dart';
import '../widgets/app_drawer.dart';

class PreparationHubScreen extends StatelessWidget {
  const PreparationHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final isTablet = MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width <= 900;
    
    int crossAxisCount = isWide ? 3 : (isTablet ? 2 : 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).preparationHub),
        centerTitle: true,
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 32 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Prepare for Success',
                  style: AppTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Explore our comprehensive tools and resources',
                  style: AppTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildHubCard(
                    context,
                    icon: Icons.picture_as_pdf,
                    title: AppLocalizations.of(context).resumeBuilder,
                    description: AppLocalizations.of(context).resumeBuilderDesc,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/resumeBuilder');
                    },
                  ),
                  _buildHubCard(
                    context,
                    icon: Icons.psychology,
                    title: AppLocalizations.of(context).careerCoach,
                    description: AppLocalizations.of(context).careerCoachDesc,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/careerCoach');
                    },
                  ),
                  _buildHubCard(
                    context,
                    icon: Icons.school,
                    title: AppLocalizations.of(context).skillTutorials,
                    description: AppLocalizations.of(context).skillTutorialsDesc,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/skillTutorials');
                    },
                  ),
                  _buildHubCard(
                    context,
                    icon: Icons.question_answer,
                    title: AppLocalizations.of(context).questionBank,
                    description: AppLocalizations.of(context).questionBankDesc,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/questionBank');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHubCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.shadowMd,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
