import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final String reason;
  final int score;
  final VoidCallback onReturnToMenu;

  const GameOverDialog({
    super.key,
    required this.reason,
    required this.score,
    required this.onReturnToMenu,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¡Juego Terminado!'),
      content: Text('$reason\nPuntuación final: $score'),
      actions: [
        TextButton(
          child: const Text('Volver al Menú'),
          onPressed: () {
            Navigator.of(context).pop(); // Cerrar diálogo
            onReturnToMenu();            // Acción externa
          },
        ),
      ],
    );
  }
}
