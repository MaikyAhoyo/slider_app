import 'package:flutter/material.dart';

// COLORES ESTILO FF7 / PS1
const Color kRetroBlueTop = Color(0xFF0000AA);
const Color kRetroBlueBottom = Color(0xFF000022);
const Color kRetroBorderHighlight = Color(0xFFEEEEEE);
const Color kRetroBorderShadow = Color(0xFF111111);

// 1. EL CONTENEDOR CLÁSICO (Dialog Box)
class RetroBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  const RetroBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: kRetroBorderShadow,
        boxShadow: [
          BoxShadow(color: Colors.black54, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: const BorderSide(color: kRetroBorderHighlight, width: 2),
            left: const BorderSide(color: kRetroBorderHighlight, width: 2),
            right: const BorderSide(color: Colors.grey, width: 2),
            bottom: const BorderSide(color: Colors.grey, width: 2),
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kRetroBlueTop, kRetroBlueBottom],
          ),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

// 2. EL BOTÓN RETRO
class RetroButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  const RetroButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: color ?? Colors.black, // Si no hay color, es negro
          border: Border.all(color: Colors.white54, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_right, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              text.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Courier',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. TEXTO RETRO ESTÁNDAR
TextStyle getRetroStyle({double size = 16, Color color = Colors.white}) {
  return TextStyle(
    fontFamily: 'Courier',
    color: color,
    fontSize: size,
    fontWeight: FontWeight.bold,
    shadows: const [
      Shadow(offset: Offset(2, 2), color: Colors.black, blurRadius: 0),
    ],
  );
}

// 4. VENTANA RETRO CON CABECERA
class RetroWindow extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onClose;
  final Widget child;
  final double? width;
  final double? height;

  const RetroWindow({
    super.key,
    required this.title,
    required this.icon,
    this.onClose,
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return RetroBox(
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              Text(
                title.toUpperCase(),
                style: getRetroStyle(size: 24, color: Colors.yellowAccent),
              ),
              if (onClose != null)
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      color: Colors.red,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 5),
          const Divider(color: Colors.white, thickness: 2),
          const SizedBox(height: 10),

          Flexible(child: child),
        ],
      ),
    );
  }
}
