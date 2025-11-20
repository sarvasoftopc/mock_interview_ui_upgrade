// pages/adaptive_interview_page.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/local_turn.dart';
import '../../providers/adaptive_session_provider.dart';
import '../../providers/interview_provider.dart';
import '../../providers/session_provider.dart';
import '../../services/tts_service.dart';
import '../widgets/audio_recorder.dart';
import '../widgets/question_card.dart';


// pages/adaptive_interview_page.dart
//NEW UI V1
// class AdaptiveInterviewPage extends StatefulWidget {
//   const AdaptiveInterviewPage({super.key});
//
//   @override
//   State<AdaptiveInterviewPage> createState() => _AdaptiveInterviewPageState();
// }
//
// class _AdaptiveInterviewPageState extends State<AdaptiveInterviewPage> {
//   bool _isRecording = false;
//   bool _endSessionChecked = false;
//   bool _sending = false;
//   String _lastMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapStart());
//   }
//
//   Future<void> _bootstrapStart() async {
//     final startPayload =
//     ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//     if (startPayload == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Missing start payload for session')),
//       );
//       return;
//     }
//
//     final adaptive = context.read<AdaptiveSessionProvider>();
//     final interviewProvider = context.read<InterviewProvider>();
//     try {
//       await adaptive.startSession(startPayload, interviewProvider);
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Failed to start session: $e')));
//     }
//   }
//
//   Future<void> _sendAnswer() async {
//     setState(() => _sending = true);
//     final interview = context.read<InterviewProvider>();
//     final provider = context.read<AdaptiveSessionProvider>();
//
//     final bytes = interview.lastRecordingBytes;
//     if (bytes == null || bytes.isEmpty) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text('No recording to send')));
//       setState(() => _sending = false);
//       return;
//     }
//
//     try {
//       await provider.uploadAudioAndSend(
//         audioBytes: bytes,
//         endSession: _endSessionChecked,
//       );
//     } catch (_) {
//     } finally {
//       interview.clearLastRecording();
//       setState(() => _sending = false);
//     }
//   }
//
//   Future<void> _onDeleteRecording() async {
//     final provider = Provider.of<InterviewProvider>(context, listen: false);
//     final deleted = await provider.deleteRecording();
//     setState(() => _lastMessage = 'Recording deleted');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           deleted ? 'Recording deleted successfully' : 'No recording to delete',
//         ),
//       ),
//     );
//   }
//
//   Future<void> _onStart() async {
//     setState(() => _isRecording = true);
//     await Provider.of<InterviewProvider>(context, listen: false)
//         .startAnswerRecording();
//   }
//
//   Future<Uint8List> _onStop() async {
//     setState(() => _isRecording = false);
//     await Provider.of<InterviewProvider>(context, listen: false)
//         .stopAnswerRecording();
//     setState(() => _lastMessage = 'Answer recorded');
//     return Uint8List(0);
//   }
//
//   Future<void> _onPlay() async =>
//       Provider.of<InterviewProvider>(context, listen: false)
//           .playLastRecording();
//
//   Future<void> _onStopPlay() async =>
//       Provider.of<InterviewProvider>(context, listen: false).stopLasPlay();
//
//   // Small recorder card - keeps question / recording UI separate and compact.
//   Widget _buildRecorderCard(bool isWide) {
//     final interview = context.watch<InterviewProvider>();
//
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.mic, size: 28, color: Colors.indigo),
//                 const SizedBox(width: 12),
//                 const Expanded(
//                   child: Text(
//                     'Your Answer',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Row(children: [
//                   Checkbox(
//                       value: _endSessionChecked,
//                       onChanged: (v) => setState(() => _endSessionChecked = v ?? false)),
//                   const Text('End session after this answer'),
//                   const SizedBox(width: 8),
//                   if (!isWide)
//                     IconButton(
//                       onPressed: interview.hasRecording && !_sending ? _sendAnswer : null,
//                       icon: const Icon(Icons.send_rounded),
//                       tooltip: 'Send Answer',
//                     ),
//                 ]),
//               ],
//             ),
//             const SizedBox(height: 12),
//             AudioRecorder(
//               isRecording: _isRecording,
//               onStart: _onStart,
//               onStop: _onStop,
//               onPlay: _onPlay,
//               onStopPlay: _onStopPlay,
//               deleteRecording: _onDeleteRecording,
//               isPlayEnabled: interview.hasRecording,
//             ),
//             const SizedBox(height: 10),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 _lastMessage,
//                 style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
//               ),
//             ),
//             const SizedBox(height: 8),
//             // action row for navigation
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.arrow_back),
//                     label: const Text('Previous'),
//                     onPressed: interview.currentIndex > 0 ? interview.previous : null,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.indigo.shade50,
//                       foregroundColor: Colors.indigo.shade800,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 // keep space for additional compact controls if needed
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Bounded feedback panel — ALWAYS has a finite height so layout remains stable.
//   Widget _buildFeedbackPanel(BoxConstraints constraints, AdaptiveSessionProvider provider, bool isWide) {
//     // Compute reasonable panel height:
//     final double feedbackBoxHeight = isWide
//         ? (constraints.maxHeight * 0.42).clamp(240.0, 720.0)
//         : 220.0;
//
//     return SizedBox(
//       height: feedbackBoxHeight,
//       child: Card(
//         elevation: 1,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Row(
//                 children: [
//                   const Expanded(
//                     child: Text('Recent Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
//                   ),
//                   if (!isWide)
//                     IconButton(
//                       icon: const Icon(Icons.open_in_new),
//                       tooltip: 'Open full feedback',
//                       onPressed: () {
//                         // show full feedback modal to avoid re-layout issues
//                         showModalBottomSheet(
//                           context: context,
//                           isScrollControlled: true,
//                           builder: (ctx) => FractionallySizedBox(
//                             heightFactor: 0.9,
//                             child: Scaffold(
//                               appBar: AppBar(title: const Text('All Feedback')),
//                               body: provider.historicalTurnFeedbacks.isEmpty
//                                   ? const Center(child: Text('No feedback yet'))
//                                   : ListView.separated(
//                                 itemCount: provider.historicalTurnFeedbacks.length,
//                                 separatorBuilder: (_, __) => const Divider(),
//                                 itemBuilder: (c, i) =>
//                                     _feedbackTile(provider.historicalTurnFeedbacks[i]),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               // bounded list area inside SizedBox: safe to use Expanded here
//               Expanded(
//                 child: provider.historicalTurnFeedbacks.isEmpty
//                     ? const Center(child: Text('No feedback yet'))
//                     : ListView.separated(
//                   itemCount: provider.historicalTurnFeedbacks.length,
//                   separatorBuilder: (_, __) => const Divider(height: 1),
//                   itemBuilder: (ctx, idx) {
//                     final f = provider.historicalTurnFeedbacks[idx];
//                     return _feedbackTile(f);
//                   },
//                 ),
//               ),
//               const SizedBox(height: 8),
//               if (provider.finalSummary != null || provider.finalScore != null)
//                 Container(
//                   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       if (provider.finalScore != null)
//                         Text(
//                           'Final Score: ${(provider.finalScore! * 100).toStringAsFixed(0)} / 100',
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                         ),
//                       if (provider.finalSummary != null) ...[
//                         const SizedBox(height: 6),
//                         ...provider.finalSummary!.entries.map((e) => Text('${e.key}: ${e.value}')),
//                       ],
//                       const SizedBox(height: 8),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: ElevatedButton(
//                           onPressed: () => Navigator.pop(context),
//                           child: const Text('Done'),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _feedbackTile(LocalTurn f) {
//     return ListTile(
//       title: Text('Q${f.currentTurn}: ${f.interviewQuestion.getQuestion}'),
//       subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (f.answerFeedback?.score != null)
//               Text('Score: ${(f.answerFeedback!.score! * 100).toStringAsFixed(0)} / 100'),
//             if (f.answerFeedback?.rationale != null)
//               Text('Feedback: ${f.answerFeedback!.rationale}'),
//             if (f.answerFeedback?.modelAnswer != null)
//               Text('Model: ${f.answerFeedback!.modelAnswer}'),
//             if (f.answerFeedback?.candidateAnswer != null)
//               Text('Candidate Answer: ${f.answerFeedback!.candidateAnswer}'),
//           ]),
//     );
//   }
//
//   Widget _buildQuestionOrStatus(AdaptiveSessionProvider adaptive) {
//     if (_sending) {
//       return Card(
//         color: Colors.blue.shade50,
//         clipBehavior: Clip.antiAlias,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         child: const Padding(
//           padding: EdgeInsets.all(12.0),
//           child: Row(
//             children: [
//               SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   'Processing your answer… Please wait.',
//                   style: TextStyle(fontSize: 16),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     final currentQ = adaptive.currentTurn?.interviewQuestion.getQuestion;
//     if (currentQ == null || currentQ.isEmpty) {
//       return Row(
//         key: const ValueKey('waiting_question'),
//         children: const [
//           Flexible(child: Text('Waiting for question', style: TextStyle(fontSize: 16))),
//           SizedBox(width: 8),
//           _AnimatedDots(),
//         ],
//       );
//     }
//
//     return ConstrainedBox(
//       constraints: const BoxConstraints(minWidth: 0, maxWidth: double.infinity),
//       child: SelectableText(
//         currentQ,
//         style: const TextStyle(fontSize: 16),
//         textAlign: TextAlign.start,
//         // these were in your original code - keep wrapping behavior:
//         minLines: 1,
//         maxLines: null,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<AdaptiveSessionProvider>();
//     final interview = context.read<InterviewProvider>();
//     final q = provider.currentTurn?.currentInterviewQuestion;
//
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         title: const Text('Adaptive Interview'),
//         backgroundColor: Colors.indigo.shade600,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.send_rounded),
//             tooltip: 'Submit Answer',
//             onPressed: interview.hasRecording && !_sending ? _sendAnswer : null,
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: q == null
//             ? AnimatedSwitcher(
//               duration: const Duration(milliseconds: 300),
//               transitionBuilder:
//                   (child, anim) => FadeTransition(
//                 opacity: anim,
//                 child: child,
//               ),
//               child: _buildQuestionOrStatus(provider),
//             )
//             : LayoutBuilder(builder: (context, constraints) {
//           final width = constraints.maxWidth;
//           final isWide = width >= 900;
//           final horizontalPadding = isWide ? 40.0 : 12.0;
//           final verticalPadding = isWide ? 18.0 : 12.0;
//
//           return SingleChildScrollView(
//             padding:
//             EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Top row or single column depending on width
//                 if (isWide)
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Left column (question + controls)
//                       Expanded(
//                         flex: 2,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [
//                             Card(
//                               elevation: 4,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(14)),
//                               shadowColor: Colors.indigo.withOpacity(0.12),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(20.0),
//                                 child: QuestionCard(question: q, highlighted: true),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             Wrap(
//                               spacing: 12,
//                               runSpacing: 8,
//                               crossAxisAlignment: WrapCrossAlignment.center,
//                               children: [
//                                 SizedBox(
//                                   width: isWide ? (width * 0.45) : double.infinity,
//                                   child: ElevatedButton.icon(
//                                     icon: const Icon(Icons.volume_up_rounded),
//                                     label: const Text('Listen to Question'),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.indigo.shade600,
//                                       padding: const EdgeInsets.symmetric(vertical: 14),
//                                       shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.circular(10)),
//                                     ),
//                                     onPressed: () {
//                                       final tts = context.read<TtsService>();
//                                       tts.speak(q.question, q.ttsFile);
//                                     },
//                                   ),
//                                 ),
//                                 OutlinedButton.icon(
//                                   onPressed: interview.hasRecording && !_sending ? _sendAnswer : null,
//                                   icon: const Icon(Icons.send_rounded),
//                                   label: const Text('Submit'),
//                                   style: OutlinedButton.styleFrom(
//                                     padding:
//                                     const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(10)),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//                             Consumer<InterviewProvider>(
//                               builder: (context, interview, _) {
//                                 return Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       'Question ${interview.currentIndex + 1} of ${interview.questions.length}',
//                                       style:
//                                       const TextStyle(fontSize: 13, color: Colors.black54),
//                                     ),
//                                     Text(
//                                       interview.hasRecording ? 'Recording available' : 'No recording yet',
//                                       style: TextStyle(
//                                         fontSize: 13,
//                                         color: interview.hasRecording
//                                             ? Colors.green.shade700
//                                             : Colors.black45,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               },
//                             ),
//                             const SizedBox(height: 16),
//                             Card(
//                               elevation: 0,
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12)),
//                               color: Colors.white,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(12.0),
//                                 child: Row(
//                                   children: [
//                                     const Icon(Icons.info_outline, color: Colors.indigo),
//                                     const SizedBox(width: 8),
//                                     Expanded(
//                                       child: Text(
//                                         'Tip: Speak clearly and treat this like a real interview. You can re-record before moving to next question.',
//                                         style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             // Recorder card stays in left column for wide screens,
//                             // but you can move it to right if desired.
//                             _buildRecorderCard(true),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(width: 24),
//
//                       // Right column: bounded feedback + small session controls
//                       Flexible(
//                         flex: 1,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [
//                             _buildFeedbackPanel(constraints, provider, isWide),
//                             const SizedBox(height: 16),
//                             Card(
//                               elevation: 1,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     const Text('Session Controls', style: TextStyle(fontWeight: FontWeight.w700)),
//                                     const SizedBox(height: 8),
//                                     ElevatedButton.icon(
//                                       onPressed: interview.hasRecording && !_sending ? _sendAnswer : null,
//                                       icon: const Icon(Icons.cloud_upload),
//                                       label: const Text('Submit Answer'),
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: Colors.indigo.shade600,
//                                         foregroundColor: Colors.white,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8)
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   )
//                 else
//                 // Narrow screen: stack vertically with bounded feedback panel below
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       Card(
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                         shadowColor: Colors.indigo.withOpacity(0.12),
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: QuestionCard(question: q, highlighted: true),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       ElevatedButton.icon(
//                         icon: const Icon(Icons.volume_up_rounded),
//                         label: const Text('Listen to Question'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.indigo.shade600,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                         ),
//                         onPressed: () {
//                           final tts = context.read<TtsService>();
//                           tts.speak(q.question, q.ttsFile);
//                         },
//                       ),
//                       const SizedBox(height: 12),
//                       _buildRecorderCard(false),
//                       const SizedBox(height: 12),
//                       Card(
//                         elevation: 1,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               OutlinedButton.icon(
//                                 onPressed: _onDeleteRecording,
//                                 icon: const Icon(Icons.delete_outline),
//                                 label: const Text('Delete Last Recording'),
//                               ),
//                               const SizedBox(height: 8),
//                               ElevatedButton.icon(
//                                 onPressed: interview.hasRecording && !_sending ? _sendAnswer : null,
//                                 icon: const Icon(Icons.cloud_upload),
//                                 label: const Text('Submit Session'),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.indigo.shade600,
//                                   foregroundColor: Colors.white,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       // Bounded feedback panel for narrow screens
//                       _buildFeedbackPanel(constraints, provider, isWide),
//                     ],
//                   ),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
//
// class _AnimatedDots extends StatefulWidget {
//   const _AnimatedDots({super.key});
//
//   @override
//   State<_AnimatedDots> createState() => _AnimatedDotsState();
// }
//
// class _AnimatedDotsState extends State<_AnimatedDots> with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<int> _dotsCount;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(duration: const Duration(milliseconds: 900), vsync: this)
//       ..repeat();
//     _dotsCount = IntTween(begin: 0, end: 3).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _dotsCount,
//       builder: (_, __) {
//         final dots = '.' * _dotsCount.value;
//         return Text(dots, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
//       },
//     );
//   }
// }


// pages/adaptive_interview_page.dart
//NEW UI V1 (updated layout & small mobile fixes)
class AdaptiveInterviewPage extends StatefulWidget {
  const AdaptiveInterviewPage({super.key});

  @override
  State<AdaptiveInterviewPage> createState() => _AdaptiveInterviewPageState();
}

class _AdaptiveInterviewPageState extends State<AdaptiveInterviewPage> {
  bool _isRecording = false;
  bool _endSessionChecked = false;
  bool _sending = false;
  String _lastMessage = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapStart());
  }

  // add to _AdaptiveInterviewPageState
  bool _processingOpen = false;
  final ValueNotifier<String> _processingLabel = ValueNotifier<String>('Processing…');

  void _showProcessing(String label) {
    if (!mounted) return;
    _processingLabel.value = label;

    if (_processingOpen) return; // already visible
    _processingOpen = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Processing',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, _, __) {
        return WillPopScope(
          onWillPop: () async => false, // block back while processing
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                        width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 12),
                    Flexible(
                      child: ValueListenableBuilder<String>(
                        valueListenable: _processingLabel,
                        builder: (_, text, __) => Text(
                          text,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _hideProcessing() {
    if (!mounted) return;
    if (_processingOpen) {
      _processingOpen = false;
      Navigator.of(context, rootNavigator: true).pop(); // close dialog
    }
  }


  void _onAdaptiveChanged() {
    final provider = context.read<AdaptiveSessionProvider>();
    final status = provider.currentTurn?.status;

    // 1) Processing states -> show/update modal
    if (status == TurnStatus.processing ||
        status == TurnStatus.uploading ||
        status == TurnStatus.uploaded) {
      final label = status == TurnStatus.uploading
          ? 'Uploading your answer…'
          : status == TurnStatus.uploaded
          ? 'Answer uploaded. Finalizing…'
          : 'Processing your answer…';
      _showProcessing(label);
      return; // nothing else for now
    }

    // 2) Processed -> hide modal
    if (status == TurnStatus.processed) {
      _hideProcessing();
      return;
    }

    // 3) Session completed: show message and navigate (once)
    if (status == TurnStatus.session_completed && !provider.navigateToSessions) {
      _hideProcessing(); // ensure no dialog remains
      provider.navigatedToSessions = true;

      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(const SnackBar(
        content: Text('Session submission started — report will appear shortly.'),
        duration: Duration(seconds: 2),
      ));

      // navigate cleanly after current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/sessions');
      });
    }
  }


  @override
  void dispose() {
    final provider = context.read<AdaptiveSessionProvider>();
    provider.removeListener(_onAdaptiveChanged);
    super.dispose();
  }

  Future<void> _bootstrapStart() async {
    final startPayload =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (startPayload == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing start payload for session')),
      );
      return;
    }

    final adaptive = context.read<AdaptiveSessionProvider>();
    final provider = Provider.of<InterviewProvider>(context, listen: false);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);

    try {
      await adaptive.startSession(startPayload,provider,sessionProvider);
      adaptive.addListener(_onAdaptiveChanged);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to start session: $e')));
    }
  }

  Future<void> _sendAnswer() async {
    setState(() => _sending = true);
    final provider = Provider.of<AdaptiveSessionProvider>(context, listen: false);

    final bytes = provider.lastRecording;
    if (bytes == null || bytes.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No recording to send')));
      setState(() => _sending = false);
      return;
    }

    try {
      await provider.uploadAudioAndSend(
        audioBytes: bytes,
        endSession: _endSessionChecked,
      );
    } catch (_) {
    } finally {
      setState(() => _sending = false);
    }
  }

  Future<void> _onDeleteRecording() async {
    final provider = Provider.of<AdaptiveSessionProvider>(context, listen: false);
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
    await Provider.of<AdaptiveSessionProvider>(context, listen: false)
        .startAnswerRecording();
  }

  Future<Uint8List> _onStop() async {
    setState(() => _isRecording = false);
   var localPath = await Provider.of<AdaptiveSessionProvider>(context, listen: false).stopAnswerRecording();
    setState(() => _lastMessage = 'Answer recorded');
    return Uint8List(0);
  }

  Future<void> _onPlay() async =>
      Provider.of<AdaptiveSessionProvider>(context, listen: false)
          .playLastRecording();

  Future<void> _onStopPlay() async =>
      Provider.of<AdaptiveSessionProvider>(context, listen: false).stopLasPlay();

  // Small recorder card - keeps question / recording UI separate and compact.
  Widget _buildRecorderCard(bool isWide) {
    final interview = Provider.of<AdaptiveSessionProvider>(context, listen: false);

    // For narrow screens we stack the checkbox + send button below the main row to avoid overflow.
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Main row: mic icon + title + optional send action (for wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.mic, size: 28, color: Colors.indigo),
                const SizedBox(width: 12),
                // The title should be flexible to avoid overflow
                const Expanded(
                  child: Text(
                    'Your Answer',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                // For wide screens show checkbox and inline send icon
                if (isWide)
                  Row(children: [
                    Checkbox(
                        value: _endSessionChecked,
                        onChanged: (v) =>
                            setState(() => _endSessionChecked = v ?? false)),
                    const SizedBox(width: 4),
                    const Text('End session after this answer'),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed:
                      interview.hasRecording && !_sending ? _sendAnswer : null,
                      icon: const Icon(Icons.send_rounded),
                      tooltip: 'Send Answer',
                    ),
                  ]),
              ],
            ),
            // For narrow screens place the checkbox + send button on a separate row to prevent overflow
            if (!isWide)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                        value: _endSessionChecked,
                        onChanged: (v) =>
                            setState(() => _endSessionChecked = v ?? false)),
                    const SizedBox(width: 4),
                    Expanded(child: const Text('End session after this answer')),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed:
                      interview.hasRecording && !_sending ? _sendAnswer : null,
                      icon: const Icon(Icons.send_rounded),
                      tooltip: 'Send Answer',
                    ),
                  ],
                ),
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
            // action row for navigation (removed Previous button as requested)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // kept placeholder space so layout looks balanced (no Previous button)
                const SizedBox.shrink(),
                // Keep room for potential compact controls later (no visible button to avoid overflow)
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Bounded feedback panel — ALWAYS has a finite height so layout remains stable.
  Widget _buildFeedbackPanel(
      BoxConstraints constraints, AdaptiveSessionProvider provider, bool isWide) {
    // Compute reasonable panel height:
    final double feedbackBoxHeight = isWide
        ? (constraints.maxHeight * 0.42).clamp(240.0, 720.0)
        : 220.0;

    return SizedBox(
      height: feedbackBoxHeight,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child:
                    Text('Recent Feedback', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  // only show "open full feedback" action on wide layouts to avoid mobile arrow clutter
                  if (isWide)
                    IconButton(
                      icon: const Icon(Icons.open_in_new),
                      tooltip: 'Open full feedback',
                      onPressed: () {
                        // show full feedback modal to avoid re-layout issues
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (ctx) => FractionallySizedBox(
                            heightFactor: 0.9,
                            child: Scaffold(
                              appBar: AppBar(title: const Text('All Feedback')),
                              body: provider.historicalTurnFeedbacks.isEmpty
                                  ? const Center(child: Text('No feedback yet'))
                                  : ListView.separated(
                                itemCount: provider.historicalTurnFeedbacks.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (c, i) =>
                                    _feedbackTile(provider.historicalTurnFeedbacks[i]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // bounded list area inside SizedBox: safe to use Expanded here
              Expanded(
                child: provider.historicalTurnFeedbacks.isEmpty
                    ? const Center(child: Text('No feedback yet'))
                    : ListView.separated(
                  itemCount: provider.historicalTurnFeedbacks.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, idx) {
                    final f = provider.historicalTurnFeedbacks[idx];
                    return _feedbackTile(f);
                  },
                ),
              ),
              const SizedBox(height: 8),
              // if (provider.finalSummary != null || provider.finalScore != null)
              //   Container(
              //     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              //     decoration: BoxDecoration(
              //       color: Colors.green.shade50,
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.stretch,
              //       children: [
              //         if (provider.finalScore != null)
              //           Text(
              //             'Final Score: ${(provider.finalScore! * 100).toStringAsFixed(0)} / 100',
              //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              //           ),
              //         if (provider.finalSummary != null) ...[
              //           const SizedBox(height: 6),
              //           ...provider.finalSummary!.entries.map((e) => Text('${e.key}: ${e.value}')),
              //         ],
              //         const SizedBox(height: 8),
              //         Align(
              //           alignment: Alignment.centerRight,
              //           child: ElevatedButton(
              //             onPressed: () => Navigator.pop(context),
              //             child: const Text('Done'),
              //           ),
              //         )
              //       ],
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feedbackTile(LocalTurn f) {
    return ListTile(
      title: Text('Q${f.currentTurn}: ${f.interviewQuestion.getQuestion}'),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (f.answerFeedback?.score != null)
          Text('Score: ${(f.answerFeedback!.score! * 100).toStringAsFixed(0)} / 100'),
        if (f.answerFeedback?.rationale != null)
          Text('Feedback: ${f.answerFeedback!.rationale}'),
        if (f.answerFeedback?.modelAnswer != null)
          Text('Model: ${f.answerFeedback!.modelAnswer}'),
        if (f.answerFeedback?.candidateAnswer != null)
          Text('Candidate Answer: ${f.answerFeedback!.candidateAnswer}'),
      ]),
    );
  }

  Widget _buildQuestionOrStatus(AdaptiveSessionProvider adaptive) {
    if (_sending) {
      return Card(
        color: Colors.blue.shade50,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            children: [
              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Processing your answer… Please wait.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentQ = adaptive.currentTurn?.interviewQuestion.getQuestion;
    final status = adaptive.currentTurn?.status;
    if (currentQ == null || currentQ.isEmpty || status == TurnStatus.pending) {
      return Row(
        key: const ValueKey('waiting_question'),
        children: const [
          Flexible(child: Text('Waiting for question', style: TextStyle(fontSize: 16))),
          SizedBox(width: 8),
          _AnimatedDots(),
        ],
      );
    }



    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 0, maxWidth: double.infinity),
      child: SelectableText(
        currentQ,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.start,
        // these were in your original code - keep wrapping behavior:
        minLines: 1,
        maxLines: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final interview = context.watch<AdaptiveSessionProvider>();


    final q = interview.currentTurn?.currentInterviewQuestion;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Adaptive Interview'),
        backgroundColor: Colors.indigo.shade600,
        actions: [
          IconButton(
            icon: const Icon(Icons.send_rounded),
            tooltip: 'Submit Answer',
            onPressed: interview.hasRecording && !_sending ? _sendAnswer : null,
          ),
        ],
      ),
      body: SafeArea(
        child: q == null
            ? AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: child,
          ),
          child: _buildQuestionOrStatus(interview),
        )
            : LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isWide = width >= 900;
          final horizontalPadding = isWide ? 40.0 : 12.0;
          final verticalPadding = isWide ? 18.0 : 12.0;

          return SingleChildScrollView(
            padding:
            EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top row or single column depending on width
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column (question + controls)
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              shadowColor: Colors.indigo.withOpacity(0.12),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: QuestionCard(question: q, highlighted: true),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                SizedBox(
                                  width: isWide ? (width * 0.45) : double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.volume_up_rounded),
                                    label: const Text('Listen to Question'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo.shade600,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () {
                                      final tts = context.read<TtsService>();
                                      tts.speak(q.question, q.ttsFile);
                                    },
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed:
                                  interview.hasRecording && !_sending ? _sendAnswer : null,
                                  icon: const Icon(Icons.send_rounded),
                                  label: const Text('Submit'),
                                  style: OutlinedButton.styleFrom(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Consumer<AdaptiveSessionProvider>(
                              builder: (context, interview, _) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Question ${interview.currentTurn!.currentTurn + 1} of ${interview.currentTurn?.interviewQuestion.getQuestion.length}',
                                      style: const TextStyle(fontSize: 13, color: Colors.black54),
                                    ),
                                    Text(
                                      interview.hasRecording ? 'Recording available' : 'No recording yet',
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
                            Card(
                              elevation: 0,
                              shape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline, color: Colors.indigo),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Tip: Speak clearly and treat this like a real interview. You can re-record before moving to next question.',
                                        style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Recorder card stays in left column for wide screens,
                            _buildRecorderCard(true),
                          ],
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Right column: bounded feedback + small session controls
                      Flexible(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildFeedbackPanel(constraints, interview, isWide),
                            const SizedBox(height: 16),
                            Card(
                              elevation: 1,
                              shape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Session Controls',
                                        style: TextStyle(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: interview.hasRecording && !_sending ? _sendAnswer : null,
                                      icon: const Icon(Icons.cloud_upload),
                                      label: const Text('Submit Answer'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo.shade600,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8)
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
                // Narrow screen: stack vertically with bounded feedback panel below
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        shadowColor: Colors.indigo.withOpacity(0.12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: QuestionCard(question: q, highlighted: true),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.volume_up_rounded),
                        label: const Text('Listen to Question'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _onDeleteRecording,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Delete Last Recording'),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: interview.hasRecording && !_sending ? _sendAnswer : null,
                                icon: const Icon(Icons.cloud_upload),
                                label: const Text('Submit Answer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo.shade600,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bounded feedback panel for narrow screens
                      _buildFeedbackPanel(constraints, interview, isWide),
                    ],
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots({super.key});

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _dotsCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 900), vsync: this)
      ..repeat();
    _dotsCount = IntTween(begin: 0, end: 3).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotsCount,
      builder: (_, __) {
        final dots = '.' * _dotsCount.value;
        return Text(dots, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));
      },
    );
  }
}

