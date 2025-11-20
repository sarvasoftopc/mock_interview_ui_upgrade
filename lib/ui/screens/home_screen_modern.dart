import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarvasoft_moc_interview/services/cv_jd_service.dart';
import 'package:sarvasoft_moc_interview/ui/widgets/custom_app_bar.dart';

import '../../config/app_theme.dart';
import '../../providers/cv_jd_provider.dart';
import '../../utils/file_util.dart';
import '../../widgets/modern_widgets.dart';
import '../widgets/app_drawer.dart';

/// Modern Home Screen with upgraded UI
/// Preserves all existing functionality while improving visual design
class HomeScreenModern extends StatefulWidget {
  const HomeScreenModern({super.key});

  @override
  State<HomeScreenModern> createState() => _HomeScreenModernState();
}

class _HomeScreenModernState extends State<HomeScreenModern> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _analysisCardKey = GlobalKey();
  int _selectedIndex = 0;

  CvJdProvider provider(BuildContext context) => context.read<CvJdProvider>();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToAnalysis() async {
    if (_analysisCardKey.currentContext != null) {
      await Scrollable.ensureVisible(
        _analysisCardKey.currentContext!,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    } else {
      _scrollController.animateTo(300,
          duration: const Duration(milliseconds: 420), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cvJdProvider = context.watch<CvJdProvider>();

    return Scaffold(
      appBar: CustomAppBar(context: context, titleText: "AI Interview Prep"),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;
            final isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 900;

            return Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: isWide ? 48 : 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildModernHeroSection(context, cvJdProvider, isWide),
                      const SizedBox(height: 28),
                      _buildInterviewPreviewSection(context, isWide),
                      const SizedBox(height: 28),
                      _buildInterviewModeSection(context, isWide),
                      const SizedBox(height: 20),
                      Container(
                          key: _analysisCardKey,
                          child: _buildAnalysisAndQuickActions(context, cvJdProvider, isWide)),
                      const SizedBox(height: 26),
                      const Text("Explore Features",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildFeatureGrid(context, cvJdProvider, isWide, isTablet),
                      const SizedBox(height: 26),
                      _buildWhySection(context, isWide),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                if (cvJdProvider.loading)
                  Container(
                    color: Colors.black.withOpacity(0.25),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: GradientButton(
        text: 'Get Started',
        onPressed: () => Navigator.pushNamed(context, '/practice'),
        icon: Icons.rocket_launch,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Modern Hero Section with gradient background
  Widget _buildModernHeroSection(BuildContext context, CvJdProvider cvJdProvider, bool isWide) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        gradient: AppTheme.primaryGradient,
        boxShadow: AppTheme.cardDecoration.boxShadow,
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(child: _heroTextColumn(context, cvJdProvider)),
                const SizedBox(width: 24),
                Expanded(child: _heroIllustration(context)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroTextColumn(context, cvJdProvider),
                const SizedBox(height: 18),
                _heroIllustration(context),
              ],
            ),
    );
  }

  Widget _heroTextColumn(BuildContext context, CvJdProvider cvJdProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Master Your Interview Skills with AI',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 12),
        const Text(
          'AI-powered mock interviews with voice interaction, adaptive difficulty, and real-time behavioral analysis. Get job-ready with personalized coaching.',
          style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.6),
        ),
        const SizedBox(height: 24),
        Wrap(spacing: 12, runSpacing: 12, children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/practice'),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Mock Interview'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                elevation: 0,
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _scrollToAnalysis,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Upload CV / JD'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            ),
          ),
        ]),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _compactStat('Avg. score ↑', '18%'),
            _compactStat('Practice attempts', '1.2K'),
            _compactStat('Satisfied users', '4.8/5'),
          ],
        )
      ],
    );
  }

  Widget _compactStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _heroIllustration(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          color: Colors.white.withOpacity(0.1),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Center(
          child: Icon(Icons.computer, size: 84, color: Colors.white.withOpacity(0.9)),
        ),
      ),
    );
  }

  /// Interview Preview Section - NEW
  Widget _buildInterviewPreviewSection(BuildContext context, bool isWide) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ready to Practice?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your interview style and start practicing with AI visual agents',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          isWide
              ? Row(
                  children: [
                    Expanded(
                        child:
                            _previewCard('🎯', 'Adaptive Mode', 'AI adjusts difficulty as you progress')),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _previewCard('👥', 'Panel Mode', 'Face multiple AI interviewers')),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _previewCard('🎤', 'Voice Interaction', 'Answer with your voice naturally')),
                  ],
                )
              : Column(
                  children: [
                    _previewCard('🎯', 'Adaptive Mode', 'AI adjusts difficulty as you progress'),
                    const SizedBox(height: 12),
                    _previewCard('👥', 'Panel Mode', 'Face multiple AI interviewers'),
                    const SizedBox(height: 12),
                    _previewCard('🎤', 'Voice Interaction', 'Answer with your voice naturally'),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _previewCard(String icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewModeSection(BuildContext context, bool isWide) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose Your Interview Mode',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          isWide
              ? Row(
                  children: [
                    Expanded(
                        child: _modeCard(context, 'Skill-Based', Icons.build_circle,
                            'Focus on specific skills.', '/mockInterviewSkill')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _modeCard(context, 'Role-Based', Icons.work_outline,
                            'Practice for a job role.', '/mockInterviewRole')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _modeCard(context, 'AI Adaptive', Icons.psychology_alt,
                            'Dynamic interviews.', '/mockInterviewAdaptive')),
                  ],
                )
              : Column(
                  children: [
                    _modeCard(context, 'Skill-Based', Icons.build_circle,
                        'Focus on specific skills.', '/mockInterviewSkill'),
                    const SizedBox(height: 12),
                    _modeCard(context, 'Role-Based', Icons.work_outline,
                        'Practice for a job role.', '/mockInterviewRole'),
                    const SizedBox(height: 12),
                    _modeCard(context, 'AI Adaptive', Icons.psychology_alt,
                        'Dynamic interviews.', '/mockInterviewAdaptive'),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _modeCard(
      BuildContext context, String title, IconData icon, String desc, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(icon, color: AppTheme.primaryPurple)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisAndQuickActions(
      BuildContext context, CvJdProvider cvJdProvider, bool isWide) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _cvJdAnalysisCard(context, cvJdProvider)),
        if (isWide) const SizedBox(width: 20),
        if (isWide)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _quickActionCard(
                  title: 'One-click Practice',
                  icon: Icons.flash_on,
                  subtitle: 'Start a short mock interview based on your CV skills',
                  onTap: () => Navigator.pushNamed(context, '/mockInterview'),
                ),
                const SizedBox(height: 12),
                _quickActionCard(
                  title: 'STAR Stories',
                  icon: Icons.book,
                  subtitle: 'Save and reuse your behavioral examples',
                  onTap: () => Navigator.pushNamed(context, '/starStories'),
                ),
                const SizedBox(height: 12),
                _quickActionCard(
                  title: 'Career Coach',
                  icon: Icons.psychology,
                  subtitle: 'Personalized tips and next steps',
                  onTap: () => Navigator.pushNamed(context, '/careerCoach'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _quickActionCard(
      {required String title,
      required IconData icon,
      required String subtitle,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.cardDecoration,
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor: AppTheme.primaryLight,
                child: Icon(icon, color: AppTheme.primaryPurple)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ])),
            const Icon(Icons.chevron_right, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(
      BuildContext context, CvJdProvider cvJdProvider, bool isWide, bool isTablet) {
    final features = [
      _FeatureData('Practice & Improve', 'Sharpen skills using CV, JD, or select from skill list.',
          Icons.school, '/practice'),
      _FeatureData('Mock Interview', 'Simulated interview with AI-generated questions.',
          Icons.mic, '/mockInterview'),
      _FeatureData('Stress Simulator', 'Timed interviews to simulate real pressure.', Icons.timer,
          '/stressSimulator'),
      _FeatureData('Panel Interview', 'Face a panel of AI interviewers.', Icons.group,
          '/panelInterview'),
      _FeatureData('AI Career Coach', 'Get personalized career guidance.', Icons.psychology,
          '/careerCoach'),
      _FeatureData('STAR Story Bank', 'Prepare STAR-format stories.', Icons.book, '/starStories'),
    ];

    int crossAxis = isWide ? 3 : (isTablet ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxis,
        mainAxisExtent: 160,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final f = features[index];
        return _featureCardModern(
          context,
          title: f.title,
          description: f.description,
          icon: f.icon,
          route: f.route,
          disabled: cvJdProvider.loading,
        );
      },
    );
  }

  Widget _buildWhySection(BuildContext context, bool isWide) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Why choose us?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 12),
        const Text(
            'AI-powered simulations, tailored feedback, safe practice environment, and measurable progress.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.6)),
        const SizedBox(height: 16),
        Wrap(children: [
          _benefitTile(Icons.speed, 'Fast setup'),
          const SizedBox(width: 12),
          _benefitTile(Icons.shield, 'Privacy-first'),
          const SizedBox(width: 12),
          _benefitTile(Icons.track_changes, 'Actionable insights'),
        ])
      ]),
    );
  }

  Widget _benefitTile(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: AppTheme.primaryPurple, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    );
  }

  BottomNavigationBar _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: AppTheme.primaryPurple,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.pushNamed(context, '/skills');
            break;
          case 2:
            Navigator.pushNamed(context, '/preparationHub');
            break;
          case 3:
            Navigator.pushNamed(context, '/history');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Skills"),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: "Preparation"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
      ],
    );
  }

  Widget _cvJdAnalysisCard(BuildContext context, CvJdProvider cvJdProvider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        gradient: AppTheme.primaryGradient,
        boxShadow: AppTheme.shadowSm,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.analytics_outlined, size: 36, color: Colors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('CV + JD Analysis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ]),
        const SizedBox(height: 10),
        const Text('Upload your CV & JD together and run skill match analysis.',
            style: TextStyle(fontSize: 14, color: Colors.white70)),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: cvJdProvider.loading
                  ? null
                  : () => FileUtil.selectFile(context, true, provider(context)),
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(cvJdProvider.cvText.isNotEmpty ? 'CV Uploaded' : 'Upload CV'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: cvJdProvider.loading
                  ? null
                  : () => FileUtil.selectFile(context, false, provider(context)),
              icon: const Icon(Icons.work_outline),
              label: Text(cvJdProvider.jdText.isNotEmpty ? 'JD Uploaded' : 'Upload JD'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryPurple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            text: cvJdProvider.loading ? 'Analyzing…' : 'Perform Analysis',
            onPressed: (cvJdProvider.cvText.isNotEmpty &&
                    cvJdProvider.jdText.isNotEmpty &&
                    !cvJdProvider.loading)
                ? () => CvJDAnalysis().performSkillAnalysis(context, provider(context))
                : () {},
            isLoading: cvJdProvider.loading,
            icon: Icons.play_circle_fill,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ]),
    );
  }

  Widget _featureCardModern(BuildContext context,
      {required String title,
      required String description,
      required IconData icon,
      required String route,
      bool disabled = false}) {
    return GestureDetector(
      onTap: disabled
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analysis in progress. Please wait.')));
            }
          : () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          gradient: disabled
              ? LinearGradient(
                  colors: [Colors.grey.shade300, Colors.grey.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)
              : AppTheme.primaryGradient,
          boxShadow: AppTheme.shadowSm,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 36, color: Colors.white),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text(description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ]),
      ),
    );
  }
}

class _FeatureData {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  _FeatureData(this.title, this.description, this.icon, this.route);
}
