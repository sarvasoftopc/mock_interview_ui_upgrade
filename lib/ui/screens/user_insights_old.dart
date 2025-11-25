import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/adaptive_session_provider.dart';
import '../../providers/interview_provider.dart';
import '../../widgets/modern_widgets.dart';

/// Modern Insights Dashboard with upgraded UI
/// Preserves all existing functionality
class InsightsDashboardScreen extends StatefulWidget {
  const InsightsDashboardScreen({super.key});

  @override
  _InsightsDashboardScreenState createState() =>
      _InsightsDashboardScreenState();
}

class _InsightsDashboardScreenState extends State<InsightsDashboardScreen> {
  Map<String, dynamic>? insights;
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadInsights();
  }

  Future<void> loadInsights() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final provider = context.read<InterviewProvider>();
      final resp = await provider.getInsights();
      setState(() {
        insights = resp['insights'];
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  List<FlSpot> _toSpots(List<dynamic>? arr) {
    if (arr == null) return [];
    return List<FlSpot>.generate(
      arr.length,
      (i) => FlSpot(i.toDouble(), (arr[i] as num).toDouble()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Insights'),
          backgroundColor: AppTheme.primaryPurple,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Insights'),
          backgroundColor: AppTheme.primaryPurple,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(error, style: AppTheme.bodyMedium),
                const SizedBox(height: 24),
                GradientButton(
                  text: 'Retry',
                  onPressed: loadInsights,
                  icon: Icons.refresh,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final data = insights!;
    final total = data['total_interviews']?.toString() ?? '0';
    final avgTime = data['avg_interview_time']?.toString() ?? '0';
    final avgScore = data['avg_score']?.toString() ?? '0';
    final avgConfidence = data['avg_confidence']?.toString() ?? '0';
    final topSkills = (data['top_skills'] as Map?)?.entries.toList() ?? [];

    final scoresTrend = _toSpots(
      List<dynamic>.from(data['trend_scores'] ?? []),
    );
    final confTrend = _toSpots(
      List<dynamic>.from(data['trend_confidence'] ?? []),
    );
    final fluTrend = _toSpots(List<dynamic>.from(data['trend_fluency'] ?? []));

    final cfi = data['confidence_fluency_index']?.toString() ?? '0';
    final cfiExplanations = data['cfi_explanation']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Insights'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadInsights,
            tooltip: 'Refresh insights',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stats Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return isWide
                      ? Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                value: total,
                                label: 'Total Interviews',
                                icon: Icons.assessment,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                value: avgTime,
                                label: 'Avg Time (min)',
                                icon: Icons.timer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                value: avgScore,
                                label: 'Avg Score',
                                icon: Icons.star,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            StatCard(
                              value: total,
                              label: 'Total Interviews',
                              icon: Icons.assessment,
                            ),
                            const SizedBox(height: 12),
                            StatCard(
                              value: avgTime,
                              label: 'Avg Time (min)',
                              icon: Icons.timer,
                            ),
                            const SizedBox(height: 12),
                            StatCard(
                              value: avgScore,
                              label: 'Avg Score',
                              icon: Icons.star,
                            ),
                          ],
                        );
                },
              ),
              const SizedBox(height: 24),

              // Trend Chart
              Container(
                decoration: AppTheme.elevatedCard,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Performance Trends',
                      style: AppTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 100,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: scoresTrend,
                              isCurved: true,
                              color: AppTheme.primaryPurple,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: confTrend,
                              isCurved: true,
                              color: Colors.orange,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: fluTrend,
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendItem(
                          color: AppTheme.primaryPurple,
                          label: 'Score',
                        ),
                        const SizedBox(width: 16),
                        _LegendItem(color: Colors.orange, label: 'Confidence'),
                        const SizedBox(width: 16),
                        _LegendItem(color: Colors.green, label: 'Fluency'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // CFI Card
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  boxShadow: AppTheme.shadowMd,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Confidence–Fluency Index',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cfi,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (cfiExplanations.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        cfiExplanations,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Top Skills
              Container(
                decoration: AppTheme.elevatedCard,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Top Skills', style: AppTheme.titleMedium),
                    const SizedBox(height: 12),
                    if (topSkills.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No skills data available yet',
                          style: AppTheme.bodySmall,
                        ),
                      )
                    else
                      ...topSkills.map((e) {
                        final skill = e.key;
                        final score = (e.value ?? 0).toString();
                        return ListTile(
                          leading: const Icon(
                            Icons.star,
                            color: AppTheme.primaryPurple,
                          ),
                          title: Text(skill),
                          trailing: Text(
                            score,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryPurple,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Weakest Skills
              Container(
                decoration: AppTheme.elevatedCard,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Areas to Improve', style: AppTheme.titleMedium),
                    const SizedBox(height: 12),
                    ...((data['weakest_skills'] as List?) ?? []).map((w) {
                      return ListTile(
                        leading: const Icon(
                          Icons.trending_down,
                          color: Colors.orange,
                        ),
                        title: Text(w['skill'] ?? ''),
                        trailing: Text(
                          (w['avg'] ?? 0).toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTheme.bodySmall),
      ],
    );
  }
}
