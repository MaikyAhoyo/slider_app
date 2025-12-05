import 'package:flutter/material.dart';

class PulsingVignette extends StatefulWidget {
  final Color color;

  const PulsingVignette({
    super.key,
    required this.color,
  });

  @override
  State<PulsingVignette> createState() => _PulsingVignetteState();
}

class _PulsingVignetteState extends State<PulsingVignette>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true); // Pulsar continuamente

    // Ajusté un poco la opacidad para que no sea tan invasiva
    _opacityAnimation = Tween<double>(begin: 0.1, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2, // Radio un poco más grande para que sea sutil en el centro
                colors: [
                  Colors.transparent,
                  widget.color.withOpacity(_opacityAnimation.value),
                ],
                stops: const [0.4, 1.0], // El centro es transparente hasta el 40%
              ),
            ),
          ),
        );
      },
    );
  }
}