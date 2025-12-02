import 'package:flutter/material.dart';
import '../ui/retro_ui.dart';

class PauseMenu extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;
  final VoidCallback onSettings;

  const PauseMenu({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    // Ancho del menú ajustado al estilo retro
    final menuWidth = isLandscape ? size.height * 0.7 : 300.0;

    return Stack(
      children: [
        // 1. Fondo Oscuro (Sin Blur, estilo PS1 pausa simple)
        Container(color: Colors.black.withOpacity(0.7)),

        // 2. Patrón de líneas opcional (Scanlines falsas)
        IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.5, 0.5],
                colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
                tileMode: TileMode.repeated,
              ),
            ),
          ),
        ),

        Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: menuWidth),
              child: RetroBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TÍTULO CON SOMBRA DURA
                    Text(
                      'PAUSA',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.blue.shade900,
                            offset: const Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),
                    const Divider(color: Colors.white54, thickness: 2),
                    const SizedBox(height: 20),

                    // BOTONES RETRO
                    RetroButton(
                      text: "CONTINUAR",
                      onPressed: onResume,
                      // Sin color específico para usar el default (negro/borde blanco)
                    ),

                    RetroButton(text: "REINICIAR", onPressed: onRestart),

                    RetroButton(text: "AJUSTES", onPressed: onSettings),

                    const SizedBox(height: 15),
                    const Divider(color: Colors.white24, thickness: 1),
                    const SizedBox(height: 10),

                    // BOTÓN SALIR (Rojo)
                    RetroButton(
                      text: "SALIR AL MENU",
                      color: const Color(0xFFAA0000), // Rojo oscuro
                      onPressed: onQuit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
