import 'dart:ui';
import 'package:flutter/material.dart';

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
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.black.withOpacity(0.6)),
        ),

        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                width: 320,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 35,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'PAUSA',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 5,
                        shadows: [
                          Shadow(
                            blurRadius: 15,
                            color: Colors.blueAccent,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),

                    _buildNeonButton(
                      label: 'CONTINUAR',
                      icon: Icons.play_arrow_rounded,
                      color: const Color(0xFF00E676),
                      onPressed: onResume,
                    ),

                    const SizedBox(height: 15),

                    _buildNeonButton(
                      label: 'REINICIAR',
                      icon: Icons.refresh_rounded,
                      color: const Color(0xFFFF9100),
                      onPressed: onRestart,
                    ),

                    const SizedBox(height: 15),

                    _buildNeonButton(
                      label: 'AJUSTES',
                      icon: Icons.settings_rounded,
                      color: Colors.blueAccent.shade400,
                      onPressed: onSettings,
                    ),

                    const SizedBox(height: 25),

                    Divider(color: Colors.white.withOpacity(0.1), thickness: 1),

                    const SizedBox(height: 10),

                    TextButton.icon(
                      onPressed: onQuit,
                      icon: const Icon(
                        Icons.exit_to_app_rounded,
                        color: Colors.redAccent,
                      ),
                      label: const Text(
                        'Salir al Menú',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
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

  Widget _buildNeonButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: color.withOpacity(
                0.2,
              ), // Fondo semitransparente del color
              foregroundColor: color, // Color del texto e icono
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              side: BorderSide(
                color: color.withOpacity(0.5),
                width: 1.5,
              ), // Borde neón
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              shadowColor: color.withOpacity(0.4),
            ).copyWith(
              // Efecto al presionar
              overlayColor: MaterialStateProperty.resolveWith(
                (states) => color.withOpacity(0.1),
              ),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
