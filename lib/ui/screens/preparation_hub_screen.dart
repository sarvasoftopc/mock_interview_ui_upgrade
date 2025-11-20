import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

class PreparationHubScreen extends StatelessWidget {
  const PreparationHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).preparationHub),
        backgroundColor: Colors.indigo,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildHubCard(
            context,
            icon: Icons.picture_as_pdf,
            title: AppLocalizations.of(context).resumeBuilder,
            description: AppLocalizations.of(context).resumeBuilderDesc,
            color: Colors.blue,
            onTap: () {
              Navigator.pushNamed(context, '/resumeBuilder');
            },
          ),
          _buildHubCard(
            context,
            icon: Icons.psychology,
            title: AppLocalizations.of(context).careerCoach,
            description: AppLocalizations.of(context).careerCoachDesc,
            color: Colors.orange,
            onTap: () {
              Navigator.pushNamed(context, '/careerCoach');
            },
          ),
          _buildHubCard(
            context,
            icon: Icons.school,
            title: AppLocalizations.of(context).skillTutorials,
            description: AppLocalizations.of(context).skillTutorialsDesc,
            color: Colors.green,
            onTap: () {
              Navigator.pushNamed(context, '/skillTutorials');
            },
          ),
          _buildHubCard(
            context,
            icon: Icons.question_answer,
            title: AppLocalizations.of(context).questionBank,
            description: AppLocalizations.of(context).questionBankDesc,
            color: Colors.purple,
            onTap: () {
              Navigator.pushNamed(context, '/questionBank');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHubCard(BuildContext context,
      {required IconData icon,
        required String title,
        required String description,
        required Color color,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
