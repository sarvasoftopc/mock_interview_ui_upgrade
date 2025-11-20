import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/candidate_session.dart';
import '../../models/session_analysis.dart';
import '../../providers/session_provider.dart';

class SessionDetailScreen extends StatefulWidget {
  final String sessionId;
  final String sessionType;
  const SessionDetailScreen({super.key, required this.sessionId,required this.sessionType});

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
    // fetch once when screen opens
    _ensureAnalysisLoaded();
  }

  Future<void> _ensureAnalysisLoaded() async {
    if (_analysis != null || !_loading && _error == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final provider = context.read<SessionProvider>();

    // return cached if available
    final cached = provider.getAnalysisFor(widget.sessionId);
    if (cached != null) {
      setState(() {
        _analysis = cached;
        _loading = false;
      });
      return;
    }

    try {
      final fetched = await provider.fetchSessionDetails(widget.sessionId,widget.sessionType);
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
    return await provider.getSessionCoaching(sessionId,sessionType);

  }

  Widget _metricChip(String label, int value) {
    final color = value >= 75
        ? Colors.green
        : (value >= 50 ? Colors.orange : Colors.red);
    return Chip(
      backgroundColor: color.withOpacity(0.12),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Text("$value", style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SessionProvider>();
    final session = provider.getSessionById(widget.sessionId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Session ${widget.sessionId}'),
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
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null)
          ? Center(child: Text(_error!))
          : (_analysis == null)
          ? const Center(child: Text('No analysis available'))
          : _buildBody(context, session, _analysis!),
    );
  }

  Widget _buildBody(BuildContext context, CandidateSession? session, SessionAnalysis analysis) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Top summary
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.blue.shade50,
                    child: Text(
                      "${analysis.overall_score}",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Overall readiness', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(analysis.summary, style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        Text(
                          session != null ? 'Session date: ${_formatDate(session.createdAt)}' : '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _metricChip("Relevance", analysis.overall_relevance),
                _metricChip("Completeness", analysis.overall_completeness),
                _metricChip("Accuracy", analysis.overall_accuracy),
                _metricChip("Fluency", analysis.overall_fluency),
                _metricChip("Confidence", analysis.overall_confidence),
                _metricChip("Tone", analysis.candidateToneAnalysis),
              ]),
            ]),
          ),
        ),

        const SizedBox(height: 12),

        // Strengths / Weaknesses / Recommendations
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Strengths', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (analysis.strengths.isEmpty) Text('—'),
                  for (var s in analysis.strengths)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(s)),
                      ]),
                    )
                ]),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Weaknesses', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (analysis.weaknesses.isEmpty) Text('—'),
                  for (var w in analysis.weaknesses)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(w)),
                      ]),
                    )
                ]),
              ),
            ),
          ),
        ]),

        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Recommendations', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (analysis.recommendations.isEmpty) Text('—'),
              for (var r in analysis.recommendations)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(r)),
                  ]),
                )
            ]),
          ),
        ),

        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () async {
            setState(() => loadingCoaching = true);
            final data  = await getSessionCoaching(widget.sessionId,widget.sessionType);
            setState(() {
              coaching = data;
              loadingCoaching = false;
            });
          },
          icon: Icon(Icons.psychology),
          label: Text('Generate Session Coaching'),
        ),
        if (coaching != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Action Items', style: TextStyle(fontWeight: FontWeight.bold)),
              ...List.from(coaching['action_items'] ?? []).map((i)=>Text('• $i')),
              Text('Confidence Tips', style: TextStyle(fontWeight: FontWeight.bold)),
              ...List.from(coaching['confidence_tips'] ?? []).map((i)=>Text('• $i')),
            ],
          ),
        const SizedBox(height: 12),
        // Skills breakdown + Progress
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Skills breakdown', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _labeledNumber('Technical', analysis.skills_breakdown.technical),
                _labeledNumber('Communication', analysis.skills_breakdown.communication),
                _labeledNumber('Problem solving', analysis.skills_breakdown.problem_solving),
                _labeledNumber('Confidence', analysis.skills_breakdown.confidence),
              ]),
              const SizedBox(height: 12),
              Text('Progress', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: Text('Previous avg: ${analysis.progress_tracking.previous_sessions_avg ?? '-'}')),
                Expanded(child: Text('Improvement: ${analysis.progress_tracking.improvement ?? '-'}')),
              ]),
            ]),
          ),
        ),

        const SizedBox(height: 12),

        // Job fit
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Job fit', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(children: [
                const Text('Fit score:'),
                const SizedBox(width: 12),
                CircleAvatar(child: Text('${analysis.job_fit_analysis.fit_score}')),
              ]),
              const SizedBox(height: 8),
              Text('Strengths for role', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              for (var s in analysis.job_fit_analysis.strengths_for_role) Text('• $s'),
              const SizedBox(height: 8),
              Text('Gaps for role', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              for (var g in analysis.job_fit_analysis.gaps_for_role) Text('• $g'),
            ]),
          ),
        ),

        const SizedBox(height: 16),

        // Per-answer breakdown
        Text('Answers', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        ...analysis.per_answer_analysis.asMap().entries.map((entry) {
          final idx = entry.key;
          final a = entry.value;
          return Card(
            child: ExpansionTile(
              key: ValueKey('answer_$idx'),
              title: Row(children: [
                Text('Q ${idx + 1}'),
                const SizedBox(width: 12),
                Text('Score: ${a.score}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              subtitle: Text(a.feedback, maxLines: 1, overflow: TextOverflow.ellipsis),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Wrap(spacing: 8, children: [
                      Chip(label: Text('Relevance: ${a.relevance}')),
                      Chip(label: Text('Completeness: ${a.completeness}')),
                      Chip(label: Text('Accuracy: ${a.accuracy}')),
                      Chip(label: Text('Fluency: ${a.fluency}')),
                      Chip(label: Text('Confidence: ${a.confidence}')),
                    ]),
                    const SizedBox(height: 12),
                    Text('Question', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(a.question),
                    const SizedBox(height: 6),
                    Text('Candidate Answer', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(a.candidate_answer),
                    const SizedBox(height: 12),
                    Text('Model answer', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(a.model_answer),
                    const SizedBox(height: 10),
                    Text('Feedback', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(a.feedback),
                    const SizedBox(height: 10),
                    // If you store transcripts/audio urls per answer, show them here:
                    // Text('Transcript: ${a.transcript ?? 'Not available'}')
                  ]),
                )
              ],
            ),
          );
        }).toList(),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _labeledNumber(String label, int value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

}

