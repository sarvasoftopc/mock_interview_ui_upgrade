import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/session_provider.dart';
import '../../widgets/modern_components.dart';
import '../widgets/app_drawer.dart';
import '../widgets/custom_app_bar.dart';

/// Capabily User Insights - Performance Analytics Dashboard
class UserInsights extends StatefulWidget {
  const UserInsights({Key? key}) : super(key: key);

  @override
  State<UserInsights> createState() => _UserInsightsState();
}

class _UserInsightsState extends State<UserInsights> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedPeriod = '7d';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final provider = context.read<SessionProvider>();
      provider.fetchSessions();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<SessionProvider>();
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1200;
    final isTablet = size.width > 768 && size.width <= 1200;

    // Calculate insights
    final sessions = sessionProvider.sessions;
    final completedSessions = sessions.where((s) => s.completed).toList();
    final avgScore = completedSessions.isEmpty
        ? 0.0
        : completedSessions.map((s) => s.score ?? 0).reduce((a, b) => a + b) / completedSessions.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: CustomAppBar(
        context: context,
        titleText: 'Performance Insights'
      ),
      drawer: const AppDrawer(),
      body: sessionProvider.loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple))
          : sessions.isEmpty
              ? EmptyState(
                  icon: Icons.insights,
                  title: 'No Data Yet',
                  description: 'Complete some interviews to see your performance insights',
                  actionText: 'Start Practice',
                  onAction: () => Navigator.pushNamed(context, '/practice'),
                )
              : SingleChildScrollView(
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
                          // Header
                          _buildHeader(context, isWide),
                          const SizedBox(height: AppTheme.space6),

                          // Period Selector
                          _buildPeriodSelector(),
                          const SizedBox(height: AppTheme.space8),

                          // Key Metrics
                          _buildKeyMetrics(context, sessions, completedSessions, avgScore, isWide, isTablet),
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
                                      _buildPerformanceTrend(context, completedSessions),
                                      const SizedBox(height: AppTheme.space6),
                                      _buildSkillsBreakdown(context, completedSessions),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppTheme.space6),
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildActivityCalendar(context, sessions),
                                      const SizedBox(height: AppTheme.space6),
                                      _buildRecommendations(context),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                _buildPerformanceTrend(context, completedSessions),
                                const SizedBox(height: AppTheme.space6),
                                _buildActivityCalendar(context, sessions),
                                const SizedBox(height: AppTheme.space6),
                                _buildSkillsBreakdown(context, completedSessions),
                                const SizedBox(height: AppTheme.space6),
                                _buildRecommendations(context),
                              ],
                            ),

                          const SizedBox(height: AppTheme.space8),

                          // Recent Sessions
                          _buildRecentSessions(context, sessions),

                          const SizedBox(height: AppTheme.space10),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isWide) {
    return FadeTransition(
      opacity: _animationController,
      child: Container(
        padding: EdgeInsets.all(isWide ? AppTheme.space8 : AppTheme.space6),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: AppTheme.shadowLg,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: const Icon(Icons.insights, color: Colors.white, size: 32),
            ),
            const SizedBox(width: AppTheme.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Progress Dashboard',
                    style: (isWide ? AppTheme.headlineLarge : AppTheme.headlineSmall)
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppTheme.space1),
                  Text(
                    'Track your interview performance and growth',
                    style: AppTheme.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PeriodButton(
            label: '7 Days',
            value: '7d',
            isSelected: _selectedPeriod == '7d',
            onTap: () => setState(() => _selectedPeriod = '7d'),
          ),
          _PeriodButton(
            label: '30 Days',
            value: '30d',
            isSelected: _selectedPeriod == '30d',
            onTap: () => setState(() => _selectedPeriod = '30d'),
          ),
          _PeriodButton(
            label: 'All Time',
            value: 'all',
            isSelected: _selectedPeriod == 'all',
            onTap: () => setState(() => _selectedPeriod = 'all'),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(BuildContext context, List sessions, List completedSessions,
      double avgScore, bool isWide, bool isTablet) {
    final totalHours = (sessions.length * 0.5).toStringAsFixed(1);
    final improvementRate = completedSessions.length > 1 ? '+12%' : 'N/A';

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      )),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: isWide ? 4 : (isTablet ? 2 : 1),
        mainAxisSpacing: AppTheme.space4,
        crossAxisSpacing: AppTheme.space4,
        childAspectRatio: isWide ? 1.5 : (isTablet ? 1.8 : 2.5),
        children: [
          StatsCard(
            label: 'Total Sessions',
            value: '${sessions.length}',
            icon: Icons.calendar_today,
            color: AppTheme.primaryPurple,
            trend: '+${sessions.length}',
            isPositiveTrend: true,
          ),
          StatsCard(
            label: 'Average Score',
            value: avgScore.toStringAsFixed(1),
            icon: Icons.star,
            color: AppTheme.success,
            trend: improvementRate,
            isPositiveTrend: true,
          ),
          StatsCard(
            label: 'Completion Rate',
            value: sessions.isEmpty ? '0%' : '${((completedSessions.length / sessions.length) * 100).toInt()}%',
            icon: Icons.check_circle,
            color: AppTheme.info,
            trend: improvementRate,
            isPositiveTrend: true,
          ),
          StatsCard(
            label: 'Practice Hours',
            value: '${totalHours}h',
            icon: Icons.timer,
            color: AppTheme.warning,
            trend: '+${totalHours}h',
            isPositiveTrend: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTrend(BuildContext context, List completedSessions) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Performance Trend',
            subtitle: 'Your score progress over time',
          ),
          const SizedBox(height: AppTheme.space6),
          
          // Simple Bar Chart Visualization
          if (completedSessions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.space8),
                child: Text('No completed sessions yet', style: AppTheme.bodyMedium),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  completedSessions.length > 10 ? 10 : completedSessions.length,
                  (index) {
                    final session = completedSessions[
                        completedSessions.length > 10 ? completedSessions.length - 10 + index : index
                    ];
                    final score = session.score ?? 0;
                    return _BarChartItem(
                      height: (score / 10) * 200,
                      score: score,
                      label: '${index + 1}',
                    );
                  },
                ),
              ),
            ),
          
          const SizedBox(height: AppTheme.space4),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _LegendDot(color: AppTheme.success, label: 'Excellent (8-10)'),
              SizedBox(width: AppTheme.space4),
              _LegendDot(color: AppTheme.warning, label: 'Good (5-7)'),
              SizedBox(width: AppTheme.space4),
              _LegendDot(color: AppTheme.error, label: 'Needs Work (<5)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCalendar(BuildContext context, List sessions) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Activity Calendar',
            subtitle: 'Your practice consistency',
          ),
          const SizedBox(height: AppTheme.space6),
          
          // Simple activity grid (7x4 = 28 days)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 28,
            itemBuilder: (context, index) {
              final hasActivity = index % 3 == 0; // Mock data
              return Container(
                decoration: BoxDecoration(
                  color: hasActivity
                      ? AppTheme.success.withOpacity(0.7)
                      : AppTheme.backgroundGray,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              );
            },
          ),
          
          const SizedBox(height: AppTheme.space4),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Less', style: AppTheme.bodySmall),
              Row(
                children: [
                  _ActivityLegend(color: AppTheme.backgroundGray),
                  _ActivityLegend(color: AppTheme.success.withOpacity(0.3)),
                  _ActivityLegend(color: AppTheme.success.withOpacity(0.6)),
                  _ActivityLegend(color: AppTheme.success),
                ],
              ),
              Text('More', style: AppTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsBreakdown(BuildContext context, List completedSessions) {
    // Mock skill data
    final skills = [
      {'name': 'Technical', 'progress': 0.85, 'color': AppTheme.info},
      {'name': 'Communication', 'progress': 0.72, 'color': AppTheme.success},
      {'name': 'Problem Solving', 'progress': 0.90, 'color': AppTheme.primaryPurple},
      {'name': 'Leadership', 'progress': 0.65, 'color': AppTheme.warning},
    ];

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Skills Performance',
            subtitle: 'Your strength areas',
          ),
          const SizedBox(height: AppTheme.space6),
          
          ...skills.map((skill) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(skill['name'] as String, style: AppTheme.titleSmall),
                    Text(
                      '${((skill['progress'] as double) * 100).toInt()}%',
                      style: AppTheme.titleSmall.copyWith(color: skill['color'] as Color),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space2),
                ModernProgressBar(
                  progress: skill['progress'] as double,
                  color: skill['color'] as Color,
                  height: 8,
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Icon(Icons.tips_and_updates, color: AppTheme.warning, size: 24),
              ),
              const SizedBox(width: AppTheme.space3),
              const Expanded(
                child: Text('Recommendations', style: AppTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space4),
          
          _RecommendationItem(
            icon: Icons.schedule,
            title: 'Practice Consistency',
            description: 'Try to practice 3x per week for best results',
            color: AppTheme.info,
          ),
          const SizedBox(height: AppTheme.space3),
          _RecommendationItem(
            icon: Icons.trending_up,
            title: 'Focus on Weak Areas',
            description: 'Spend more time on leadership questions',
            color: AppTheme.warning,
          ),
          const SizedBox(height: AppTheme.space3),
          _RecommendationItem(
            icon: Icons.star,
            title: 'Great Progress!',
            description: 'Your scores have improved by 12% this month',
            color: AppTheme.success,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions(BuildContext context, List sessions) {
    final recentSessions = sessions.take(5).toList();

    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Recent Sessions',
            subtitle: 'Your latest ${recentSessions.length} interviews',
            action: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/sessions'),
              child: const Text('View All'),
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          
          ...recentSessions.map((session) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.space3),
            child: InkWell(
              onTap: () {
                final provider = context.read<SessionProvider>();
                provider.openSession(context, session.id, session.sessionType);
              },
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.space4),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundGray,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: session.completed
                            ? AppTheme.successGradient
                            : AppTheme.warningGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        session.completed ? Icons.check : Icons.pending,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppTheme.space3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session.sessionType, style: AppTheme.titleSmall),
                          Text(
                            _formatDate(session.createdAt),
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (session.completed && session.score != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getScoreColor(session.score!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Text(
                          session.score!.toStringAsFixed(1),
                          style: AppTheme.titleSmall.copyWith(
                            color: _getScoreColor(session.score!),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8) return AppTheme.success;
    if (score >= 5) return AppTheme.warning;
    return AppTheme.error;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Supporting Widgets
class _PeriodButton extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Text(
          label,
          style: AppTheme.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _BarChartItem extends StatelessWidget {
  final double height;
  final double score;
  final String label;

  const _BarChartItem({
    required this.height,
    required this.score,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final color = score >= 8 ? AppTheme.success : (score >= 5 ? AppTheme.warning : AppTheme.error);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: height.clamp(20.0, 200.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.bodySmall),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTheme.bodySmall),
      ],
    );
  }
}

class _ActivityLegend extends StatelessWidget {
  final Color color;

  const _ActivityLegend({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _RecommendationItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.titleSmall),
                Text(description, style: AppTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
