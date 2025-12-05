import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../ui/retro_ui.dart';

class LeaderboardWidget extends StatefulWidget {
  final int currentScore;
  final String playerName;
  final bool isNewHighScore;

  const LeaderboardWidget({
    super.key,
    required this.currentScore,
    required this.playerName,
    this.isNewHighScore = false,
  });

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  final SupabaseService _supabase = SupabaseService();

  List<Map<String, dynamic>> _topPlayers = [];
  int _myRank = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final tops = await _supabase.getLeaderboard(limit: 5);
    final rank = await _supabase.getPlayerRank(widget.currentScore);

    if (mounted) {
      setState(() {
        _topPlayers = tops;
        _myRank = rank;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: Colors.greenAccent),
        ),
      );
    }

    return RetroBox(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events,
                color: Colors.yellowAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "TOP RACERS",
                style: getRetroStyle(size: 18, color: Colors.yellowAccent),
              ),
            ],
          ),
          const Divider(color: Colors.white54, thickness: 1),

          if (widget.isNewHighScore)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(4),
              color: Colors.green.withOpacity(0.2),
              child: Text(
                "¡NUEVO RECORD PERSONAL!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

          ..._topPlayers.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final name = data['player_name'] ?? '???';
            final points = data['points'] ?? 0;
            final isMe = name == widget.playerName;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 25,
                    child: Text(
                      "#${index + 1}",
                      style: getRetroStyle(
                        color: index == 0 ? Colors.yellow : Colors.grey,
                        size: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      name,
                      style: getRetroStyle(
                        color: isMe ? Colors.greenAccent : Colors.white,
                        size: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    points.toString().padLeft(6, '0'),
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const Divider(color: Colors.white24, thickness: 1),

          if (_myRank > 5)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "TU POSICIÓN GLOBAL: ",
                    style: getRetroStyle(size: 12, color: Colors.grey),
                  ),
                  Text(
                    "#$_myRank",
                    style: getRetroStyle(size: 14, color: Colors.cyanAccent),
                  ),
                ],
              ),
            )
          else
            Text(
              "¡ERES UNA LEYENDA!",
              textAlign: TextAlign.center,
              style: getRetroStyle(size: 10, color: Colors.orangeAccent),
            ),
        ],
      ),
    );
  }
}
