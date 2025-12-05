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
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.5,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

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
              child: Stack(
                children: [
                  Transform.translate(
                    offset: const Offset(4, 4),
                    child: Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Courier',
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(2, 2),
                    child: Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Courier',
                        fontStyle: FontStyle.italic,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ),
                  Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Courier',
                      fontStyle: FontStyle.italic,
                      color: Colors.yellowAccent,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
