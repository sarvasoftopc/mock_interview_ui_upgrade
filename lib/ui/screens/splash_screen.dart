// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sarvasoft_moc_interview/ui/screens/home_screen_v2.dart';

import '../../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _fadeLogo;
//   late final Animation<double> _fadeText;
//   late final Animation<double> _fadeIcons;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2200),
//     );
//
//     _fadeLogo = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
//     );
//     _fadeText = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
//     );
//     _fadeIcons = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
//     );
//
//     _controller.forward();
//
//     // Delay to ensure splash is visible even if auth check is fast
//     Future.delayed(const Duration(seconds: 3), _navigateNext);
//   }
//
//   Future<void> _navigateNext() async {
//     if (!mounted) return;
//
//     final auth = context.read<AuthProvider>();
//     await auth.loadUser();
//
//     if (!mounted) return;
//
//     if (auth.isLoggedIn) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const HomeScreen()),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   Widget _animatedIconsRow() {
//     final icons = [
//       Icons.mic,
//       Icons.description_outlined,
//       Icons.school,
//       Icons.psychology,
//     ];
//
//     return FadeTransition(
//       opacity: _fadeIcons,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: icons
//             .map(
//               (icon) => Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Icon(
//               icon,
//               color: Colors.indigo.shade600,
//               size: 30,
//             ),
//           ),
//         )
//             .toList(),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isWide = size.width > 800;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Center(
//           child: Stack(
//             children: [
//               Positioned.fill(
//                 child: AnimatedContainer(
//                   duration: const Duration(seconds: 3),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.indigo.shade700,
//                         Colors.indigo.shade400,
//                         Colors.white
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                 ),
//               ),
//               Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     FadeTransition(
//                       opacity: _fadeLogo,
//                       child: Icon(
//                         Icons.auto_awesome,
//                         color: Colors.amber.shade400,
//                         size: isWide ? 100 : 80,
//                       ),
//                     ),
//                     const SizedBox(height: 18),
//                     FadeTransition(
//                       opacity: _fadeText,
//                       child: Column(
//                         children: [
//                           Text(
//                             "IntervueX",
//                             style: TextStyle(
//                               fontSize: isWide ? 48 : 34,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                               letterSpacing: 1.1,
//                               shadows: [
//                                 Shadow(
//                                   color: Colors.black.withOpacity(0.3),
//                                   blurRadius: 6,
//                                   offset: const Offset(0, 2),
//                                 )
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           const Text(
//                             "AI-driven Interview Preparation Suite",
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 16,
//                             ),
//                           ),
//                           const SizedBox(height: 18),
//                           _animatedIconsRow(),
//                           const SizedBox(height: 30),
//                           FadeTransition(
//                             opacity: _fadeIcons,
//                             child: Column(
//                               children: const [
//                                 Text(
//                                   "SarvaSoft (OPC) Private Limited",
//                                   style: TextStyle(
//                                       color: Colors.white70, fontSize: 13),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   "sarvasoft.com",
//                                   style: TextStyle(
//                                       color: Colors.white60,
//                                       fontSize: 13,
//                                       decoration: TextDecoration.underline),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// splash_screen.dart
// Redesigned immersive splash for Capabily.app
// - Keeps the original navigation logic untouched (copied verbatim)
// - Uses the provided logo as an integrated UI element (not just an image)
// - Adds depth: blurred large logo background, circular badge, subtle animations

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeLogo;
  late final Animation<double> _fadeText;
  late final Animation<double> _fadeIcons;
  late final Animation<double> _logoFloat;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _fadeLogo = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _fadeText = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
    );
    _fadeIcons = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _logoFloat = Tween<double>(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.25, 1.0, curve: Curves.easeInOut)),
    );

    _logoScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.55, curve: Curves.elasticOut)),
    );

    _controller.forward();

    // Delay to ensure splash is visible even if auth check is fast
    Future.delayed(const Duration(seconds: 3), _navigateNext);
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    await auth.loadUser();

    if (!mounted) return;

    if (auth.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _animatedIconsRow() {
    final icons = [
      Icons.mic,
      Icons.description_outlined,
      Icons.school,
      Icons.psychology,
    ];

    return FadeTransition(
      opacity: _fadeIcons,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: icons
            .map(
              (icon) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(
              icon,
              color: Colors.indigo.shade600,
              size: 30,
            ),
          ),
        )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              // Layered gradient background
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(seconds: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.indigo.shade800,
                        Colors.indigo.shade400,
                        Colors.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

              // Big blurred logo behind content for immersive effect
              Positioned(
                right: isWide ? -100 : -40,
                top: isWide ? 40 : 12,
                child: SizedBox(
                  width: isWide ? 420 : 260,
                  height: isWide ? 420 : 260,
                  child: Stack(
                    children: [
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                        child: Opacity(
                          opacity: 0.26,
                          child: Image.asset(
                            'assets/images/capabily_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [Colors.transparent, Colors.black.withOpacity(0.06)],
                            radius: 0.9,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main centered content
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated logo badge — integrates the image into a circular badge
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _logoFloat.value),
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: child,
                            ),
                          );
                        },
                        child: _LogoBadge(size: isWide ? 140 : 110),
                      ),

                      const SizedBox(height: 18),

                      FadeTransition(
                        opacity: _fadeText,
                        child: Column(
                          children: [
                            Text(
                              'Capabily',
                              style: TextStyle(
                                fontSize: isWide ? 44 : 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.6,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AI-driven interview coaching for every aspiring candidate',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isWide ? 16 : 14,
                              ),
                            ),

                            const SizedBox(height: 18),

                            _animatedIconsRow(),

                            const SizedBox(height: 24),

                            // Feature chips conveying platform benefits
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: const [
                                _FeatureChip(label: 'Mock Interviews'),
                                _FeatureChip(label: 'Adaptive Difficulty'),
                                _FeatureChip(label: 'Emotion Feedback'),
                                _FeatureChip(label: 'Skill Reports'),
                              ],
                            ),

                            const SizedBox(height: 22),

                            FadeTransition(
                              opacity: _fadeIcons,
                              child: Column(
                                children: const [
                                  Text(
                                    'SarvaSoft (OPC) Private Limited',
                                    style: TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'sarvasoft.com',
                                    style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 13,
                                        decoration: TextDecoration.underline),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top-left subtle branding
              Positioned(
                left: 18,
                top: 18,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 28,
                            width: 28,
                            child: Image.asset('assets/images/capabily_logo.png', fit: BoxFit.contain),
                          ),
                          const SizedBox(width: 8),
                          const Text('capabily.app', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  final double size;
  const _LogoBadge({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 14,
      shape: const CircleBorder(),
      shadowColor: Colors.black45,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.96)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ClipOval(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Image.asset(
                  'assets/images/capabily_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: size * 0.45,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.0), Colors.white.withOpacity(0.06)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  const _FeatureChip({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }
}


