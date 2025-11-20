import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarvasoft_moc_interview/models/generatequestions.dart';
import 'package:sarvasoft_moc_interview/services/tts_service.dart';
import '../../config/app_theme.dart';
import '../../providers/interview_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/modern_components.dart';
import '../widgets/audio_recorder.dart';
import '../widgets/question_card.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({Key? key}) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  String _lastMessage = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onDeleteRecording() async {
    final provider = Provider.of<InterviewProvider>(context, listen: false);
    final deleted = await provider.deleteRecording();
    setState(() => _lastMessage = 'Recording deleted');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(deleted ? 'Recording deleted successfully' : 'No recording to delete'),
        backgroundColor: deleted ? AppTheme.success : AppTheme.error,
      ),
    );
  }

  Future<void> _onStart() async {
    setState(() => _isRecording = true);
    await Provider.of<InterviewProvider>(context, listen: false).startAnswerRecording();
  }

  Future<Uint8List> _onStop() async {
    setState(() => _isRecording = false);
    await Provider.of<InterviewProvider>(context, listen: false).stopAnswerRecording();
    setState(() => _lastMessage = 'Answer recorded');
    return Uint8List(0);
  }

  Future<void> _onPlay() async =>
      Provider.of<InterviewProvider>(context, listen: false).playLastRecording();

  Future<void> _onStopPlay() async =>
      Provider.of<InterviewProvider>(context, listen: false).stopLasPlay();

  Future<void> _submitSession() async {
    final provider = Provider.of<InterviewProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    try {
      await provider.submitSession(sessionProvider, runInBackground: true);
      Navigator.pushReplacementNamed(context, '/sessions');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session submission started — report will appear shortly.'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start submission: $e'), backgroundColor: AppTheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final interview = context.watch<InterviewProvider>();
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1200;
    final isTablet = size.width > 768 && size.width <= 1200;

    if (interview.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          title: const Text('Interview'),
          backgroundColor: AppTheme.primaryPurple,
          foregroundColor: Colors.white,
        ),
        body: const EmptyState(
          icon: Icons.quiz,
          title: 'No Questions Available',
          description: 'Please start an interview session first',
        ),
      );
    }

    final currentQ = interview.currentQuestion;
    final progress = (interview.currentIndex + 1) / interview.questions.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Question ${interview.currentIndex + 1}/${interview.questions.length}'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          if (isWide)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: ModernButton(
                  text: 'Submit',
                  icon: Icons.send,
                  onPressed: _submitSession,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4, vertical: AppTheme.space3),
            child: Column(
              children: [
                ModernProgressBar(progress: progress, height: 8),
                const SizedBox(height: AppTheme.space2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: ${((progress) * 100).toInt()}%',
                      style: AppTheme.bodySmall,
                    ),
                    Text(
                      '${interview.currentIndex + 1} of ${interview.questions.length}',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? AppTheme.space12 : (isTablet ? AppTheme.space8 : AppTheme.space4),
                vertical: AppTheme.space6,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 1000 : double.infinity),
                  child: Column(
                    children: [
                      // Question Card
                      FadeTransition(
                        opacity: _animationController,
                        child: QuestionCard(question: currentQ),
                      ),
                      const SizedBox(height: AppTheme.space6),

                      // Answer Recorder Card
                      FadeTransition(
                        opacity: _animationController,
                        child: _buildRecorderCard(isWide, interview),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecorderCard(bool isWide, InterviewProvider interview) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Icon(Icons.mic, color: Colors.white, size: 24),
              ),
              const SizedBox(width: AppTheme.space3),
              const Expanded(
                child: Text('Your Answer', style: AppTheme.titleLarge),
              ),
              if (!isWide)
                IconButton(
                  onPressed: _submitSession,
                  icon: const Icon(Icons.send_rounded, color: AppTheme.primaryPurple),
                  tooltip: 'Submit session',
                ),
            ],
          ),
          const SizedBox(height: AppTheme.space4),

          // Audio Recorder
          AudioRecorder(
            isRecording: _isRecording,
            onStart: _onStart,
            onStop: _onStop,
            onPlay: _onPlay,
            onStopPlay: _onStopPlay,
            deleteRecording: _onDeleteRecording,
            isPlayEnabled: interview.hasRecording,
          ),

          if (_lastMessage.isNotEmpty) ..[
            const SizedBox(height: AppTheme.space3),
            Container(
              padding: const EdgeInsets.all(AppTheme.space3),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.success, size: 20),
                  const SizedBox(width: AppTheme.space2),
                  Expanded(
                    child: Text(_lastMessage, style: AppTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppTheme.space6),

          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  onPressed: interview.currentIndex > 0 ? interview.previous : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryPurple,
                    side: const BorderSide(color: AppTheme.primaryPurple, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: interview.currentIndex < interview.questions.length - 1
                        ? AppTheme.primaryGradient
                        : AppTheme.successGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: ElevatedButton.icon(
                    icon: Icon(
                      interview.currentIndex < interview.questions.length - 1
                          ? Icons.arrow_forward
                          : Icons.check_circle,
                    ),
                    label: Text(
                      interview.currentIndex < interview.questions.length - 1
                          ? 'Next Question'
                          : 'Finish Interview',
                    ),
                    onPressed: interview.currentIndex < interview.questions.length - 1
                        ? interview.next
                        : _submitSession,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
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
  }
}
