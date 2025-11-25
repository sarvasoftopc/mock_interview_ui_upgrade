// lib/screens/question_screen.dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../services/tts_service.dart';
import '../../widgets/modern_components.dart';
import '../../providers/interview_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/video_answer_player.dart';
import '../widgets/audio_recorder.dart';
import '../widgets/question_card.dart';
import '../../widgets/movie_scroll_text.dart';
import '../widgets/video_recorder.dart';
import '../../services/video_service.dart';

// class QuestionScreenV2 extends StatefulWidget {
//   const QuestionScreenV2({Key? key}) : super(key: key);
//
//   @override
//   State<QuestionScreenV2> createState() => _QuestionScreenV2State();
// }
//
// class _QuestionScreenV2State extends State<QuestionScreenV2> {
//   bool _isRecording = false;
//   String _lastMessage = '';
//   bool _showScroll = true;
//   bool _autoPlayed = false;
//
//   // mode: 'audio' or 'video'
//   String _mode = 'video';
//
//   Future<void> _onDeleteRecording() async {
//     final provider = Provider.of<InterviewProvider>(context, listen: false);
//     final deleted = await provider.deleteLastVideoRecording();
//     setState(() => _lastMessage = 'Recording deleted');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(deleted ? 'Recording deleted successfully' : 'No recording to delete'),
//         backgroundColor: deleted ? AppTheme.success : AppTheme.error,
//       ),
//     );
//   }
//
//   Future<void> _onStartAudio() async {
//     setState(() => _isRecording = true);
//     await Provider.of<InterviewProvider>(context, listen: false).startAnswerRecording();
//   }
//
//   Future<Uint8List> _onStopAudio() async {
//     setState(() => _isRecording = false);
//     final bytes = await Provider.of<InterviewProvider>(context, listen: false).stopAnswerRecording();
//     setState(() => _lastMessage = 'Answer recorded');
//     return bytes;
//   }
//
//   Future<void> _onStartVideo() async {
//     setState(() => _isRecording = true);
//     await Provider.of<InterviewProvider>(context, listen: false).startVideoRecording();
//   }
//
//   Future<Uint8List> _onStopVideo() async {
//     setState(() => _isRecording = false);
//     final bytes = await Provider.of<InterviewProvider>(context, listen: false).stopVideoRecording();
//     setState(() => _lastMessage = 'Video answer saved');
//     return bytes;
//   }
//
//   Future<void> _onPlayAudio() async =>
//       Provider.of<InterviewProvider>(context, listen: false).playLastRecording();
//
//   Future<void> _onStopPlayAudio() async =>
//       Provider.of<InterviewProvider>(context, listen: false).stopLasPlay();
//
//   Future<void> _onPlayVideo() async {
//     final provider = Provider.of<InterviewProvider>(context, listen: false);
//     final path = await provider.playLastVideo();
//     if (path == null) return;
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => Scaffold(
//           appBar: AppBar(title: const Text("Your Video Answer")),
//           body: VideoAnswerPlayer(path: path),
//         ),
//       ),
//     );
//   }
//
//
//   Future<void> _submitSession() async {
//     final provider = Provider.of<InterviewProvider>(context, listen: false);
//     final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
//
//     try {
//       await provider.submitSession(sessionProvider, runInBackground: true);
//       Navigator.pushReplacementNamed(context, '/sessions');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Session submission started — report will appear shortly.'),
//           backgroundColor: AppTheme.success,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to start submission: $e'),
//           backgroundColor: AppTheme.error,
//         ),
//       );
//     }
//   }
//
//   Widget _buildRecorderCard(bool isWide) {
//     final interview = context.watch<InterviewProvider>();
//     final videoService = context.read<InterviewProvider>().video;
//
//     return ModernCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   gradient: AppTheme.primaryGradient,
//                   borderRadius: BorderRadius.circular(AppTheme.radiusMd),
//                 ),
//                 child: Icon(_mode == 'video' ? Icons.videocam : Icons.mic, color: Colors.white, size: 24),
//               ),
//               const SizedBox(width: AppTheme.space3),
//               Expanded(
//                 child: Text(_mode == 'video' ? 'Your Video Answer' : 'Your Audio Answer', style: AppTheme.titleLarge),
//               ),
//               ToggleButtons(
//                 isSelected: [_mode == 'audio', _mode == 'video'],
//                 onPressed: (i) {
//                   setState(() {
//                     _mode = i == 0 ? 'audio' : 'video';
//                     _lastMessage = '';
//                   });
//                 },
//                 children: const [Padding(padding: EdgeInsets.all(8), child: Text('Audio')), Padding(padding: EdgeInsets.all(8), child: Text('Video'))],
//               ),
//             ],
//           ),
//           const SizedBox(height: AppTheme.space4),
//
//           if (_mode == 'audio')
//             AudioRecorder(
//               isRecording: _isRecording,
//               onStart: _onStartAudio,
//               onStop: _onStopAudio,
//               onPlay: _onPlayAudio,
//               onStopPlay: _onStopPlayAudio,
//               deleteRecording: _onDeleteRecording,
//               isPlayEnabled: interview.hasRecording,
//             ),
//
//           if (_mode == 'video')
//             VideoRecorder(
//               service: videoService,
//               isRecording: _isRecording,
//               onStart: _onStartVideo,
//               onStop: _onStopVideo,
//               onPlay: _onPlayVideo,
//               deleteRecording: _onDeleteRecording,
//               isPlayEnabled: interview.hasVideoRecording,
//             ),
//
//           if (_lastMessage.isNotEmpty) ...[
//             const SizedBox(height: AppTheme.space3),
//             Container(
//               padding: const EdgeInsets.all(AppTheme.space3),
//               decoration: BoxDecoration(
//                 color: AppTheme.success.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(AppTheme.radiusSm),
//                 border: Border.all(color: AppTheme.success.withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.check_circle, color: AppTheme.success, size: 20),
//                   const SizedBox(width: AppTheme.space2),
//                   Expanded(child: Text(_lastMessage, style: AppTheme.bodyMedium)),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final interview = context.watch<InterviewProvider>();
//     final size = MediaQuery.of(context).size;
//     final isWide = size.width > 1100;
//
//     if (interview.questions.isEmpty) {
//       return Scaffold(
//         backgroundColor: AppTheme.backgroundLight,
//         appBar: AppBar(
//           title: const Text('Interview'),
//           backgroundColor: AppTheme.primaryPurple,
//           foregroundColor: Colors.white,
//         ),
//         body: const EmptyState(
//           icon: Icons.quiz,
//           title: 'No Questions Available',
//           description: 'Please start an interview session first',
//         ),
//       );
//     }
//
//     final currentQ = interview.currentQuestion;
//     final progress = (interview.currentIndex + 1) / interview.questions.length;
//
//     if (!_autoPlayed) {
//       final tts = context.read<TtsService>();
//       tts.speak(currentQ!.question, currentQ.getTtsFile);
//       _autoPlayed = true;
//     }
//
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundLight,
//       appBar: AppBar(
//         title: Text('Question ${interview.currentIndex + 1}/${interview.questions.length}'),
//         backgroundColor: AppTheme.primaryPurple,
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: Colors.white,
//             padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4, vertical: AppTheme.space3),
//             child: Column(
//               children: [
//                 ModernProgressBar(progress: progress, height: 8),
//                 const SizedBox(height: AppTheme.space2),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text('Progress: ${(progress * 100).toInt()}%', style: AppTheme.bodySmall),
//                     Text('${interview.currentIndex + 1} of ${interview.questions.length}', style: AppTheme.bodySmall),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
//               child: Center(
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(maxWidth: 1200),
//                   child: Column(
//                     children: [
//                       QuestionCard(question: currentQ!),
//                       const SizedBox(height: 30),
//
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             width: isWide ? 400 : 240,
//                             height: isWide ? 500 : 300,
//                             decoration: BoxDecoration(
//                               color: Colors.black,
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
//                             ),
//                             child: _showScroll
//                                 ? MovieScrollText(text: currentQ.question, width: isWide ? 400 : 240, height: isWide ? 500 : 300)
//                                 : const Center(child: Text("Question Hidden", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600))),
//                           ),
//
//                           const SizedBox(width: 40),
//
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.stretch,
//                               children: [
//                                 ElevatedButton.icon(
//                                   icon: const Icon(Icons.visibility),
//                                   label: const Text('Listen to Question Again'),
//                                   style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade600, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
//                                   onPressed: () {
//                                     setState(() {
//                                       _showScroll = !_showScroll;
//                                       _autoPlayed = false;
//                                     });
//                                   },
//                                 ),
//                                 const SizedBox(height: 30),
//                                 _buildRecorderCard(isWide),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 40),
//
//                       Row(
//                         children: [
//                           Expanded(
//                             child: OutlinedButton.icon(
//                               icon: const Icon(Icons.arrow_back),
//                               label: const Text('Previous'),
//                               onPressed: interview.currentIndex > 0 ? interview.previous : null,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             flex: 2,
//                             child: ElevatedButton.icon(
//                               icon: Icon(interview.currentIndex < interview.questions.length - 1 ? Icons.arrow_forward : Icons.check_circle),
//                               label: Text(interview.currentIndex < interview.questions.length - 1 ? 'Next Question' : 'Finish Interview'),
//                               onPressed: interview.currentIndex < interview.questions.length - 1
//                                   ? () {
//                                 setState(() {
//                                   _autoPlayed = false;
//                                   _showScroll = true;
//                                 });
//                                 interview.next();
//                               }
//                                   : _submitSession,
//                             ),
//                           )
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/screens/question_screen.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../services/tts_service.dart';
import '../../widgets/modern_components.dart';
import '../../providers/interview_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/video_answer_player.dart';
import '../widgets/audio_recorder.dart';
import '../widgets/question_card.dart';
import '../../widgets/movie_scroll_text.dart';
import '../widgets/video_recorder.dart';
import '../../services/video_service.dart';

class QuestionScreenV2 extends StatefulWidget {
  const QuestionScreenV2({super.key});

  @override
  State<QuestionScreenV2> createState() => _QuestionScreenV2State();
}

class _QuestionScreenV2State extends State<QuestionScreenV2> {
  bool _isRecording = false;
  String _lastMessage = '';
  bool _showScroll = true;
  bool _autoPlayed = false;

  // mode: 'audio' or 'video'
  String _mode = 'video';

  // video timer
  Timer? _recordTimer;
  Duration _recordDuration = Duration.zero;
  String get _recordElapsedStr => _formatDuration(_recordDuration);

  void _startRecordTimer() {
    _recordTimer?.cancel();
    _recordDuration = Duration.zero;
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _recordDuration = _recordDuration + const Duration(seconds: 1);
      });
    });
  }

  void _stopRecordTimer() {
    _recordTimer?.cancel();
    _recordTimer = null;
    _recordDuration = Duration.zero;
  }

  static String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Future<void> _onDeleteRecording() async {
    final provider = Provider.of<InterviewProvider>(context, listen: false);
    final deleted = await provider.deleteLastVideoRecording();
    setState(
      () => _lastMessage = deleted
          ? 'Recording deleted'
          : 'No recording to delete',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted ? 'Recording deleted successfully' : 'No recording to delete',
        ),
        backgroundColor: deleted ? AppTheme.success : AppTheme.error,
      ),
    );
  }

  Future<void> _onStartAudio() async {
    setState(() => _isRecording = true);
    await Provider.of<InterviewProvider>(
      context,
      listen: false,
    ).startAnswerRecording();
  }

  Future<Uint8List> _onStopAudio() async {
    setState(() => _isRecording = false);
    final bytes = await Provider.of<InterviewProvider>(
      context,
      listen: false,
    ).stopAnswerRecording();
    setState(() => _lastMessage = 'Answer recorded');
    return bytes;
  }

  Future<void> _onStartVideo() async {
    var provider = Provider.of<InterviewProvider>(context, listen: false);
    await provider.initCamera();
    setState(() {
      _isRecording = true;
      _recordDuration = Duration.zero;
    });
    _startRecordTimer();
    await provider.startVideoRecording();
  }

  Future<Uint8List> _onStopVideo() async {
    setState(() => _isRecording = false);
    print("onStopVideo called");
    final bytes = await Provider.of<InterviewProvider>(
      context,
      listen: false,
    ).stopVideoRecording();
    print("stop vide recording done");
    // ensure provider state propagated before UI reads it
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _lastMessage = 'Video answer saved');
    try {
      _stopRecordTimer();
    } catch (e) {
      print("Error while stopng record timeer");
    }
    return bytes;
  }

  Future<void> _onPlayAudio() async => Provider.of<InterviewProvider>(
    context,
    listen: false,
  ).playLastRecording();

  Future<void> _onStopPlayAudio() async =>
      Provider.of<InterviewProvider>(context, listen: false).stopLasPlay();

  Future<void> _onPlayVideo() async {
    final provider = Provider.of<InterviewProvider>(context, listen: false);
    final path = await provider.playLastVideo();
    if (path == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Your Video Answer")),
          body: VideoAnswerPlayer(path: path),
        ),
      ),
    );
  }

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
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start submission: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Widget _buildRecorderCard(bool isWide) {
    final interview = context.watch<InterviewProvider>();
    final videoService = context.read<InterviewProvider>().video;

    // recorder area height — fixed box to avoid overflow on mobile
    final recorderHeight = isWide ? 320.0 : 260.0;

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
                child: Icon(
                  _mode == 'video' ? Icons.videocam : Icons.mic,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: Text(
                  _mode == 'video' ? 'Your Video Answer' : 'Your Audio Answer',
                  style: AppTheme.titleLarge,
                ),
              ),
              ToggleButtons(
                isSelected: [_mode == 'audio', _mode == 'video'],
                onPressed: (i) {
                  setState(() {
                    _mode = i == 0 ? 'audio' : 'video';
                    _lastMessage = '';
                  });
                },
                children: const [
                  Padding(padding: EdgeInsets.all(8), child: Text('Audio')),
                  Padding(padding: EdgeInsets.all(8), child: Text('Video')),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space4),

          if (_mode == 'audio')
            AudioRecorder(
              isRecording: _isRecording,
              onStart: _onStartAudio,
              onStop: _onStopAudio,
              onPlay: _onPlayAudio,
              onStopPlay: _onStopPlayAudio,
              deleteRecording: _onDeleteRecording,
              isPlayEnabled: interview.hasRecording,
            ),

          if (_mode == 'video')
            SizedBox(
              height: recorderHeight,
              child:VideoRecorder(
                      service: videoService,
                      isRecording: _isRecording,
                      onStart: _onStartVideo,
                      onStop: _onStopVideo,
                      onPlay: _onPlayVideo,
                      deleteRecording: _onDeleteRecording,
                      isPlayEnabled: interview.hasVideoRecording,
                    )

            ),
          if (_isRecording)
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fiber_manual_record,
                    color: Colors.red,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Text(_recordElapsedStr, style: AppTheme.bodyMedium),
                ],
              ),
            ),

          if (_lastMessage.isNotEmpty) ...[
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
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.success,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.space2),
                  Expanded(
                    child: Text(_lastMessage, style: AppTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final interview = context.watch<InterviewProvider>();
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1100;

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

    if (!_autoPlayed) {
      final tts = context.read<TtsService>();
      tts.speak(currentQ!.question, currentQ.getTtsFile);
      _autoPlayed = true;
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Question ${interview.currentIndex + 1}/${interview.questions.length}',
        ),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space4,
              vertical: AppTheme.space3,
            ),
            child: Column(
              children: [
                ModernProgressBar(progress: progress, height: 8),
                const SizedBox(height: AppTheme.space2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: ${(progress * 100).toInt()}%',
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      QuestionCard(question: currentQ!),
                      const SizedBox(height: 30),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: isWide ? 400 : 240,
                            height: isWide ? 500 : 300,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: _showScroll
                                ? MovieScrollText(
                                    text: currentQ.question,
                                    width: isWide ? 400 : 240,
                                    height: isWide ? 500 : 300,
                                  )
                                : const Center(
                                    child: Text(
                                      "Question Hidden",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                          ),

                          const SizedBox(width: 40),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.visibility),
                                  label: const Text('Listen to Question Again'),
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
                                    setState(() {
                                      _showScroll = !_showScroll;
                                      _autoPlayed = false;
                                    });
                                  },
                                ),
                                const SizedBox(height: 30),
                                _buildRecorderCard(isWide),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Previous'),
                              onPressed: interview.currentIndex > 0
                                  ? interview.previous
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              icon: Icon(
                                interview.currentIndex <
                                        interview.questions.length - 1
                                    ? Icons.arrow_forward
                                    : Icons.check_circle,
                              ),
                              label: Text(
                                interview.currentIndex <
                                        interview.questions.length - 1
                                    ? 'Next Question'
                                    : 'Finish Interview',
                              ),
                              onPressed:
                                  interview.currentIndex <
                                      interview.questions.length - 1
                                  ? () {
                                      setState(() {
                                        _autoPlayed = false;
                                        _showScroll = true;
                                      });
                                      interview.next();
                                    }
                                  : _submitSession,
                            ),
                          ),
                        ],
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
}
