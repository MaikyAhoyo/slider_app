import 'package:flutter/material.dart';
import '../ui/retro_ui.dart';
import 'leaderboard_menu.dart';

class GameOverMenu extends StatelessWidget {
  final String reason;
  final int score;
  final VoidCallback onReturnToMenu;
  final VoidCallback onRestart;
  final bool isHighScore;
  final String playerName;

  const GameOverMenu({
    super.key,
    required this.reason,
    required this.score,
    required this.onReturnToMenu,
    required this.onRestart,
    required this.isHighScore,
    required this.playerName,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: const Color(0xFF330000).withOpacity(0.85)),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'GAME OVER',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: isLandscape ? 36 : 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.red,
                              letterSpacing: 5,
                              shadows: const [
                                Shadow(
                                  blurRadius: 0,
                                  color: Colors.black,
                                  offset: Offset(4, 4),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 20),

                          RetroBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  "ESTADO DE MISIÓN:",
                                  style: getRetroStyle(
                                    color: Colors.grey,
                                    size: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),

                                Text(
                                  reason.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: getRetroStyle(
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Container(
                                  color: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 10,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "SCORE FINAL",
                                        style: getRetroStyle(
                                          color: Colors.yellow,
                                          size: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        score.toString().padLeft(6, '0'),
                                        style: const TextStyle(
                                          fontFamily: 'Courier',
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.greenAccent,
                                          letterSpacing: 3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                LeaderboardWidget(
                                  currentScore: score,
                                  playerName: playerName,
                                  isNewHighScore: isHighScore,
                                ),

                                const SizedBox(height: 20),

                                RetroButton(
                                  text: "REINTENTAR",
                                  onPressed: onRestart,
                                  color: Colors.green.shade800,
                                ),

                                const SizedBox(height: 8),

                                RetroButton(
                                  text: "SALIR",
                                  color: Colors.red.shade900,
                                  onPressed: onReturnToMenu,
                                ),
                              ],
                            ),
                          ),
                        ],
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
