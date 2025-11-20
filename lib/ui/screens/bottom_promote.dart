// place this widget as the last child inside your main Column within SingleChildScrollView
import 'dart:ui' as ui; // for reduced motion check

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // used only for optional analytics hook

/// Responsive, collapsible promo hero for QuestionScreen.
/// - Collapsed on narrow screens by default (user can expand).
/// - Dismissible on wide screens (keeps UI tidy).
/// - Adds semantics labels for accessibility.
/// - Attempts to send analytics if an Analytics provider is present (non-fatal).
class BottomPromoHero extends StatefulWidget {
  final bool defaultExpandedOnWide;
  const BottomPromoHero({Key? key, this.defaultExpandedOnWide = false}) : super(key: key);

  @override
  State<BottomPromoHero> createState() => _BottomPromoHeroState();
}

class _BottomPromoHeroState extends State<BottomPromoHero> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _dismissed = false;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _expanded = widget.defaultExpandedOnWide;
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    if (_expanded) _animController.value = 1.0;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Non-fatal analytics call: tries to call provider if available.
  void _track(String event, [Map<String, dynamic>? props]) {
    try {
      // attempt to find an analytics provider in the widget tree
      final analytics = Provider.of<dynamic>(context, listen: false);
      // if it has a trackEvent method (duck-typing)
      if (analytics != null) {
        final fn = analytics.trackEvent ?? analytics.track; // try common names
        if (fn is Function) {
          fn(event, props ?? {});
        }
      }
    } catch (_) {
      // no analytics provider, ignore silently
    }
  }

  bool get _prefersReducedMotion {
    // MediaQueryData.disableAnimations or platform-level reduce motion
    // Use MediaQuery if available; fall back to platform-level preference.
    try {
      final mq = MediaQuery.maybeOf(context);
      if (mq != null) return mq.disableAnimations || mq.accessibleNavigation;
    } catch (_) {}
    // Fallback: platform dispatcher preference if available (some versions)
    try {
      return ui.window.platformDispatcher.platformBrightness == ui.Brightness.dark && false;
    } catch (_) {}
    return false;
  }

  void _onPrimaryCTA() {
    _track('promo_upgrade_clicked', {'screen': 'question'});
    Navigator.pushNamed(context, '/pricing');
  }

  void _onDismissOrToggle(bool isWide) {
    _track(isWide ? 'promo_dismissed' : (_expanded ? 'promo_collapse' : 'promo_expand'));
    if (isWide) {
      setState(() => _dismissed = true);
    } else {
      setState(() {
        _expanded = !_expanded;
        if (_expanded) _animController.forward();
        else _animController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;
    final collapsed = !isWide && !_expanded;
    final prefersReduced = _prefersReducedMotion;

    // Animated container for smooth expansion/collapse (respects reduced motion)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: AnimatedContainer(
            duration: prefersReduced ? Duration.zero : const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.indigo.shade600,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: content + actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon + text
                    Expanded(
                      child: Row(
                        children: [
                          Semantics(
                            label: 'Hero promotion',
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.rocket_launch, color: Colors.white, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Supercharge your interview prep',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Get AI-reviewed feedback, mock coaching and scoring insights. Try 7 days free.',
                                  style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        Semantics(
                          button: true,
                          label: 'Upgrade to premium for coaching',
                          child: ElevatedButton(
                            onPressed: _onPrimaryCTA,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade600,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Upgrade'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: isWide ? 'Dismiss promotional card' : (_expanded ? 'Collapse' : 'Expand'),
                          icon: Icon(isWide ? Icons.close : (collapsed ? Icons.expand_more : Icons.close)),
                          color: Colors.white,
                          onPressed: () => _onDismissOrToggle(isWide),
                        ),
                      ],
                    )
                  ],
                ),

                // extra content only when expanded or on wide screens
                if (!collapsed) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Premium users get personalized feedback and prioritized coaching sessions. Use code LAUNCH for 10% off.',
                          style: TextStyle(color: Colors.white.withOpacity(0.95)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                _track('promo_learn_more', {'screen': 'question'});
                                Navigator.pushNamed(context, '/learn');
                              },
                              icon: const Icon(Icons.info_outline, size: 16),
                              label: const Text('Learn more'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white.withOpacity(0.16)),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                _track('promo_try_demo', {'screen': 'question'});
                                Navigator.pushNamed(context, '/demo');
                              },
                              icon: const Icon(Icons.play_circle_outline, size: 16),
                              label: const Text('Watch demo'),
                              style: TextButton.styleFrom(foregroundColor: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
