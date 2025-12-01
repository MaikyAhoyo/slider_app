import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:audioplayers/audioplayers.dart';
import 'services/supabase_service.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String playerName = "Jugador";
  final TextEditingController _controller = TextEditingController();

  late final SupabaseService _supabaseService;
  String _selectedCarAsset = 'assets/cars/orange_car.png';
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService();
    _controller.text = playerName;
    _signIn();
    _playMenuMusic();
  }

  Future<void> _signIn() async {
    await _supabaseService.signIn(
      email: dotenv.env['AUTH_EMAIL']!,
      password: dotenv.env['AUTH_PASSWORD']!,
    );
  }

  /// Función para reproducir la música en bucle con manejo de errores
  Future<void> _playMenuMusic() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('music/menu_theme.mp3'));
      debugPrint("🎵 Música iniciada correctamente");
    } catch (e) {
      debugPrint("❌ ERROR DE AUDIO: No se pudo reproducir la música.");
      debugPrint("Detalles del error: $e");
    }
  }

  /// Detiene la música (se llama al salir del menú)
  Future<void> _stopMenuMusic() async {
    await _audioPlayer.stop();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _changeName() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cambiar Nombre"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: "Tu nombre"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                playerName = _controller.text.isNotEmpty
                    ? _controller.text
                    : "Player";
              });
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // --- Función para abrir Configuración ---
  void _openSettings() async {
    final newCar = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SettingsScreen(currentCarAsset: _selectedCarAsset),
      ),
    );

    // Cuando volvemos de Configuración, comprobamos si se seleccionó un coche
    if (newCar != null && newCar is String) {
      setState(() {
        _selectedCarAsset = newCar;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo con imagen de carro
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/backgrounds/menu_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay con oscurecido
          Container(color: Colors.black.withOpacity(0.4)),

          // Contenido
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TÍTULO CON NEÓN
                Text(
                  "CAR RACERS",
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        blurRadius: 25,
                        color: Colors.blueAccent.shade400,
                        offset: const Offset(0, 0),
                      ),
                      Shadow(
                        blurRadius: 40,
                        color: Colors.redAccent.shade400,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // PANEL DE VIDRIO (glassmorphism)
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      width: 280,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Jugador: $playerName",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),

                          const SizedBox(height: 12),

                          ElevatedButton(
                            onPressed: _changeName,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white70,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text("Cambiar Nombre"),
                          ),

                          const SizedBox(height: 30),

                          // BOTÓN PLAY GRANDE
                          ElevatedButton(
                            onPressed: () async {
                              await _stopMenuMusic();
                              if (context.mounted) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GameScreen(
                                      playerName: playerName,
                                      supabaseService: _supabaseService,
                                      carAssetPath: _selectedCarAsset,
                                    ),
                                  ),
                                );
                              }
                              _playMenuMusic();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "JUGAR",
                              style: TextStyle(fontSize: 24),
                            ),
                          ),

                          const SizedBox(height: 15),

                          TextButton(
                            onPressed: _openSettings,
                            child: const Text(
                              "Configuración",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
