import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarvasoft_moc_interview/services/cv_jd_service.dart';
import 'package:sarvasoft_moc_interview/ui/widgets/custom_app_bar.dart';

import '../../providers/cv_jd_provider.dart';
import '../../utils/file_util.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      _scrollController.animateTo(300, duration: const Duration(milliseconds: 420), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cvJdProvider = context.watch<CvJdProvider>();

    return Scaffold(
      appBar: CustomAppBar(context: context, titleText: "AI Interview Prep"),
      drawer: const AppDrawer(),
      body: SafeArea(
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
                    _buildHeroSection(context, cvJdProvider, isWide),
                    const SizedBox(height: 28),
                    _buildInterviewModeSection(context, isWide),
                    const SizedBox(height: 20),
                    Container(key: _analysisCardKey, child: _buildAnalysisAndQuickActions(context, cvJdProvider, isWide)),
                    const SizedBox(height: 26),
                    const Text("Explore Features", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildFeatureGrid(context, cvJdProvider, isWide, isTablet),
                    const SizedBox(height: 26),
                    _buildWhySection(context, isWide),
                    const SizedBox(height: 26),
                    _buildFooter(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              if (cvJdProvider.loading)
                Container(
                  color: Colors.black.withOpacity(0.25),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.indigo,
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/practice'),
        label: const Text('Get Started'),
        icon: const Icon(Icons.rocket_launch),
        backgroundColor: Colors.indigo.shade600,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeroSection(BuildContext context, CvJdProvider cvJdProvider, bool isWide) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [Colors.indigo.shade800, Colors.indigo.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6)),
        ],
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
          'Prepare smarter. Interview better.',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Text(
          'AI-driven mock interviews, CV↔JD analysis, personalized coaching — all in one place.\nDesigned for candidates and teams.',
          style: TextStyle(fontSize: 14.5, color: Colors.white70),
        ),
        const SizedBox(height: 18),
        Wrap(spacing: 12, runSpacing: 12, children: [
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/practice'),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Try a Mock Interview'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          OutlinedButton.icon(
            onPressed: _scrollToAnalysis,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Upload CV / JD'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.18)),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ]),
        const SizedBox(height: 14),
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.06),
        ),
        child: Center(
          child: Icon(Icons.computer, size: 84, color: Colors.white.withOpacity(0.9)),
        ),
      ),
    );
  }

  Widget _buildInterviewModeSection(BuildContext context, bool isWide) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose Your Interview Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          isWide
              ? Row(
            children: [
              Expanded(child: _modeCard(context, 'Skill-Based', Icons.build_circle, 'Focus on specific skills.', '/mockInterviewSkill')),
              const SizedBox(width: 12),
              Expanded(child: _modeCard(context, 'Role-Based', Icons.work_outline, 'Practice for a specific job role.', '/mockInterviewRole')),
              const SizedBox(width: 12),
              Expanded(child: _modeCard(context, 'AI Adaptive (Smart)', Icons.psychology_alt, 'Dynamic real-time interviews.', '/mockInterviewAdaptive')),
            ],
          )
              : Column(
            children: [
              _modeCard(context, 'Skill-Based', Icons.build_circle, 'Focus on specific skills.', '/mockInterviewSkill'),
              const SizedBox(height: 12),
              _modeCard(context, 'Role-Based', Icons.work_outline, 'Practice for a specific job role.', '/mockInterviewRole'),
              const SizedBox(height: 12),
              _modeCard(context, 'AI Adaptive (Smart)', Icons.psychology_alt, 'Dynamic real-time interviews.', '/mockInterviewAdaptive'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeCard(BuildContext context, String title, IconData icon, String desc, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.indigo.shade100),
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: Colors.indigo.shade100, child: Icon(icon, color: Colors.indigo)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ]),
            ),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisAndQuickActions(BuildContext context, CvJdProvider cvJdProvider, bool isWide) {
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

  Widget _quickActionCard({required String title, required IconData icon, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: Colors.indigo.shade50, child: Icon(icon, color: Colors.indigo)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54))])),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, CvJdProvider cvJdProvider, bool isWide, bool isTablet) {
    final features = [
      _FeatureData('Practice & Improve', 'Sharpen skills using CV, JD, or select from skill list for targeted practice.', Icons.school, '/practice'),
      _FeatureData('Mock Interview', 'Simulated interview with AI-generated questions and analysis.', Icons.mic, '/mockInterview'),
      _FeatureData('Stress Simulator', 'Timed interviews to simulate real pressure environments.', Icons.timer, '/stressSimulator'),
      _FeatureData('Panel Interview', 'Face a panel of AI interviewers for realistic practice.', Icons.group, '/panelInterview'),
      _FeatureData('AI Career Coach', 'Get personalized career guidance, tips, and improvement areas.', Icons.psychology, '/careerCoach'),
      _FeatureData('STAR Story Bank', 'Prepare STAR-format stories for behavioral interviews.', Icons.book, '/starStories'),
    ];

    int crossAxis = isWide ? 3 : (isTablet ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxis,
        mainAxisExtent: 150,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final f = features[index];
        return _featureCardResponsive(
          context,
          title: f.title,
          description: f.description,
          icon: f.icon,
          route: f.route,
          isWide: true,
          disabled: cvJdProvider.loading,
        );
      },
    );
  }

  Widget _buildWhySection(BuildContext context, bool isWide) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Why choose us?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('AI-powered simulations, tailored feedback, safe practice environment, and measurable progress.'),
        const SizedBox(height: 12),
        Row(children: [
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
    return Expanded(
      child: Row(children: [
        CircleAvatar(backgroundColor: Colors.indigo.shade50, child: Icon(icon, color: Colors.indigo)),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: Wrap(alignment: WrapAlignment.center, spacing: 12, children: [
        TextButton(onPressed: () => Navigator.pushNamed(context, '/settings'), child: const Text('Settings')),
        TextButton(onPressed: () => Navigator.pushNamed(context, '/reports'), child: const Text('Reports')),
        TextButton(onPressed: () => Navigator.pushNamed(context, '/resumeBuilder'), child: const Text('Resume Builder')),
      ]),
    );
  }

  BottomNavigationBar _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.indigo,
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
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Skills Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: "Preparation Hub"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
      ],
    );
  }

  Widget _cvJdAnalysisCard(BuildContext context, CvJdProvider cvJdProvider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [Colors.indigo.shade500, Colors.indigo.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.analytics_outlined, size: 36, color: Colors.white),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('CV + JD Analysis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ]),
        const SizedBox(height: 8),
        const Text('Upload your CV & JD together and run skill match analysis with tailored questions.', style: TextStyle(fontSize: 13, color: Colors.white70)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: cvJdProvider.loading ? null : () => FileUtil.selectFile(context, true, provider(context)),
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(cvJdProvider.cvText.isNotEmpty ? 'CV Uploaded' : 'Upload CV'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo.shade900,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: cvJdProvider.loading ? null : () => FileUtil.selectFile(context, false, provider(context)),
              icon: const Icon(Icons.work_outline),
              label: Text(cvJdProvider.jdText.isNotEmpty ? 'JD Uploaded' : 'Upload JD'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo.shade900,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: (cvJdProvider.cvText.isNotEmpty && cvJdProvider.jdText.isNotEmpty && !cvJdProvider.loading)
                ? () => CvJDAnalysis().performSkillAnalysis(context, provider(context))
                : null,
            icon: cvJdProvider.loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.play_circle_fill),
            label: Text(cvJdProvider.loading ? 'Analyzing…' : 'Perform Analysis'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _featureCardResponsive(BuildContext context,
      {required String title, required String description, required IconData icon, required String route, required bool isWide, bool disabled = false}) {
    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: disabled
            ? () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analysis in progress. Please wait or view results in Skills Dashboard.')));
        }
            : () => Navigator.pushNamed(context, route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(colors: disabled ? [Colors.grey.shade300, Colors.grey.shade200] : [Colors.pink.shade400, Colors.pink.shade200], begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 6))],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 34, color: Colors.white),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 6),
            Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ]),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: () {
      Navigator.of(context).pop();
      onTap();
    });
  }
}

class _FeatureData {
  final String title;
  final String description;
  final IconData icon;
  final String route;

  _FeatureData(this.title, this.description, this.icon, this.route);
}


