import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/cv_jd_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/modern_components.dart';
import '../../utils/file_util.dart';
import '../../services/cv_jd_service.dart';
import '../widgets/app_drawer.dart';

/// Capabily Home Screen - Complete Modern Redesign
/// Professional SaaS dashboard with proper visual hierarchy
class HomeScreenRedesigned extends StatefulWidget {
  const HomeScreenRedesigned({super.key});

  @override
  State<HomeScreenRedesigned> createState() => _HomeScreenRedesignedState();
}

class _HomeScreenRedesignedState extends State<HomeScreenRedesigned> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cvJdProvider = context.watch<CvJdProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1200;
    final isTablet = size.width > 768 && size.width <= 1200;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      drawer: const AppDrawer(),
      appBar: _buildAppBar(context, profileProvider),
      body: LoadingOverlay(
        isLoading: cvJdProvider.loading,
        message: 'Analyzing your documents...',
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? AppTheme.space12 : (isTablet ? AppTheme.space8 : AppTheme.space4),
            vertical: AppTheme.space6,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 1400 : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
                  _buildHeroSection(context, isWide, isTablet),
                  const SizedBox(height: AppTheme.space8),

                  // Quick Stats
                  _buildQuickStats(context, isWide, isTablet),
                  const SizedBox(height: AppTheme.space8),

                  // Main Content Grid
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildInterviewModesSection(context, cvJdProvider),
                              const SizedBox(height: AppTheme.space6),
                              _buildCVJDAnalysisSection(context, cvJdProvider),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppTheme.space6),
                        Expanded(
                          child: _buildQuickActionsPanel(context),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildInterviewModesSection(context, cvJdProvider),
                        const SizedBox(height: AppTheme.space6),
                        _buildCVJDAnalysisSection(context, cvJdProvider),
                        const SizedBox(height: AppTheme.space6),
                        _buildQuickActionsPanel(context),
                      ],
                    ),

                  const SizedBox(height: AppTheme.space8),

                  // Features Grid
                  _buildFeaturesGrid(context, isWide, isTablet),

                  const SizedBox(height: AppTheme.space8),

                  // Testimonials or Social Proof
                  _buildSocialProof(context, isWide),

                  const SizedBox(height: AppTheme.space10),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: !isWide ? _buildBottomNav(context) : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/practice'),
        icon: const Icon(Icons.rocket_launch),
        label: const Text('Start Practice'),
        backgroundColor: AppTheme.primaryPurple,
        elevation: 4,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ProfileProvider profileProvider) {
    final profile = profileProvider.profile;
    
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Text(
              'Capabily',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/profile'),
          child: CircleAvatar(
            backgroundColor: AppTheme.primaryPurple,
            child: Text(
              profile?.fullName?.isNotEmpty == true
                  ? profile!.fullName![0].toUpperCase()
                  : 'U',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isWide, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isWide ? AppTheme.space10 : AppTheme.space6),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowLg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Master Your Interview Skills',
                  style: isWide
                      ? AppTheme.displayMedium.copyWith(color: Colors.white)
                      : AppTheme.headlineLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: AppTheme.space4),
                Text(
                  'AI-powered mock interviews, real-time feedback, and personalized coaching to help you land your dream job.',
                  style: AppTheme.bodyLarge.copyWith(color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: AppTheme.space6),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ModernButton(
                      text: 'Start Interview',
                      icon: Icons.play_arrow,
                      onPressed: () => Navigator.pushNamed(context, '/practice'),
                    ),
                    ModernButton(
                      text: 'View Progress',
                      icon: Icons.analytics,
                      isPrimary: false,
                      onPressed: () => Navigator.pushNamed(context, '/insights'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isWide) ...[
            const SizedBox(width: AppTheme.space8),
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              child: Center(
                child: Icon(
                  Icons.psychology_alt,
                  size: 120,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, bool isWide, bool isTablet) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isWide ? 4 : (isTablet ? 2 : 1),
      mainAxisSpacing: AppTheme.space4,
      crossAxisSpacing: AppTheme.space4,
      childAspectRatio: isWide ? 1.5 : (isTablet ? 1.8 : 2.5),
      children: const [
        StatsCard(
          label: 'Interviews Completed',
          value: '24',
          icon: Icons.check_circle,
          color: AppTheme.success,
          trend: '+12%',
        ),
        StatsCard(
          label: 'Average Score',
          value: '85%',
          icon: Icons.trending_up,
          color: AppTheme.info,
          trend: '+5%',
        ),
        StatsCard(
          label: 'Skills Improved',
          value: '12',
          icon: Icons.stars,
          color: AppTheme.warning,
          trend: '+3',
        ),
        StatsCard(
          label: 'Practice Hours',
          value: '42h',
          icon: Icons.timer,
          color: AppTheme.primaryPurple,
          trend: '+8h',
        ),
      ],
    );
  }

  Widget _buildInterviewModesSection(BuildContext context, CvJdProvider cvJdProvider) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Interview Modes',
            subtitle: 'Choose how you want to practice',
          ),
          const SizedBox(height: AppTheme.space4),
          _InterviewModeCard(
            icon: Icons.psychology_alt,
            title: 'AI Adaptive Interview',
            description: 'Dynamic questions that adapt to your responses',
            gradient: AppTheme.primaryGradient,
            onTap: () => Navigator.pushNamed(context, '/mockInterviewAdaptive'),
          ),
          const SizedBox(height: AppTheme.space3),
          _InterviewModeCard(
            icon: Icons.work_outline,
            title: 'Role-Based Practice',
            description: 'Prepare for specific job roles and positions',
            gradient: const LinearGradient(
              colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
            ),
            onTap: () => Navigator.pushNamed(context, '/mockInterviewRole'),
          ),
          const SizedBox(height: AppTheme.space3),
          _InterviewModeCard(
            icon: Icons.code,
            title: 'Skill-Based Focus',
            description: 'Target specific technical or soft skills',
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF34D399)],
            ),
            onTap: () => Navigator.pushNamed(context, '/mockInterviewSkill'),
          ),
        ],
      ),
    );
  }

  Widget _buildCVJDAnalysisSection(BuildContext context, CvJdProvider cvJdProvider) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'CV & Job Description Analysis',
            subtitle: 'Get AI-powered insights and matching questions',
          ),
          const SizedBox(height: AppTheme.space4),
          Row(
            children: [
              Expanded(
                child: _UploadButton(
                  icon: Icons.description,
                  label: cvJdProvider.cvText.isEmpty ? 'Upload CV' : 'CV Uploaded',
                  isUploaded: cvJdProvider.cvText.isNotEmpty,
                  onTap: () => FileUtil.selectFile(context, true, cvJdProvider),
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: _UploadButton(
                  icon: Icons.work,
                  label: cvJdProvider.jdText.isEmpty ? 'Upload JD' : 'JD Uploaded',
                  isUploaded: cvJdProvider.jdText.isNotEmpty,
                  onTap: () => FileUtil.selectFile(context, false, cvJdProvider),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space4),
          ModernButton(
            text: cvJdProvider.loading ? 'Analyzing...' : 'Analyze Match',
            icon: Icons.analytics,
            isFullWidth: true,
            isLoading: cvJdProvider.loading,
            onPressed: (cvJdProvider.cvText.isNotEmpty &&
                    cvJdProvider.jdText.isNotEmpty &&
                    !cvJdProvider.loading)
                ? () => CvJDAnalysis().performSkillAnalysis(context, cvJdProvider)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsPanel(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: AppTheme.space4),
          _QuickActionItem(
            icon: Icons.history,
            title: 'View Sessions',
            subtitle: 'See your interview history',
            onTap: () => Navigator.pushNamed(context, '/sessions'),
          ),
          const Divider(height: AppTheme.space4),
          _QuickActionItem(
            icon: Icons.insights,
            title: 'Performance Insights',
            subtitle: 'Track your progress',
            onTap: () => Navigator.pushNamed(context, '/insights'),
          ),
          const Divider(height: AppTheme.space4),
          _QuickActionItem(
            icon: Icons.school,
            title: 'Preparation Hub',
            subtitle: 'Resources and tutorials',
            onTap: () => Navigator.pushNamed(context, '/preparationHub'),
          ),
          const Divider(height: AppTheme.space4),
          _QuickActionItem(
            icon: Icons.book,
            title: 'STAR Stories',
            subtitle: 'Manage behavioral answers',
            onTap: () => Navigator.pushNamed(context, '/starStories'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context, bool isWide, bool isTablet) {
    final features = [
      _FeatureData('Mock Interviews', 'Practice with AI interviewers', Icons.mic, '/mockInterview'),
      _FeatureData('Career Coach', 'Get personalized guidance', Icons.psychology, '/careerCoach'),
      _FeatureData('Panel Mode', 'Multi-interviewer practice', Icons.group, '/panelInterview'),
      _FeatureData('Skill Dashboard', 'Track your abilities', Icons.dashboard, '/skills'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Explore Features',
          subtitle: 'Comprehensive tools for interview success',
        ),
        const SizedBox(height: AppTheme.space4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 4 : (isTablet ? 2 : 1),
            mainAxisSpacing: AppTheme.space4,
            crossAxisSpacing: AppTheme.space4,
            childAspectRatio: 1.2,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return _FeatureCard(
              icon: feature.icon,
              title: feature.title,
              description: feature.description,
              onTap: () => Navigator.pushNamed(context, feature.route),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSocialProof(BuildContext context, bool isWide) {
    return ModernCard(
      child: Column(
        children: [
          const SectionHeader(
            title: 'Trusted by Professionals',
            subtitle: '10,000+ interviews completed successfully',
          ),
          const SizedBox(height: AppTheme.space6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _StatColumn(value: '95%', label: 'Success Rate'),
              _StatColumn(value: '4.9/5', label: 'User Rating'),
              _StatColumn(value: '50+', label: 'Companies'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppTheme.shadowMd,
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() => _selectedNavIndex = index);
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/sessions');
              break;
            case 2:
              Navigator.pushNamed(context, '/insights');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryPurple,
        unselectedItemColor: AppTheme.textLight,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Sessions'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Insights'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Supporting Widgets
class _InterviewModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _InterviewModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space4),
        decoration: BoxDecoration(
          gradient: gradient.scale(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: AppTheme.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.titleMedium),
                  const SizedBox(height: AppTheme.space1),
                  Text(description, style: AppTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }
}

class _UploadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isUploaded;
  final VoidCallback onTap;

  const _UploadButton({
    required this.icon,
    required this.label,
    required this.isUploaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space4),
        decoration: BoxDecoration(
          color: isUploaded ? AppTheme.success.withOpacity(0.1) : AppTheme.backgroundGray,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isUploaded ? AppTheme.success : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isUploaded ? Icons.check_circle : icon,
              color: isUploaded ? AppTheme.success : AppTheme.textSecondary,
              size: 32,
            ),
            const SizedBox(height: AppTheme.space2),
            Text(
              label,
              style: AppTheme.labelMedium.copyWith(
                color: isUploaded ? AppTheme.success : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, color: AppTheme.primaryPurple, size: 24),
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.titleSmall),
                Text(subtitle, style: AppTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textLight),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: AppTheme.space3),
          Text(title, style: AppTheme.titleSmall, textAlign: TextAlign.center),
          const SizedBox(height: AppTheme.space1),
          Text(
            description,
            style: AppTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTheme.displaySmall.copyWith(color: AppTheme.primaryPurple)),
        const SizedBox(height: AppTheme.space1),
        Text(label, style: AppTheme.bodyMedium),
      ],
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

extension on LinearGradient {
  LinearGradient scale(double opacity) {
    return LinearGradient(
      colors: colors.map((c) => c.withOpacity(opacity)).toList(),
      begin: begin,
      end: end,
    );
  }
}
