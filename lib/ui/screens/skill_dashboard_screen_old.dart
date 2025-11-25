import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarvasoft_moc_interview/models/mock_interview_session.dart';
import 'package:sarvasoft_moc_interview/ui/screens/summary_bottom_sheet.dart';
import 'package:sarvasoft_moc_interview/ui/widgets/custom_app_bar.dart';

import '../../generated/l10n.dart';
import '../../providers/cv_jd_provider.dart';
import '../../providers/interview_provider.dart';
import '../widgets/app_drawer.dart';

class SkillDashboardScreen extends StatefulWidget {
  const SkillDashboardScreen({super.key});

  @override
  State<SkillDashboardScreen> createState() => _SkillDashboardScreenState();
}

class _SkillDashboardScreenState extends State<SkillDashboardScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // Ensure provider loads last analysis if not already loaded.
      final cvJdProvider = context.read<CvJdProvider>();
      cvJdProvider.ensureAnalysisLoaded();
      _initialized = true;
    }
  }

  Future<void> _startMockInterview(BuildContext context) async {
    final provider = context.read<InterviewProvider>();

    final cvJdProvider = context.read<CvJdProvider>();
    if (cvJdProvider.sessionId.isNotEmpty &&
        cvJdProvider.questions.isNotEmpty) {
      // use existing session/questions
      debugPrint("current session with session id:${cvJdProvider.sessionId}");
      provider.loadQuestions(cvJdProvider.questions);
      provider.startSession(cvJdProvider.sessionId, SessionType.normal);
    } else {
      // fetch analysis & questions (provider handles repeated calls / caching)
      await cvJdProvider.extractSkillsAndFetchQuestions();

      debugPrint("current session with session id:${cvJdProvider.sessionId}");
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
    final summary = cvJdProvider.summary ?? "No summary available.";
    final matchScore = double.tryParse(cvJdProvider.matchScore ?? "0") ?? 0.0;

    return Scaffold(
      appBar: CustomAppBar(
        context: context,
        titleText: AppLocalizations.of(context).skillsDashboard,
      ),
      drawer: const AppDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          // Wide screen: two-column layout (main content + right panel)
          if (width >= 1000) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left / main column
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildMatchScoreCard(context, matchScore, summary),
                          const SizedBox(height: 16),
                          _buildInsightsCard(
                            context,
                            overlapSkills,
                            missingSkills,
                            extraSkills,
                            matchScore,
                          ),
                          const SizedBox(height: 16),
                          _buildSkillsTabs(
                            context,
                            overlapSkills,
                            missingSkills,
                            extraSkills,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.indigo, Colors.blue],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/preparationHub',
                                        arguments: {
                                          "missingSkills": missingSkills,
                                        },
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.school,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      AppLocalizations.of(
                                        context,
                                      ).prepareMissingSkills,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.deepPurple,
                                        Colors.pinkAccent,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _startMockInterview(context),
                                    icon: const Icon(
                                      Icons.mic,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      AppLocalizations.of(
                                        context,
                                      ).startMockInterview,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Right / side column: useful info, quick actions, recent sessions
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.timeline),
                                  title: Text("Reset Sessions"),
                                  onTap: () =>
                                      Navigator.pushNamed(context, '/sessions'),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.playlist_add_check),
                                  title: Text("Recommended Practice"),
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/preparationHub',
                                    arguments: {"missingSkills": missingSkills},
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.share),
                                  title: Text("Share Report"),
                                  onTap: () {
                                    // TODO: implement share
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Quick Tip",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "• Add missing skills to your CV\n• Practice STAR stories for behavioral questions\n• Record 5-minute answers and review",
                                ),
                              ],
                            ),
                          ),
                        ),
                        // put more side widgets as needed
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // Medium screens: two-column like tablet
          if (width >= 600) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMatchScoreCard(
                            context,
                            matchScore,
                            summary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInsightsCard(
                            context,
                            overlapSkills,
                            missingSkills,
                            extraSkills,
                            matchScore,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSkillsTabs(
                      context,
                      overlapSkills,
                      missingSkills,
                      extraSkills,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.indigo, Colors.blue],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/preparationHub',
                                  arguments: {"missingSkills": missingSkills},
                                );
                              },
                              icon: const Icon(
                                Icons.school,
                                color: Colors.white,
                              ),
                              label: Text(
                                AppLocalizations.of(
                                  context,
                                ).prepareMissingSkills,
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.deepPurple, Colors.pinkAccent],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => _startMockInterview(context),
                              icon: const Icon(Icons.mic, color: Colors.white),
                              label: Text(
                                AppLocalizations.of(context).startMockInterview,
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          // Narrow screen (mobile) - original layout preserved
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ===== Match Score Radial Chart =====
                _buildMatchScoreCard(context, matchScore, summary),

                const SizedBox(height: 16),

                // ===== Insights =====
                _buildInsightsCard(
                  context,
                  overlapSkills,
                  missingSkills,
                  extraSkills,
                  matchScore,
                ),

                const SizedBox(height: 16),

                // ===== Skills Tabs =====
                _buildSkillsTabs(
                  context,
                  overlapSkills,
                  missingSkills,
                  extraSkills,
                ),

                const SizedBox(height: 24),

                // ===== Action Buttons =====
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.indigo, Colors.blue],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/preparationHub',
                              arguments: {"missingSkills": missingSkills},
                            );
                          },
                          icon: const Icon(Icons.school, color: Colors.white),
                          label: Text(
                            AppLocalizations.of(context).prepareMissingSkills,
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.deepPurple, Colors.pinkAccent],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _startMockInterview(context),
                          icon: const Icon(Icons.mic, color: Colors.white),
                          label: Text(
                            AppLocalizations.of(context).startMockInterview,
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // === Match Score Card ===
  Widget _buildMatchScoreCard(
    BuildContext context,
    double matchScore,
    String summary,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).matchScore,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              width: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: matchScore / 100,
                    strokeWidth: 14,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      matchScore >= 75
                          ? Colors.green
                          : matchScore >= 50
                          ? Colors.amber
                          : Colors.redAccent,
                    ),
                  ),
                  Text(
                    "${matchScore.toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.article_outlined),
              label: const Text("View Summary"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) {
                    return SummaryBottomSheet(summary: summary);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // === Insights Card ===
  Widget _buildInsightsCard(
    BuildContext context,
    List<String> overlap,
    List<String> missing,
    List<String> extra,
    double score,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context).insights,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            _insightRow(
              context,
              AppLocalizations.of(context).matchedSkills,
              "${overlap.length}",
            ),
            _insightRow(
              context,
              AppLocalizations.of(context).missingSkills,
              "${missing.length}",
            ),
            _insightRow(
              context,
              AppLocalizations.of(context).extraSkills,
              "${extra.length}",
            ),
            _insightRow(
              context,
              AppLocalizations.of(context).strengthArea,
              overlap.isNotEmpty
                  ? overlap.first
                  : AppLocalizations.of(context).na,
            ),
          ],
        ),
      ),
    );
  }

  Widget _insightRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }

  // === Skills Tabs ===
  Widget _buildSkillsTabs(
    BuildContext context,
    List<String> overlap,
    List<String> missing,
    List<String> extra,
  ) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.indigo,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.indigo,
            tabs: [
              Tab(text: AppLocalizations.of(context).matchedSkills),
              Tab(text: AppLocalizations.of(context).missingSkills),
              Tab(text: AppLocalizations.of(context).extraSkills),
            ],
          ),
          Container(
            height: 220,
            padding: const EdgeInsets.all(12),
            child: TabBarView(
              children: [
                _skillsChipList(overlap, Colors.green.shade600),
                _skillsChipList(missing, Colors.redAccent.shade200),
                _skillsChipList(extra, Colors.blueGrey.shade400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillsChipList(List<String> skills, Color color) {
    if (skills.isEmpty) {
      return const Center(child: Text("No skills found"));
    }
    return SingleChildScrollView(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills
            .map(
              (skill) => Chip(
                label: Text(
                  skill,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
