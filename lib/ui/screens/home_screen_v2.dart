// // home_screen.dart
// // Responsive HomeScreen: separates web (wide) and mobile layouts
// // Keep your existing providers and logic. Replace TODOs with provider calls where necessary.
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// // Import any app-specific widgets you already have.
// // For example: QuestionCard, AudioRecorder, etc.
// // import '../widgets/question_card.dart';
// // import '../widgets/audio_recorder.dart';
//
// // If you created BottomPromoHero in a separate file, import it; else the widget below contains a compact implementation.
//
// // ---------- BEGIN BottomPromoHero (same as we discussed; paste in if you don't have it) ----------
// class BottomPromoHero extends StatefulWidget {
//   final bool defaultExpandedOnWide;
//   const BottomPromoHero({Key? key, this.defaultExpandedOnWide = false}) : super(key: key);
//
//   @override
//   State<BottomPromoHero> createState() => _BottomPromoHeroState();
// }
//
// class _BottomPromoHeroState extends State<BottomPromoHero> with SingleTickerProviderStateMixin {
//   bool _expanded = false;
//   bool _dismissed = false;
//   late final AnimationController _animController;
//
//   @override
//   void initState() {
//     super.initState();
//     _expanded = widget.defaultExpandedOnWide;
//     _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
//     if (_expanded) _animController.value = 1.0;
//   }
//
//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
//   }
//
//   void _track(String event, [Map<String, dynamic>? props]) {
//     try {
//       final analytics = Provider.of<dynamic>(context, listen: false);
//       if (analytics != null) {
//         final fn = analytics.trackEvent ?? analytics.track;
//         if (fn is Function) {
//           fn(event, props ?? {});
//         }
//       }
//     } catch (_) {}
//   }
//
//   bool get _prefersReducedMotion {
//     try {
//       final mq = MediaQuery.maybeOf(context);
//       if (mq != null) return mq.disableAnimations || mq.accessibleNavigation;
//     } catch (_) {}
//     return false;
//   }
//
//   void _onPrimaryCTA() {
//     _track('promo_upgrade_clicked', {'screen': 'home'});
//     Navigator.pushNamed(context, '/pricing');
//   }
//
//   void _onDismissOrToggle(bool isWide) {
//     _track(isWide ? 'promo_dismissed' : (_expanded ? 'promo_collapse' : 'promo_expand'));
//     if (isWide) {
//       setState(() => _dismissed = true);
//     } else {
//       setState(() {
//         _expanded = !_expanded;
//         if (_expanded) _animController.forward();
//         else _animController.reverse();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_dismissed) return const SizedBox.shrink();
//
//     final width = MediaQuery.of(context).size.width;
//     final isWide = width >= 900;
//     final collapsed = !isWide && !_expanded;
//     final prefersReduced = _prefersReducedMotion;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 18.0),
//       child: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 1100),
//           child: AnimatedContainer(
//             duration: prefersReduced ? Duration.zero : const Duration(milliseconds: 300),
//             curve: Curves.easeOutCubic,
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: Colors.indigo.shade600,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: Row(
//                         children: [
//                           Semantics(
//                             label: 'Hero promotion',
//                             child: Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.12),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(Icons.rocket_launch, color: Colors.white, size: 20),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Supercharge your interview prep',
//                                   style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Get AI-reviewed feedback, mock coaching and scoring insights. Try 7 days free.',
//                                   style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 13),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Row(
//                       children: [
//                         Semantics(
//                           button: true,
//                           label: 'Upgrade to premium for coaching',
//                           child: ElevatedButton(
//                             onPressed: _onPrimaryCTA,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.amber.shade600,
//                               foregroundColor: Colors.black87,
//                               padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                             ),
//                             child: const Text('Upgrade'),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         IconButton(
//                           tooltip: isWide ? 'Dismiss promotional card' : (_expanded ? 'Collapse' : 'Expand'),
//                           icon: Icon(isWide ? Icons.close : (collapsed ? Icons.expand_more : Icons.close)),
//                           color: Colors.white,
//                           onPressed: () => _onDismissOrToggle(isWide),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//                 if (!collapsed) ...[
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           'Premium users get personalized feedback and prioritized coaching sessions. Use code LAUNCH for 10% off.',
//                           style: TextStyle(color: Colors.white.withOpacity(0.95)),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Wrap(
//                           spacing: 8,
//                           children: [
//                             OutlinedButton.icon(
//                               onPressed: () {
//                                 _track('promo_learn_more', {'screen': 'home'});
//                                 Navigator.pushNamed(context, '/learn');
//                               },
//                               icon: const Icon(Icons.info_outline, size: 16),
//                               label: const Text('Learn more'),
//                               style: OutlinedButton.styleFrom(
//                                 foregroundColor: Colors.white,
//                                 side: BorderSide(color: Colors.white.withOpacity(0.16)),
//                               ),
//                             ),
//                             TextButton.icon(
//                               onPressed: () {
//                                 _track('promo_try_demo', {'screen': 'home'});
//                                 Navigator.pushNamed(context, '/demo');
//                               },
//                               icon: const Icon(Icons.play_circle_outline, size: 16),
//                               label: const Text('Watch demo'),
//                               style: TextButton.styleFrom(foregroundColor: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   )
//                 ]
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// // ---------- END BottomPromoHero ----------
//
// // ---------- BEGIN HomeScreen ----------
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   // Helper UI: compact stat box (used in hero)
//   Widget _compactStat(String title, String value) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.indigo.shade700.withOpacity(0.18),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
//           const SizedBox(height: 4),
//           Text(title, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
//         ],
//       ),
//     );
//   }
//
//   // TODO: Replace these stub methods with your real provider actions
//   Future<void> _onTryMockInterview(BuildContext context) async {
//     try {
//       // Example: context.read<InterviewProvider>().startMockInterview();
//       // Replace with your actual action
//       Navigator.pushNamed(context, '/question'); // placeholder
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to start mock interview: $e')));
//     }
//   }
//
//   Future<void> _onUploadCv(BuildContext context) async {
//     try {
//       // TODO: wire to your upload logic
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload CV flow (placeholder)')));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload CV failed: $e')));
//     }
//   }
//
//   Future<void> _onUploadJd(BuildContext context) async {
//     try {
//       // TODO: wire to your upload JD logic
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload JD flow (placeholder)')));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload JD failed: $e')));
//     }
//   }
//
//   Future<void> _onPerformCvJdAnalysis(BuildContext context) async {
//     try {
//       // TODO: wire to your provider submit / analysis method
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Performing analysis (placeholder)')));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Analysis failed: $e')));
//     }
//   }
//
//   // Small reusable card for feature tiles
//   Widget _featureCard({required Color start, required Color end, required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(colors: [start, end], begin: Alignment.topLeft, end: Alignment.bottomRight),
//           borderRadius: BorderRadius.circular(14),
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 6))],
//         ),
//         padding: const EdgeInsets.all(18),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             CircleAvatar(backgroundColor: Colors.white.withOpacity(0.15), child: Icon(icon, color: Colors.white)),
//             const SizedBox(height: 16),
//             Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 6),
//             Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.95))),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // --- Web/Large layout ---
//   Widget _buildWebHomeView(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // hero row: left text + right visual box
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // left hero text
//               Expanded(
//                 flex: 2,
//                 child: Container(
//                   padding: const EdgeInsets.all(28),
//                   decoration: BoxDecoration(
//                     color: Colors.indigo.shade700,
//                     borderRadius: BorderRadius.circular(14),
//                     boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Prepare smarter. Interview better.', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 12),
//                       Text('AI-driven mock interviews, CV↔JD analysis, personalized coaching — all in one place.\nDesigned for candidates and teams.', style: TextStyle(color: Colors.white.withOpacity(0.92))),
//                       const SizedBox(height: 18),
//                       Row(
//                         children: [
//                           ElevatedButton.icon(
//                             icon: const Icon(Icons.play_arrow_rounded),
//                             label: const Text('Try a Mock Interview'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.amber.shade600,
//                               foregroundColor: Colors.black87,
//                               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                             ),
//                             onPressed: () => _onTryMockInterview(context),
//                           ),
//                           const SizedBox(width: 12),
//                           OutlinedButton.icon(
//                             icon: const Icon(Icons.upload_file_outlined),
//                             label: const Text('Upload CV / JD'),
//                             style: OutlinedButton.styleFrom(
//                               foregroundColor: Colors.white,
//                               side: BorderSide(color: Colors.white.withOpacity(0.18)),
//                               padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                             ),
//                             onPressed: () => _onUploadCv(context),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 18),
//                       // stats wrap
//                       Wrap(spacing: 12, runSpacing: 12, children: [
//                         _compactStat('Avg. score ↑', '18%'),
//                         _compactStat('Practice attempts', '1.2K'),
//                         _compactStat('Satisfied users', '4.8/5'),
//                       ]),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 24),
//               // right visual box
//               Expanded(
//                 flex: 1,
//                 child: Container(
//                   height: 280,
//                   decoration: BoxDecoration(
//                     color: Colors.indigo.shade600,
//                     borderRadius: BorderRadius.circular(14),
//                     boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
//                   ),
//                   child: const Center(child: Icon(Icons.laptop_mac, color: Colors.white70, size: 64)),
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 22),
//
//           // CV + JD Analysis + Right quick actions (web two-column)
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // left analysis card
//               Expanded(
//                 flex: 2,
//                 child: Card(
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   color: Colors.indigo.shade600,
//                   child: Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       Row(children: const [
//                         Icon(Icons.insert_chart_outlined, color: Colors.white),
//                         SizedBox(width: 12),
//                         Text('CV + JD Analysis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
//                       ]),
//                       const SizedBox(height: 12),
//                       Text('Upload your CV & JD together and run skill match analysis with tailored questions.', style: TextStyle(color: Colors.white.withOpacity(0.9))),
//                       const SizedBox(height: 14),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: () => _onUploadCv(context),
//                               icon: const Icon(Icons.file_upload_outlined),
//                               label: const Text('Upload CV'),
//                               style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.indigo),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: () => _onUploadJd(context),
//                               icon: const Icon(Icons.workspace_premium_outlined),
//                               label: const Text('Upload JD'),
//                               style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.indigo),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 14),
//                       ElevatedButton.icon(
//                         onPressed: () => _onPerformCvJdAnalysis(context),
//                         icon: const Icon(Icons.play_circle_outline),
//                         label: const Text('Perform Analysis'),
//                         style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade400, foregroundColor: Colors.white),
//                       ),
//                     ]),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(width: 18),
//
//               // right quick actions
//               Expanded(
//                 flex: 1,
//                 child: Column(
//                   children: [
//                     Card(
//                       child: ListTile(
//                         leading: const CircleAvatar(child: Icon(Icons.flash_on)),
//                         title: const Text('One-click Practice'),
//                         subtitle: const Text('Start a short mock interview based on your CV skills'),
//                         trailing: const Icon(Icons.chevron_right),
//                         onTap: () => Navigator.pushNamed(context, '/quick-practice'),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Card(
//                       child: ListTile(
//                         leading: const CircleAvatar(child: Icon(Icons.bookmark_outline)),
//                         title: const Text('STAR Stories'),
//                         subtitle: const Text('Save and reuse your behavioral examples'),
//                         trailing: const Icon(Icons.chevron_right),
//                         onTap: () => Navigator.pushNamed(context, '/star-stories'),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Card(
//                       child: ListTile(
//                         leading: const CircleAvatar(child: Icon(Icons.psychology)),
//                         title: const Text('Career Coach'),
//                         subtitle: const Text('Personalized tips and next steps'),
//                         trailing: const Icon(Icons.chevron_right),
//                         onTap: () => Navigator.pushNamed(context, '/career-coach'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 28),
//
//           // Explore feature tiles (3 columns on wide)
//           const Text('Explore Features', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 12),
//           GridView.count(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             crossAxisCount: 3,
//             childAspectRatio: 1.4,
//             crossAxisSpacing: 14,
//             mainAxisSpacing: 14,
//             children: [
//               _featureCard(start: Colors.pink.shade400, end: Colors.pink.shade300, title: 'Practice & Improve', subtitle: 'Sharpen skills using CV, JD, or select from skill list', icon: Icons.school, onTap: () => Navigator.pushNamed(context, '/practice')),
//               _featureCard(start: Colors.purple.shade400, end: Colors.purple.shade300, title: 'Simulate Interview', subtitle: 'Simulated interview with AI-generated questions', icon: Icons.rocket, onTap: () => Navigator.pushNamed(context, '/simulate')),
//               _featureCard(start: Colors.orange.shade400, end: Colors.orange.shade300, title: 'Stress Simulator', subtitle: 'Timed interviews to build resilience', icon: Icons.timer, onTap: () => Navigator.pushNamed(context, '/stress')),
//             ],
//           ),
//
//           const SizedBox(height: 28),
//
//           // Why choose us card + links + hero promo
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(18.0),
//               child: Column(
//                 children: [
//                   const Align(alignment: Alignment.centerLeft, child: Text('Why choose us?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
//                   const SizedBox(height: 12),
//                   Text('AI-powered simulations, tailored feedback, safe practice environment, and measurable progress.'),
//                   const SizedBox(height: 12),
//                   Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                     TextButton(onPressed: () => Navigator.pushNamed(context, '/settings'), child: const Text('Settings')),
//                     TextButton(onPressed: () => Navigator.pushNamed(context, '/reports'), child: const Text('Reports')),
//                     TextButton(onPressed: () => Navigator.pushNamed(context, '/resume-builder'), child: const Text('Resume Builder')),
//                   ])
//                 ],
//               ),
//             ),
//           ),
//
//           const BottomPromoHero(),
//         ],
//       ),
//     );
//   }
//
//   // --- Mobile layout ---
//   Widget _buildMobileHomeView(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//         // Compact hero card
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.indigo.shade700,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
//           ),
//           padding: const EdgeInsets.all(20),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             const Text('Prepare smarter.\nInterview better.', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             Text('AI-driven mock interviews, CV↔JD analysis, personalized coaching — all in one place.', style: TextStyle(color: Colors.white.withOpacity(0.95))),
//             const SizedBox(height: 14),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.play_arrow_rounded),
//               label: const Text('Try a Mock Interview'),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade600, foregroundColor: Colors.black87),
//               onPressed: () => _onTryMockInterview(context),
//             ),
//             const SizedBox(height: 8),
//             OutlinedButton.icon(
//               icon: const Icon(Icons.upload_file),
//               label: const Text('Upload CV / JD'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 side: BorderSide(color: Colors.white.withOpacity(0.16)),
//               ),
//               onPressed: () => _onUploadCv(context),
//             ),
//             const SizedBox(height: 12),
//             Wrap(spacing: 8, runSpacing: 8, children: [
//               _compactStat('Avg. score ↑', '18%'),
//               _compactStat('Practice attempts', '1.2K'),
//               _compactStat('Satisfied users', '4.8/5'),
//             ]),
//           ]),
//         ),
//
//         const SizedBox(height: 18),
//
//         // CV + JD Analysis compact card
//         Card(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//               Row(children: const [
//                 Icon(Icons.insert_chart_outlined, color: Colors.indigo),
//                 SizedBox(width: 12),
//                 Text('CV + JD Analysis', style: TextStyle(fontWeight: FontWeight.bold)),
//               ]),
//               const SizedBox(height: 12),
//               Text('Upload your CV & JD together and run skill match analysis with tailored questions.', style: TextStyle(color: Colors.black.withOpacity(0.7))),
//               const SizedBox(height: 12),
//               Row(children: [
//                 Expanded(child: ElevatedButton.icon(onPressed: () => _onUploadCv(context), icon: const Icon(Icons.file_upload_outlined), label: const Text('Upload CV'))),
//                 const SizedBox(width: 10),
//                 Expanded(child: ElevatedButton.icon(onPressed: () => _onUploadJd(context), icon: const Icon(Icons.work_outline), label: const Text('Upload JD'))),
//               ]),
//               const SizedBox(height: 8),
//               ElevatedButton.icon(onPressed: () => _onPerformCvJdAnalysis(context), icon: const Icon(Icons.play_circle_outline), label: const Text('Perform Analysis')),
//             ]),
//           ),
//         ),
//
//         const SizedBox(height: 18),
//
//         // Explore features: column stacked
//         const Text('Explore Features', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 12),
//         Column(children: [
//           _featureCard(start: Colors.pink.shade400, end: Colors.pink.shade300, title: 'Practice & Improve', subtitle: 'Sharpen skills using CV, JD, or select from skill list', icon: Icons.school, onTap: () => Navigator.pushNamed(context, '/practice')),
//           const SizedBox(height: 12),
//           _featureCard(start: Colors.purple.shade400, end: Colors.purple.shade300, title: 'Simulate Interview', subtitle: 'Simulated interview with AI-generated questions', icon: Icons.rocket, onTap: () => Navigator.pushNamed(context, '/simulate')),
//           const SizedBox(height: 12),
//           _featureCard(start: Colors.orange.shade400, end: Colors.orange.shade300, title: 'Stress Simulator', subtitle: 'Timed interviews to build resilience', icon: Icons.timer, onTap: () => Navigator.pushNamed(context, '/stress')),
//         ]),
//
//         const SizedBox(height: 18),
//
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
//               const Text('Why choose us?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text('AI-powered simulations, tailored feedback, safe practice environment, and measurable progress.'),
//               const SizedBox(height: 12),
//               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//                 TextButton(onPressed: () => Navigator.pushNamed(context, '/settings'), child: const Text('Settings')),
//                 TextButton(onPressed: () => Navigator.pushNamed(context, '/reports'), child: const Text('Reports')),
//                 TextButton(onPressed: () => Navigator.pushNamed(context, '/resume-builder'), child: const Text('Resume Builder')),
//               ])
//             ]),
//           ),
//         ),
//
//         const SizedBox(height: 18),
//         const BottomPromoHero(),
//       ]),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       final isWide = constraints.maxWidth >= 900;
//       return Scaffold(
//         backgroundColor: Colors.grey.shade50,
//         appBar: AppBar(
//           title: const Text('AI Interview Prep'),
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black87,
//           elevation: 0,
//           actions: [
//             IconButton(onPressed: () => Navigator.pushNamed(context, '/language'), icon: const Icon(Icons.language)),
//             IconButton(onPressed: () => Navigator.pushNamed(context, '/settings'), icon: const Icon(Icons.settings)),
//           ],
//         ),
//         body: isWide ? _buildWebHomeView(context) : _buildMobileHomeView(context),
//         // Keep your bottom nav / FAB as before
//         bottomNavigationBar: BottomAppBar(
//           color: Colors.white,
//           elevation: 6,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//             child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
//               _NavItem(icon: Icons.home, label: 'Home', onTap: () => Navigator.pushReplacementNamed(context, '/home')),
//               _NavItem(icon: Icons.bar_chart, label: 'Reports', onTap: () => Navigator.pushNamed(context, '/reports')),
//               _NavItem(icon: Icons.school, label: 'Learn', onTap: () => Navigator.pushNamed(context, '/learn')),
//               _NavItem(icon: Icons.history, label: 'History', onTap: () => Navigator.pushNamed(context, '/sessions')),
//             ]),
//           ),
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//         floatingActionButton: Semantics(
//           label: 'Get Started',
//           child: FloatingActionButton.extended(
//             onPressed: () => Navigator.pushNamed(context, '/get-started'),
//             icon: const Icon(Icons.rocket_launch),
//             label: const Text('Get Started'),
//             backgroundColor: Colors.indigo.shade700,
//           ),
//         ),
//       );
//     });
//   }
// }
//
// class _NavItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//   const _NavItem({required this.icon, required this.label, required this.onTap});
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 12))]));
//   }
// }
