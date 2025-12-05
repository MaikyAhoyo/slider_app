import 'package:flutter/material.dart';

class FloatingText extends StatefulWidget {
  final String text;
  final Color color;
  final Offset startPosition;
  final VoidCallback onAnimationComplete;

  const FloatingText({
    super.key,
    required this.text,
    required this.color,
    required this.startPosition,
    required this.onAnimationComplete,
  });

  @override
  State<FloatingText> createState() => _FloatingTextState();
}

class _FloatingTextState extends State<FloatingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.startPosition - const Offset(0, 100), // Sube 100 pixeles
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) => widget.onAnimationComplete());
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
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.color,
                shadows: const [
                  Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 2)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}