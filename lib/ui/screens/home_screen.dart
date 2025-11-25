import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/cv_jd_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/modern_components.dart';
import '../../utils/file_util.dart';
import '../../services/cv_jd_service.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_app_bar.dart';

/// Capabily Home Screen - Modern SaaS Dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedNavIndex = 0;
  String _analysisMode = 'jd'; // 'jd' or 'role'
  String? _selectedRole;

  final List<String> _roles = [
    'Frontend Developer',
    'Backend Developer',
    'Fullstack Developer',
    'Data Scientist',
    'Product Manager',
    'QA Engineer',
    'DevOps Engineer',
    'Mobile Developer',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CvJdProvider>(context, listen: false).getRoles();
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
      appBar: CustomAppBar(context: context, titleText: 'Capabily'),
      body: LoadingOverlay(
        isLoading: cvJdProvider.loading,
        message: 'Analyzing your documents...',
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide
                ? AppTheme.space12
                : (isTablet ? AppTheme.space8 : AppTheme.space4),
            vertical: AppTheme.space6,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 1400 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section
                  _buildHeroSection(context, profileProvider, isWide, isTablet),
                  const SizedBox(height: AppTheme.space8),

                  // Quick Stats
                  _buildQuickStats(context, isWide, isTablet),
                  const SizedBox(height: AppTheme.space8),

                  // Main Content
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildInterviewModes(context),
                              const SizedBox(height: AppTheme.space6),
                              _buildCVJDAnalysis(context, cvJdProvider),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppTheme.space6),
                        Expanded(child: _buildQuickActions(context)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildInterviewModes(context),
                        const SizedBox(height: AppTheme.space6),
                        _buildCVJDAnalysis(context, cvJdProvider),
                        const SizedBox(height: AppTheme.space6),
                        _buildQuickActions(context),
                      ],
                    ),

                  const SizedBox(height: AppTheme.space8),

                  // Features Grid
                  _buildFeaturesSection(context, isWide, isTablet),

                  const SizedBox(height: AppTheme.space10),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: !isWide ? _buildBottomNav() : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/practice'),
        icon: const Icon(Icons.rocket_launch),
        label: const Text('Start Practice'),
        backgroundColor: AppTheme.primaryPurple,
        elevation: 4,
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    ProfileProvider profileProvider,
    bool isWide,
    bool isTablet,
  ) {
    final profile = profileProvider.profile;
    final userName = profile?.fullName ?? 'there';
    final greeting = _getGreeting();

    return FadeTransition(
      opacity: _animationController,
      child: Container(
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
                    '$greeting, $userName! 👋',
                    style:
                        (isWide
                                ? AppTheme.displayMedium
                                : AppTheme.headlineLarge)
                            .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppTheme.space3),
                  Text(
                    'Ready to ace your next interview? Let\'s practice and improve together.',
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ModernButton(
                        text: 'Start Interview',
                        icon: Icons.play_arrow,
                        onPressed: () =>
                            Navigator.pushNamed(context, '/practice'),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMd,
                          ),
                        ),
                        child: TextButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/insights'),
                          icon: const Icon(
                            Icons.analytics,
                            color: AppTheme.primaryPurple,
                          ),
                          label: const Text(
                            'View Insights',
                            style: TextStyle(
                              color: AppTheme.primaryPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isWide) ...[
              const SizedBox(width: AppTheme.space8),
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.psychology_alt,
                    size: 120,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, bool isWide, bool isTablet) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
            ),
          ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: isWide ? 4 : (isTablet ? 2 : 1),
        mainAxisSpacing: AppTheme.space4,
        crossAxisSpacing: AppTheme.space4,
        childAspectRatio: isWide ? 1.5 : (isTablet ? 1.8 : 2.5),
        children: const [
          StatsCard(
            label: 'Total Sessions',
            value: '24',
            icon: Icons.calendar_today,
            color: AppTheme.primaryPurple,
            trend: '+12%',
          ),
          StatsCard(
            label: 'Avg Score',
            value: '8.5/10',
            icon: Icons.trending_up,
            color: AppTheme.success,
            trend: '+0.5',
          ),
          StatsCard(
            label: 'Skills Mastered',
            value: '18',
            icon: Icons.stars,
            color: AppTheme.warning,
            trend: '+6',
          ),
          StatsCard(
            label: 'Hours Practiced',
            value: '42h',
            icon: Icons.timer,
            color: AppTheme.info,
            trend: '+8h',
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewModes(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Choose Your Interview Mode',
            subtitle: 'Select how you want to practice',
          ),
          const SizedBox(height: AppTheme.space4),
          _InterviewModeCard(
            icon: Icons.psychology_alt,
            title: 'AI Adaptive',
            subtitle: 'Smart questions that adapt to you',
            gradient: AppTheme.primaryGradient,
            onTap: () => Navigator.pushNamed(context, '/mockInterviewAdaptive'),
          ),
          const SizedBox(height: AppTheme.space3),
          _InterviewModeCard(
            icon: Icons.work_outline,
            title: 'Role-Based',
            subtitle: 'Practice for specific positions',
            gradient: const LinearGradient(
              colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
            ),
            onTap: () => Navigator.pushNamed(context, '/mockInterviewRole'),
          ),
          const SizedBox(height: AppTheme.space3),
          _InterviewModeCard(
            icon: Icons.code,
            title: 'Skill-Focused',
            subtitle: 'Target specific competencies',
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF34D399)],
            ),
            onTap: () => Navigator.pushNamed(context, '/mockInterviewSkill'),
          ),
        ],
      ),
    );
  }

  Widget _buildCVJDAnalysis(BuildContext context, CvJdProvider provider) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Smart Analysis',
            subtitle: 'Compare your CV against job requirements or roles',
          ),
          const SizedBox(height: AppTheme.space4),

          // Mode Selector
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ModeButton(
                    label: 'CV vs JD',
                    icon: Icons.description,
                    isSelected: _analysisMode == 'jd',
                    onTap: () => setState(() => _analysisMode = 'jd'),
                  ),
                ),
                Expanded(
                  child: _ModeButton(
                    label: 'CV vs Role',
                    icon: Icons.work,
                    isSelected: _analysisMode == 'role',
                    onTap: () => setState(() => _analysisMode = 'role'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.space4),

          // Info Box
          Container(
            padding: const EdgeInsets.all(AppTheme.space4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryPurple.withOpacity(0.1),
                  AppTheme.primaryPurple.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: AppTheme.primaryPurple.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: AppTheme.primaryPurple, size: 24),
                const SizedBox(width: AppTheme.space3),
                Expanded(
                  child: Text(
                    _analysisMode == 'jd'
                        ? 'Upload your CV and job description to get personalized questions'
                        : 'Upload your CV and select a role to see how you match',
                    style: AppTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.space4),

          // CV Upload (always shown)
          _UploadCard(
            icon: Icons.description,
            label: provider.cvText.isEmpty ? 'Upload CV' : 'CV Uploaded',
            isUploaded: provider.cvText.isNotEmpty,
            onTap: () => FileUtil.selectFile(context, true, provider),
          ),

          const SizedBox(height: AppTheme.space3),

          // JD Upload or Role Selector
          if (_analysisMode == 'jd')
            _UploadCard(
              icon: Icons.work,
              label: provider.jdText.isEmpty ? 'Upload JD' : 'JD Uploaded',
              isUploaded: provider.jdText.isNotEmpty,
              onTap: () => FileUtil.selectFile(context, false, provider),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppTheme.space4),
              decoration: BoxDecoration(
                color: _selectedRole != null
                    ? AppTheme.success.withOpacity(0.1)
                    : AppTheme.backgroundGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: _selectedRole != null
                      ? AppTheme.success
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedRole,
                hint: Row(
                  children: [
                    Icon(
                      Icons.work_outline,
                      color: AppTheme.textSecondary,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text('Select Target Role'),
                  ],
                ),
                items: provider.roles
                    .map(
                      (role) => DropdownMenuItem<String>(
                        value: role.roleId.toString(),
                        child: Text(role.roleName),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedRole = v),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

          const SizedBox(height: AppTheme.space4),

          // Analyze Button
          ModernButton(
            text: provider.loading ? 'Analyzing...' : 'Analyze Match',
            icon: Icons.analytics,
            isFullWidth: true,
            isLoading: provider.loading,
            onPressed:
                (_analysisMode == 'jd'
                    ? (provider.cvText.isNotEmpty &&
                          provider.jdText.isNotEmpty &&
                          !provider.loading)
                    : (provider.cvText.isNotEmpty &&
                          _selectedRole != null &&
                          !provider.loading))
                ? () {
                    if (_analysisMode == 'jd') {
                      CvJDAnalysis().performSkillAnalysis(context, provider);
                    } else {
                      // TODO: Implement CV vs Role analysis
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Analyzing CV against $_selectedRole role...',
                          ),
                          backgroundColor: AppTheme.info,
                        ),
                      );
                    }
                  }
                : null,
          ),

          if (provider.matchScore != null) ...[
            const SizedBox(height: AppTheme.space4),
            Container(
              padding: const EdgeInsets.all(AppTheme.space4),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppTheme.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Match Score: ${provider.matchScore}%',
                          style: AppTheme.titleSmall,
                        ),
                        Text(
                          'View detailed analysis',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/skills'),
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: AppTheme.space4),
          _QuickActionTile(
            icon: Icons.history,
            title: 'Session History',
            subtitle: 'View past interviews',
            onTap: () => Navigator.pushNamed(context, '/sessions'),
          ),
          const Divider(height: AppTheme.space4),
          _QuickActionTile(
            icon: Icons.insights,
            title: 'Performance Insights',
            subtitle: 'Track your progress',
            onTap: () => Navigator.pushNamed(context, '/insights'),
          ),
          const Divider(height: AppTheme.space4),
          _QuickActionTile(
            icon: Icons.school,
            title: 'Preparation Hub',
            subtitle: 'Learning resources',
            onTap: () => Navigator.pushNamed(context, '/preparationHub'),
          ),
          const Divider(height: AppTheme.space4),
          _QuickActionTile(
            icon: Icons.book,
            title: 'STAR Stories',
            subtitle: 'Behavioral examples',
            onTap: () => Navigator.pushNamed(context, '/starStories'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(
    BuildContext context,
    bool isWide,
    bool isTablet,
  ) {
    final features = [
      {
        'title': 'Panel Interview',
        'desc': 'Multi-interviewer mode',
        'icon': Icons.group,
        'route': '/panelInterview',
      },
      {
        'title': 'Career Coach',
        'desc': 'AI guidance',
        'icon': Icons.psychology,
        'route': '/careerCoach',
      },
      {
        'title': 'Skill Dashboard',
        'desc': 'Track abilities',
        'icon': Icons.dashboard,
        'route': '/skills',
      },
      {
        'title': 'Settings',
        'desc': 'Customize experience',
        'icon': Icons.settings,
        'route': '/settings',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'More Features',
          subtitle: 'Comprehensive interview preparation tools',
        ),
        const SizedBox(height: AppTheme.space4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 4 : (isTablet ? 2 : 2),
            mainAxisSpacing: AppTheme.space4,
            crossAxisSpacing: AppTheme.space4,
            childAspectRatio: 1.1,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return _FeatureCard(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              description: feature['desc'] as String,
              onTap: () =>
                  Navigator.pushNamed(context, feature['route'] as String),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
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
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Insights',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// Supporting Widgets
class _InterviewModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _InterviewModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
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
          gradient: LinearGradient(
            colors: gradient.colors.map((c) => c.withOpacity(0.1)).toList(),
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: gradient.colors.first.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: AppTheme.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.titleMedium),
                  Text(subtitle, style: AppTheme.bodySmall),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isUploaded;
  final VoidCallback onTap;

  const _UploadCard({
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
          color: isUploaded
              ? AppTheme.success.withOpacity(0.1)
              : AppTheme.backgroundGray,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isUploaded ? AppTheme.success : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isUploaded ? Icons.check_circle : icon,
              color: isUploaded ? AppTheme.success : AppTheme.textSecondary,
              size: 32,
            ),
            const SizedBox(width: AppTheme.space3),
            Expanded(
              child: Text(
                label,
                style: AppTheme.labelLarge.copyWith(
                  color: isUploaded ? AppTheme.success : AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.space2),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Icon(icon, color: AppTheme.primaryPurple, size: 20),
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
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppTheme.textLight,
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(AppTheme.space4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: AppTheme.space3),
          Text(title, style: AppTheme.titleSmall, textAlign: TextAlign.center),
          const SizedBox(height: AppTheme.space1),
          Text(
            description,
            style: AppTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
