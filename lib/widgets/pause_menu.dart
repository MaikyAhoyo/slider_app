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
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    // En landscape, usar altura como referencia para el ancho
    final menuWidth = orientation == Orientation.landscape
        ? size.height *
              0.5 // 50% de la altura en horizontal
        : 320.0; // Ancho fijo en vertical

    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(color: Colors.black.withOpacity(0.6)),
        ),

        Center(
          child: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: menuWidth,
                  constraints: BoxConstraints(
                    maxWidth: size.width * 0.9,
                    maxHeight: size.height * 0.85,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: orientation == Orientation.landscape ? 20 : 35,
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
                      Text(
                        'PAUSA',
                        style: TextStyle(
                          fontSize: orientation == Orientation.landscape
                              ? 24
                              : 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 5,
                          shadows: const [
                            Shadow(
                              blurRadius: 15,
                              color: Colors.blueAccent,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: orientation == Orientation.landscape ? 20 : 35,
                      ),

                      _buildNeonButton(
                        label: 'CONTINUAR',
                        icon: Icons.play_arrow_rounded,
                        color: const Color(0xFF00E676),
                        onPressed: onResume,
                        isLandscape: orientation == Orientation.landscape,
                      ),

                      SizedBox(
                        height: orientation == Orientation.landscape ? 10 : 15,
                      ),

                      _buildNeonButton(
                        label: 'REINICIAR',
                        icon: Icons.refresh_rounded,
                        color: const Color(0xFFFF9100),
                        onPressed: onRestart,
                        isLandscape: orientation == Orientation.landscape,
                      ),

                      SizedBox(
                        height: orientation == Orientation.landscape ? 10 : 15,
                      ),

                      _buildNeonButton(
                        label: 'AJUSTES',
                        icon: Icons.settings_rounded,
                        color: Colors.blueAccent.shade400,
                        onPressed: onSettings,
                        isLandscape: orientation == Orientation.landscape,
                      ),

                      SizedBox(
                        height: orientation == Orientation.landscape ? 15 : 25,
                      ),

                      Divider(
                        color: Colors.white.withOpacity(0.1),
                        thickness: 1,
                      ),

                      SizedBox(
                        height: orientation == Orientation.landscape ? 8 : 10,
                      ),

                      TextButton.icon(
                        onPressed: onQuit,
                        icon: const Icon(
                          Icons.exit_to_app_rounded,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        label: Text(
                          'Salir al Menú',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: orientation == Orientation.landscape
                                ? 14
                                : 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: orientation == Orientation.landscape
                                ? 8
                                : 12,
                          ),
                        ),
                      ),
                    ],
                  ),
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
    bool isLandscape = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: color.withOpacity(0.2),
              foregroundColor: color,
              padding: EdgeInsets.symmetric(vertical: isLandscape ? 12 : 16),
              elevation: 0,
              side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              shadowColor: color.withOpacity(0.4),
            ).copyWith(
              overlayColor: MaterialStateProperty.resolveWith(
                (states) => color.withOpacity(0.1),
              ),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isLandscape ? 20 : 24),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isLandscape ? 14 : 16,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
