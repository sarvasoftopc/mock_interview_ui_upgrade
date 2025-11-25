import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../config/app_theme.dart';
import '../../generated/l10n.dart';
import '../../models/mock_interview_session.dart';
import '../../providers/cv_jd_provider.dart';
import '../../providers/interview_provider.dart';
import '../../widgets/modern_components.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_app_bar.dart';
import 'summary_bottom_sheet.dart';

/// Capabily Skill Dashboard - Modern Data Visualization
class SkillDashboardScreen extends StatefulWidget {
  const SkillDashboardScreen({super.key});

  @override
  State<SkillDashboardScreen> createState() => _SkillDashboardScreenState();
}

class _SkillDashboardScreenState extends State<SkillDashboardScreen>
    with SingleTickerProviderStateMixin {
  bool _initialized = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final cvJdProvider = context.read<CvJdProvider>();
      cvJdProvider.ensureAnalysisLoaded();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _startMockInterview(BuildContext context) async {
    final provider = context.read<InterviewProvider>();
    final cvJdProvider = context.read<CvJdProvider>();

    if (cvJdProvider.sessionId.isNotEmpty &&
        cvJdProvider.questions.isNotEmpty) {
      provider.loadQuestions(cvJdProvider.questions);
      provider.startSession(cvJdProvider.sessionId, SessionType.normal);
    } else {
      await cvJdProvider.extractSkillsAndFetchQuestions();
      provider.loadQuestions(cvJdProvider.questions);
      provider.startSession(cvJdProvider.sessionId, SessionType.normal);
    }
    Navigator.of(context).pushNamed('/question');
  }

  @override
  Widget build(BuildContext context) {
    final cvJdProvider = context.watch<CvJdProvider>();
    final overlapSkills = cvJdProvider.overlapSkills;
    final missingSkills = cvJdProvider.missingSkills;
    final extraSkills = cvJdProvider.additonalSkills;
    final summary = cvJdProvider.summary ?? "No analysis available yet.";
    final matchScore = double.tryParse(cvJdProvider.matchScore ?? "0") ?? 0.0;

    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1200;
    final isTablet = size.width > 768 && size.width <= 1200;

    // Check if analysis exists
    final hasAnalysis =
        overlapSkills.isNotEmpty ||
        missingSkills.isNotEmpty ||
        extraSkills.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: CustomAppBar(context: context, titleText: 'Skill Dashboard'),
      drawer: const AppDrawer(),
      body: hasAnalysis
          ? SingleChildScrollView(
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
                      // Header Section
                      _buildHeaderSection(context, matchScore, isWide),
                      const SizedBox(height: AppTheme.space8),

                      // Quick Stats
                      _buildQuickStats(
                        context,
                        overlapSkills,
                        missingSkills,
                        extraSkills,
                        isWide,
                        isTablet,
                      ),
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
                                  _buildMatchVisualization(
                                    context,
                                    matchScore,
                                    overlapSkills.length,
                                    missingSkills.length,
                                  ),
                                  const SizedBox(height: AppTheme.space6),
                                  _buildSkillsBreakdown(
                                    context,
                                    overlapSkills,
                                    missingSkills,
                                    extraSkills,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppTheme.space6),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildActionPanel(context, cvJdProvider),
                                  const SizedBox(height: AppTheme.space6),
                                  _buildSummaryCard(context, summary),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildMatchVisualization(
                              context,
                              matchScore,
                              overlapSkills.length,
                              missingSkills.length,
                            ),
                            const SizedBox(height: AppTheme.space6),
                            _buildActionPanel(context, cvJdProvider),
                            const SizedBox(height: AppTheme.space6),
                            _buildSkillsBreakdown(
                              context,
                              overlapSkills,
                              missingSkills,
                              extraSkills,
                            ),
                            const SizedBox(height: AppTheme.space6),
                            _buildSummaryCard(context, summary),
                          ],
                        ),

                      const SizedBox(height: AppTheme.space10),
                    ],
                  ),
                ),
              ),
            )
          : EmptyState(
              icon: Icons.analytics,
              title: 'No Analysis Yet',
              description:
                  'Upload your CV and job description to see your skill match analysis',
              actionText: 'Go to Home',
              onAction: () => Navigator.pop(context),
            ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    double matchScore,
    bool isWide,
  ) {
    return Container(
      padding: EdgeInsets.all(isWide ? AppTheme.space8 : AppTheme.space6),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppTheme.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skill Match Analysis',
                      style: isWide
                          ? AppTheme.headlineLarge.copyWith(color: Colors.white)
                          : AppTheme.headlineSmall.copyWith(
                              color: Colors.white,
                            ),
                    ),
                    const SizedBox(height: AppTheme.space1),
                    Text(
                      'CV vs Job Description Comparison',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    BuildContext context,
    List overlapSkills,
    List missingSkills,
    List extraSkills,
    bool isWide,
    bool isTablet,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isWide ? 4 : (isTablet ? 2 : 1),
      mainAxisSpacing: AppTheme.space4,
      crossAxisSpacing: AppTheme.space4,
      childAspectRatio: isWide ? 1.5 : (isTablet ? 1.8 : 2.5),
      children: [
        StatsCard(
          label: 'Matched Skills',
          value: '${overlapSkills.length}',
          icon: Icons.check_circle,
          color: AppTheme.success,
        ),
        StatsCard(
          label: 'Skills to Learn',
          value: '${missingSkills.length}',
          icon: Icons.school,
          color: AppTheme.warning,
        ),
        StatsCard(
          label: 'Extra Skills',
          value: '${extraSkills.length}',
          icon: Icons.star,
          color: AppTheme.info,
        ),
        StatsCard(
          label: 'Total Skills',
          value:
              '${overlapSkills.length + missingSkills.length + extraSkills.length}',
          icon: Icons.inventory,
          color: AppTheme.primaryPurple,
        ),
      ],
    );
  }

  Widget _buildMatchVisualization(
    BuildContext context,
    double matchScore,
    int matched,
    int missing,
  ) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Match Score',
            subtitle: 'Your skill alignment with the job',
          ),
          const SizedBox(height: AppTheme.space6),

          // Circular Progress
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: matchScore / 100,
                      strokeWidth: 16,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(matchScore),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${matchScore.toInt()}%',
                        style: AppTheme.displayMedium.copyWith(
                          color: _getScoreColor(matchScore),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getScoreLabel(matchScore),
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.space6),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _LegendItem(
                color: AppTheme.success,
                label: 'Matched',
                value: matched.toString(),
              ),
              _LegendItem(
                color: AppTheme.warning,
                label: 'Missing',
                value: missing.toString(),
              ),
              _LegendItem(
                color: _getScoreColor(matchScore),
                label: 'Score',
                value: '${matchScore.toInt()}%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsBreakdown(
    BuildContext context,
    List overlapSkills,
    List missingSkills,
    List extraSkills,
  ) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Skills Breakdown',
            subtitle: 'Detailed skill comparison',
          ),
          const SizedBox(height: AppTheme.space4),

          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryPurple,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryPurple,
            tabs: [
              Tab(text: 'Matched (${overlapSkills.length})'),
              Tab(text: 'Missing (${missingSkills.length})'),
              Tab(text: 'Extra (${extraSkills.length})'),
            ],
          ),

          const SizedBox(height: AppTheme.space4),

          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSkillList(
                  overlapSkills,
                  AppTheme.success,
                  Icons.check_circle,
                ),
                _buildSkillList(missingSkills, AppTheme.warning, Icons.school),
                _buildSkillList(extraSkills, AppTheme.info, Icons.star),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillList(List skills, Color color, IconData icon) {
    if (skills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textLight),
            const SizedBox(height: AppTheme.space4),
            Text('No skills in this category', style: AppTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.space2),
      itemCount: skills.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppTheme.space3),
      itemBuilder: (context, index) {
        final skill = skills[index].toString();
        return Container(
          padding: const EdgeInsets.all(AppTheme.space4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(child: Text(skill, style: AppTheme.titleSmall)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionPanel(BuildContext context, CvJdProvider provider) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: AppTheme.space4),

          ModernButton(
            text: 'Start Practice Interview',
            icon: Icons.play_arrow,
            isFullWidth: true,
            onPressed: () => _startMockInterview(context),
          ),

          const SizedBox(height: AppTheme.space3),

          ModernButton(
            text: 'View Detailed Summary',
            icon: Icons.description,
            isPrimary: false,
            isFullWidth: true,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) =>
                    SummaryBottomSheet(summary: provider.summary ?? ''),
              );
            },
          ),

          const SizedBox(height: AppTheme.space3),

          ModernButton(
            text: 'New Analysis',
            icon: Icons.refresh,
            isPrimary: false,
            isFullWidth: true,
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          ),

          const SizedBox(height: AppTheme.space6),
          const Divider(),
          const SizedBox(height: AppTheme.space4),

          _ActionTile(
            icon: Icons.trending_up,
            title: 'Improve Skills',
            subtitle: 'Get learning resources',
            onTap: () => Navigator.pushNamed(context, '/preparationHub'),
          ),
          const SizedBox(height: AppTheme.space3),
          _ActionTile(
            icon: Icons.history,
            title: 'View History',
            subtitle: 'Past analyses',
            onTap: () => Navigator.pushNamed(context, '/sessions'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String summary) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: AppTheme.info,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              const Expanded(
                child: Text('AI Insights', style: AppTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space4),
          Container(
            padding: const EdgeInsets.all(AppTheme.space4),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Text(
              summary.length > 300
                  ? '${summary.substring(0, 300)}...'
                  : summary,
              style: AppTheme.bodyMedium.copyWith(height: 1.6),
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          TextButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => SummaryBottomSheet(summary: summary),
              );
            },
            icon: const Icon(Icons.read_more),
            label: const Text('Read Full Summary'),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppTheme.success;
    if (score >= 60) return AppTheme.info;
    if (score >= 40) return AppTheme.warning;
    return AppTheme.error;
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return 'Excellent Match';
    if (score >= 60) return 'Good Match';
    if (score >= 40) return 'Fair Match';
    return 'Needs Improvement';
  }
}

// Supporting Widgets
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: AppTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.titleSmall.copyWith(color: color)),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.space3),
        decoration: BoxDecoration(
          color: AppTheme.backgroundGray,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryPurple, size: 24),
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
