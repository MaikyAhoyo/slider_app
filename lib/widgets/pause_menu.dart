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
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.7)),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isLandscape =
                        MediaQuery.of(context).orientation ==
                        Orientation.landscape;
                    final double menuWidth = isLandscape ? 500 : 320;

                    return ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: menuWidth),
                      child: RetroWindow(
                        title: 'PAUSA',
                        icon: Icons.pause_circle_filled,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            RetroButton(
                              text: "CONTINUAR",
                              onPressed: onResume,
                              color: const Color(0xFF00AA00),
                            ),

                            const SizedBox(height: 10),

                            RetroButton(
                              text: "REINICIAR",
                              onPressed: onRestart,
                            ),

                            const SizedBox(height: 10),

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
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
