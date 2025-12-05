import 'package:flutter/material.dart';

class ComboBanner extends StatefulWidget {
  final String text;
  final VoidCallback onAnimationComplete;

  const ComboBanner({
    super.key,
    required this.text,
    required this.onAnimationComplete,
  });

  @override
  State<ComboBanner> createState() => _ComboBannerState();
}

class _ComboBannerState extends State<ComboBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Un poco más rápido que el milestone
    );

    // Efecto de "pop" elástico
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.5).chain(CurveTween(curve: Curves.easeOutBack)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);
    
    // Ligera rotación para darle dinamismo
    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.yellowAccent, Colors.redAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40, // Texto grande
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Courier', // O tu fuente retro preferida
                    color: Colors.white, // Necesario para que el ShaderMask funcione
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black,
                        offset: Offset(5.0, 5.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}