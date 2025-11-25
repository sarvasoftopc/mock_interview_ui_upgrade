import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarvasoft_moc_interview/models/generatequestions.dart';
import 'package:sarvasoft_moc_interview/services/tts_service.dart';

import '../../providers/interview_provider.dart';
import '../../providers/session_provider.dart';
import '../widgets/audio_recorder.dart';
import '../widgets/question_card.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  bool _isRecording = false;
  String _lastMessage = '';

  Future<void> _onDeleteRecording() async {
    final provider = Provider.of<InterviewProvider>(context, listen: false);
    final deleted = await provider.deleteRecording();
    setState(() => _lastMessage = 'Recording deleted');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted ? 'Recording deleted successfully' : 'No recording to delete',
        ),
      ),
    );
  }

  Future<void> _onStart() async {
    setState(() => _isRecording = true);
    await Provider.of<InterviewProvider>(
      context,
      listen: false,
    ).startAnswerRecording();
  }

  Future<Uint8List> _onStop() async {
    setState(() => _isRecording = false);
    await Provider.of<InterviewProvider>(
      context,
      listen: false,
    ).stopAnswerRecording();
    setState(() => _lastMessage = 'Answer recorded');
    return Uint8List(0);
  }

  Future<void> _onPlay() async => Provider.of<InterviewProvider>(
    context,
    listen: false,
  ).playLastRecording();

  Future<void> _onStopPlay() async =>
      Provider.of<InterviewProvider>(context, listen: false).stopLasPlay();

  Future<void> _submitSession() async {
    final provider = Provider.of<InterviewProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(
      context,
      listen: false,
    );

    try {
      await provider.submitSession(sessionProvider, runInBackground: true);
      Navigator.pushReplacementNamed(context, '/sessions');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Session submission started — report will appear shortly.',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to start submission: $e')));
    }
  }

  Widget _buildRecorderCard(bool isWide) {
    final interview = context.watch<InterviewProvider>();
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.mic, size: 28, color: Colors.indigo),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Your Answer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                if (!isWide)
                  IconButton(
                    onPressed: _submitSession,
                    icon: const Icon(Icons.send_rounded),
                    tooltip: 'Submit session',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            AudioRecorder(
              isRecording: _isRecording,
              onStart: _onStart,
              onStop: _onStop,
              onPlay: _onPlay,
              onStopPlay: _onStopPlay,
              deleteRecording: _onDeleteRecording,
              isPlayEnabled: interview.hasRecording,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _lastMessage,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            // action row for navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    onPressed: interview.currentIndex > 0
                        ? interview.previous
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade50,
                      foregroundColor: Colors.indigo.shade800,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(
                      interview.currentIndex < interview.questions.length - 1
                          ? Icons.arrow_forward
                          : Icons.check_circle_outline,
                    ),
                    label: Text(
                      interview.currentIndex < interview.questions.length - 1
                          ? 'Next'
                          : 'Finish',
                    ),
                    onPressed:
                        interview.currentIndex < interview.questions.length - 1
                        ? interview.next
                        : _submitSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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

  @override
  Widget build(BuildContext context) {
    final interview = context.watch<InterviewProvider>();
    final q = interview.currentQuestion;
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Question'),
        backgroundColor: Colors.indigo.shade600,
        actions: [
          IconButton(
            icon: const Icon(Icons.send_rounded),
            tooltip: 'Submit Session',
            onPressed: _submitSession,
          ),
        ],
      ),

      body: SafeArea(
        child: q == null
            ? const Center(child: Text('No question available'))
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final isWide = width >= 900;
                  // adaptive padding
                  final horizontalPadding = isWide ? 40.0 : 12.0;
                  final verticalPadding = isWide ? 18.0 : 12.0;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top row or single column depending on width
                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left column: flexible; takes remaining space
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Question Card
                                    Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      shadowColor: Colors.indigo.withOpacity(
                                        0.12,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: QuestionCard(
                                          question: q,
                                          highlighted: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Listen + Submit row (wrap so Submit won't push)
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 8,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: isWide
                                              ? (width * 0.45)
                                              : double.infinity,
                                          child: ElevatedButton.icon(
                                            icon: const Icon(
                                              Icons.volume_up_rounded,
                                            ),
                                            label: const Text(
                                              'Listen to Question',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.indigo.shade600,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: () {
                                              final tts = context
                                                  .read<TtsService>();
                                              tts.speak(q.question, q.ttsFile);
                                            },
                                          ),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed: _submitSession,
                                          icon: const Icon(Icons.send_rounded),
                                          label: const Text('Submit'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Small pager/info
                                    Consumer<InterviewProvider>(
                                      builder: (context, interview, _) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Question ${interview.currentIndex + 1} of ${interview.questions.length}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            Text(
                                              interview.hasRecording
                                                  ? 'Recording available'
                                                  : 'No recording yet',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: interview.hasRecording
                                                    ? Colors.green.shade700
                                                    : Colors.black45,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // Tip card
                                    Card(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      color: Colors.white,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.info_outline,
                                              color: Colors.indigo,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Tip: Speak clearly and treat this like a real interview. You can re-record before moving to next question.',
                                                style: TextStyle(
                                                  color: Colors.grey.shade800,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 24),

                              // Right column: use Flexible so it can shrink if needed
                              Flexible(
                                flex: 1,
                                child: Column(
                                  children: [
                                    _buildRecorderCard(
                                      true,
                                    ), // keep your method
                                    const SizedBox(height: 16),
                                    // session controls card (keeps small footprint)
                                    Card(
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: 14,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Session Controls',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ElevatedButton.icon(
                                              onPressed: _submitSession,
                                              icon: const Icon(
                                                Icons.cloud_upload,
                                              ),
                                              label: const Text(
                                                'Submit Session',
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.indigo.shade600,
                                                foregroundColor: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            OutlinedButton.icon(
                                              onPressed: _onDeleteRecording,
                                              icon: const Icon(
                                                Icons.delete_outline,
                                              ),
                                              label: const Text(
                                                'Delete Last Recording',
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          // Narrow screen: stack vertically
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                shadowColor: Colors.indigo.withOpacity(0.12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: QuestionCard(
                                    question: q,
                                    highlighted: true,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.volume_up_rounded),
                                label: const Text('Listen to Question'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo.shade600,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {
                                  final tts = context.read<TtsService>();
                                  tts.speak(q.question, q.ttsFile);
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildRecorderCard(false),
                              const SizedBox(height: 12),
                              Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 14,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: _onDeleteRecording,
                                        icon: const Icon(Icons.delete_outline),
                                        label: const Text(
                                          'Delete Last Recording',
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(
                                        onPressed: _submitSession,
                                        icon: const Icon(Icons.cloud_upload),
                                        label: const Text('Submit Session'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.indigo.shade600,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
