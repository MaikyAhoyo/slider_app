import 'package:flutter/material.dart';

class ScreenFlash extends StatefulWidget {
  final Color color;
  final VoidCallback onComplete;

  const ScreenFlash({
    super.key,
    this.color = Colors.red,
    required this.onComplete,
  });

  @override
  State<ScreenFlash> createState() => _ScreenFlashState();
}

class _ScreenFlashState extends State<ScreenFlash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.5), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.0), weight: 80),
    ]).animate(_controller);

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return IgnorePointer(
          child: Container(
            color: widget.color.withOpacity(_opacity.value),
          ),
        );
      },
    );
  }
}