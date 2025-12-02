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

    final menuWidth = isLandscape ? size.height * 0.7 : 300.0;

    return Stack(
      children: [
        Container(color: Colors.black.withOpacity(0.7)),

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
              child: RetroWindow(
                title: 'PAUSA',
                icon: Icons.pause_circle_filled,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // BOTONES RETRO
                    RetroButton(text: "CONTINUAR", onPressed: onResume),

                    RetroButton(text: "REINICIAR", onPressed: onRestart),

                    RetroButton(text: "AJUSTES", onPressed: onSettings),

                    const SizedBox(height: 15),
                    const Divider(color: Colors.white24, thickness: 1),
                    const SizedBox(height: 10),

                    // BOTÓN SALIR (Rojo)
                    RetroButton(
                      text: "SALIR AL MENU",
                      color: const Color(0xFFAA0000),
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
