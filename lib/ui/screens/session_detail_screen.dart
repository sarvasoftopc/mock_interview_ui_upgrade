import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/modern_components.dart';
import '../../models/candidate_session.dart';
import '../../models/session_analysis.dart';
import '../../providers/session_provider.dart';

class SessionDetailScreen extends StatefulWidget {
  final String sessionId;
  final String sessionType;
  const SessionDetailScreen({
    super.key,
    required this.sessionId,
    required this.sessionType,
  });

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  bool _loading = true;
  SessionAnalysis? _analysis;
  String? _error;
  bool loadingCoaching = false;
  var coaching;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureAnalysisLoaded();
  }

  Future<void> _ensureAnalysisLoaded() async {
    if (_analysis != null || !_loading && _error == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final provider = context.read<SessionProvider>();
    final cached = provider.getAnalysisFor(widget.sessionId);
    if (cached != null) {
      setState(() {
        _analysis = cached;
        _loading = false;
      });
      return;
    }

    try {
      final fetched = await provider.fetchSessionDetails(
        widget.sessionId,
        widget.sessionType,
      );
      if (fetched == null) {
        setState(() {
          _error = 'No analysis available for this session.';
          _loading = false;
        });
      } else {
        setState(() {
          _analysis = fetched;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load session analysis.';
        _loading = false;
      });
    }
  }

  Future getSessionCoaching(String sessionId, String sessionType) async {
    final provider = context.read<SessionProvider>();
    return await provider.getSessionCoaching(sessionId, sessionType);
  }

  Widget _metricCard(String label, int value) {
    final color = value >= 75
        ? AppTheme.success
        : (value >= 50 ? AppTheme.warning : AppTheme.error);
    return Container(
      padding: const EdgeInsets.all(AppTheme.space3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: AppTheme.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.space1),
          Text(label, style: AppTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SessionProvider>();
    final session = provider.getSessionById(widget.sessionId);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1200;
    final isTablet = size.width > 768 && size.width <= 1200;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Session Analysis'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                _loading = true;
                _error = null;
              });
              await _ensureAnalysisLoaded();
            },
            tooltip: 'Refresh analysis',
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPurple),
            )
          : (_error != null)
          ? EmptyState(
              icon: Icons.error_outline,
              title: 'Error Loading Analysis',
              description: _error!,
              actionText: 'Retry',
              onAction: () async {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                await _ensureAnalysisLoaded();
              },
            )
          : (_analysis == null)
          ? const EmptyState(
              icon: Icons.analytics_outlined,
              title: 'No Analysis Available',
              description: 'Analysis for this session is not available',
            )
          : _buildBody(context, session, _analysis!, isWide, isTablet),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CandidateSession? session,
    SessionAnalysis analysis,
    bool isWide,
    bool isTablet,
  ) {
    return SingleChildScrollView(
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
              // Top Summary Card
              ModernCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Score Circle
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.shadowMd,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${analysis.overall_score}',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Score',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.space6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Overall Readiness',
                            style: AppTheme.titleLarge,
                          ),
                          const SizedBox(height: AppTheme.space2),
                          Text(analysis.summary, style: AppTheme.bodyLarge),
                          const SizedBox(height: AppTheme.space2),
                          if (session != null)
                            Text(
                              'Session date: ${_formatDate(session.createdAt)}',
                              style: AppTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.space6),

              // Metrics Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isWide ? 6 : (isTablet ? 3 : 2),
                mainAxisSpacing: AppTheme.space3,
                crossAxisSpacing: AppTheme.space3,
                childAspectRatio: 1.2,
                children: [
                  _metricCard('Relevance', analysis.overall_relevance),
                  _metricCard('Complete', analysis.overall_completeness),
                  _metricCard('Accuracy', analysis.overall_accuracy),
                  _metricCard('Fluency', analysis.overall_fluency),
                  _metricCard('Confidence', analysis.overall_confidence),
                  _metricCard('Tone', analysis.candidateToneAnalysis),
                ],
              ),
              const SizedBox(height: AppTheme.space6),

              // Strengths / Weaknesses / Recommendations
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildStrengthsCard(analysis)),
                    const SizedBox(width: AppTheme.space4),
                    Expanded(child: _buildWeaknessesCard(analysis)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildStrengthsCard(analysis),
                    const SizedBox(height: AppTheme.space4),
                    _buildWeaknessesCard(analysis),
                  ],
                ),
              const SizedBox(height: AppTheme.space4),
              _buildRecommendationsCard(analysis),
              const SizedBox(height: AppTheme.space6),

              // AI Coaching Button
              ModernButton(
                text: loadingCoaching
                    ? 'Generating...'
                    : 'Generate AI Coaching',
                icon: Icons.psychology,
                isFullWidth: true,
                isLoading: loadingCoaching,
                onPressed: loadingCoaching
                    ? null
                    : () async {
                        setState(() => loadingCoaching = true);
                        final data = await getSessionCoaching(
                          widget.sessionId,
                          widget.sessionType,
                        );
                        setState(() {
                          coaching = data;
                          loadingCoaching = false;
                        });
                      },
              ),

              if (coaching != null) ...[
                const SizedBox(height: AppTheme.space4),
                _buildCoachingCard(coaching),
              ],

              const SizedBox(height: AppTheme.space6),

              // Skills & Progress
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildSkillsCard(analysis)),
                    const SizedBox(width: AppTheme.space4),
                    Expanded(child: _buildProgressCard(analysis)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildSkillsCard(analysis),
                    const SizedBox(height: AppTheme.space4),
                    _buildProgressCard(analysis),
                  ],
                ),
              const SizedBox(height: AppTheme.space6),

              // Job Fit
              _buildJobFitCard(analysis),
              const SizedBox(height: AppTheme.space6),

              // Per-Answer Breakdown
              const SectionHeader(
                title: 'Answer Breakdown',
                subtitle: 'Detailed analysis for each question',
              ),
              const SizedBox(height: AppTheme.space4),
              ...analysis.per_answer_analysis.asMap().entries.map((entry) {
                final idx = entry.key;
                final a = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.space3),
                  child: ModernCard(
                    child: ExpansionTile(
                      key: ValueKey('answer_$idx'),
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(
                        top: AppTheme.space4,
                      ),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSm,
                              ),
                            ),
                            child: Text(
                              'Q${idx + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.space3),
                          Text(
                            'Score: ${a.score}',
                            style: AppTheme.titleSmall.copyWith(
                              color: _getScoreColor(a.score.toDouble()),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: AppTheme.space2),
                        child: Text(
                          a.feedback,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.bodySmall,
                        ),
                      ),
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ModernBadge(
                              label: 'Relevance: ${a.relevance}',
                              color: AppTheme.info,
                            ),
                            ModernBadge(
                              label: 'Complete: ${a.completeness}',
                              color: AppTheme.success,
                            ),
                            ModernBadge(
                              label: 'Accuracy: ${a.accuracy}',
                              color: AppTheme.primaryPurple,
                            ),
                            ModernBadge(
                              label: 'Fluency: ${a.fluency}',
                              color: AppTheme.warning,
                            ),
                            ModernBadge(
                              label: 'Confidence: ${a.confidence}',
                              color: AppTheme.error,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.space4),
                        _buildAnswerSection('Question', a.question),
                        const SizedBox(height: AppTheme.space3),
                        _buildAnswerSection('Your Answer', a.candidate_answer),
                        const SizedBox(height: AppTheme.space3),
                        _buildAnswerSection('Model Answer', a.model_answer),
                        const SizedBox(height: AppTheme.space3),
                        _buildAnswerSection('Feedback', a.feedback),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppTheme.space10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthsCard(SessionAnalysis analysis) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.success, size: 24),
              const SizedBox(width: AppTheme.space2),
              const Text('Strengths', style: AppTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppTheme.space4),
          if (analysis.strengths.isEmpty)
            Text('No strengths identified', style: AppTheme.bodyMedium)
          else
            ...analysis.strengths.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.space2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.success,
                      size: 16,
                    ),
                    const SizedBox(width: AppTheme.space2),
                    Expanded(child: Text(s, style: AppTheme.bodyMedium)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeaknessesCard(SessionAnalysis analysis) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: AppTheme.error, size: 24),
              const SizedBox(width: AppTheme.space2),
              const Text('Weaknesses', style: AppTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppTheme.space4),
          if (analysis.weaknesses.isEmpty)
            Text('No weaknesses identified', style: AppTheme.bodyMedium)
          else
            ...analysis.weaknesses.map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.space2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppTheme.error,
                      size: 16,
                    ),
                    const SizedBox(width: AppTheme.space2),
                    Expanded(child: Text(w, style: AppTheme.bodyMedium)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(SessionAnalysis analysis) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppTheme.warning, size: 24),
              const SizedBox(width: AppTheme.space2),
              const Text('Recommendations', style: AppTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppTheme.space4),
          if (analysis.recommendations.isEmpty)
            Text('No recommendations available', style: AppTheme.bodyMedium)
          else
            ...analysis.recommendations.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.space2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.warning,
                      size: 16,
                    ),
                    const SizedBox(width: AppTheme.space2),
                    Expanded(child: Text(r, style: AppTheme.bodyMedium)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCoachingCard(dynamic coaching) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              const Text('AI Coaching', style: AppTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppTheme.space4),
          const Text('Action Items', style: AppTheme.titleSmall),
          const SizedBox(height: AppTheme.space2),
          ...List.from(coaching['action_items'] ?? []).map(
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.space1),
              child: Text('• $i', style: AppTheme.bodyMedium),
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          const Text('Confidence Tips', style: AppTheme.titleSmall),
          const SizedBox(height: AppTheme.space2),
          ...List.from(coaching['confidence_tips'] ?? []).map(
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.space1),
              child: Text('• $i', style: AppTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard(SessionAnalysis analysis) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Skills Breakdown'),
          const SizedBox(height: AppTheme.space4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _labeledNumber('Technical', analysis.skills_breakdown.technical),
              _labeledNumber(
                'Communication',
                analysis.skills_breakdown.communication,
              ),
              _labeledNumber(
                'Problem Solving',
                analysis.skills_breakdown.problem_solving,
              ),
              _labeledNumber(
                'Confidence',
                analysis.skills_breakdown.confidence,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(SessionAnalysis analysis) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Progress Tracking'),
          const SizedBox(height: AppTheme.space4),
          _infoRow(
            'Previous Avg',
            '${analysis.progress_tracking.previous_sessions_avg ?? '-'}',
          ),
          const SizedBox(height: AppTheme.space2),
          _infoRow(
            'Improvement',
            '${analysis.progress_tracking.improvement ?? '-'}',
          ),
        ],
      ),
    );
  }

  Widget _buildJobFitCard(SessionAnalysis analysis) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppTheme.successGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${analysis.job_fit_analysis.fit_score}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space4),
              const Expanded(
                child: Text('Job Fit Score', style: AppTheme.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space4),
          const Text('Strengths for Role', style: AppTheme.titleSmall),
          const SizedBox(height: AppTheme.space2),
          ...analysis.job_fit_analysis.strengths_for_role.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.space1),
              child: Text('• $s', style: AppTheme.bodyMedium),
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          const Text('Gaps for Role', style: AppTheme.titleSmall),
          const SizedBox(height: AppTheme.space2),
          ...analysis.job_fit_analysis.gaps_for_role.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.space1),
              child: Text('• $g', style: AppTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTheme.titleSmall),
        const SizedBox(height: AppTheme.space2),
        Container(
          padding: const EdgeInsets.all(AppTheme.space3),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGray,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Text(content, style: AppTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _labeledNumber(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryPurple),
        ),
        const SizedBox(height: AppTheme.space1),
        Text(label, style: AppTheme.bodySmall, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyMedium),
        Text(
          value,
          style: AppTheme.titleSmall.copyWith(color: AppTheme.primaryPurple),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppTheme.success;
    if (score >= 60) return AppTheme.info;
    if (score >= 40) return AppTheme.warning;
    return AppTheme.error;
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
