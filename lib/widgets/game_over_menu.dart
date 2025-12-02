import 'package:flutter/material.dart';
import '../ui/retro_ui.dart';

class GameOverMenu extends StatelessWidget {
  final String reason;
  final int score;
  final VoidCallback onReturnToMenu;
  final VoidCallback onRestart;

  const GameOverMenu({
    super.key,
    required this.reason,
    required this.score,
    required this.onReturnToMenu,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final menuWidth = isLandscape ? size.height * 0.7 : 320.0;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Fondo rojo semitransparente para dar sensación de peligro/muerte
          Container(color: const Color(0xFF330000).withOpacity(0.8)),

          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: menuWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TEXTO GAME OVER FLOTANDO FUERA DE LA CAJA
                    Text(
                      'GAME OVER',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.red,
                        letterSpacing: 5,
                        shadows: [
                          Shadow(
                            blurRadius: 0,
                            color: Colors.black,
                            offset: const Offset(4, 4),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CAJA DE REPORTE DE MISIÓN
                    RetroBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "ESTADO DE MISIÓN:",
                            style: getRetroStyle(color: Colors.grey, size: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),

                          Text(
                            reason.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: getRetroStyle(size: 14, color: Colors.white),
                          ),

                          const SizedBox(height: 20),
                          Container(
                            color: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              children: [
                                Text(
                                  "SCORE FINAL",
                                  style: getRetroStyle(
                                    color: Colors.yellow,
                                    size: 12,
                                  ),
                                ),
                                Text(
                                  score.toString().padLeft(
                                    6,
                                    '0',
                                  ), // Estilo arcade 000123
                                  style: const TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.greenAccent,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          RetroButton(text: "REINTENTAR", onPressed: onRestart),

                          RetroButton(
                            text: "SALIR",
                            color: Colors.grey.shade900,
                            onPressed: onReturnToMenu,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
