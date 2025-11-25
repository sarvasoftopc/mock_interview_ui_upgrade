import 'package:flutter/material.dart';

class MovieScrollText extends StatefulWidget {
  final String text;
  final double width;
  final double height;

  const MovieScrollText({
    super.key,
    required this.text,
    required this.width,
    required this.height,
  });

  @override
  State<MovieScrollText> createState() => _MovieScrollTextState();
}

class _MovieScrollTextState extends State<MovieScrollText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 14),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.height,
      end: -800,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant MovieScrollText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, __) {
          return Transform.translate(
            offset: Offset(0, _animation.value),
            child: SizedBox(
              width: widget.width,
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                  color: Colors.yellowAccent,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
