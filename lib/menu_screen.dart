import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/supabase_service.dart';
import 'services/audio_manager.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'styles_screen.dart';

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
  final AudioManager _audioManager = AudioManager.instance;

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
    await _audioManager.playMusic('menu_theme');
  }

  /// Detiene la música (se llama al salir del menú)
  Future<void> _stopMenuMusic() async {
    await _audioManager.stopMusic();
  }

  @override
  void dispose() {
    // No disponemos el AudioManager aquí porque es un singleton global
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
                    : "Jugador";
              });
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // --- Función para abrir Estilos ---
  void _openStyles() async {
    final newCar = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StylesScreen(currentCarAsset: _selectedCarAsset),
      ),
    );

    // Cuando volvemos de Estilos, comprobamos si se seleccionó un coche
    if (newCar != null && newCar is String) {
      setState(() {
        _selectedCarAsset = newCar;
      });
    }
  }

  // --- Función para abrir Configuración ---
  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  // ... (Tus imports y variables de estado siguen igual) ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. IMAGEN DE FONDO
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/backgrounds/menu_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. DEGRADADO
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.4, 0.7, 1.0],
              ),
            ),
          ),

          // 3. CONTENIDO SEGURO (SafeArea)
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape =
                    constraints.maxWidth > constraints.maxHeight;

                if (isLandscape) {
                  // --- LAYOUT HORIZONTAL (LANDSCAPE) ---
                  return Row(
                    children: [
                      // Izquierda: Título y Espacio
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: Text(
                            "CAR\nRACERS",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 48,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                              height: 0.9,
                              shadows: [
                                Shadow(
                                  blurRadius: 20,
                                  color: Colors.blueAccent.shade700,
                                  offset: const Offset(0, 0),
                                ),
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.redAccent.shade700,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Derecha: Panel de Control
                      Expanded(
                        flex: 5,
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 40),
                              child: _buildControlPanel(isLandscape: true),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // --- LAYOUT VERTICAL (PORTRAIT) ---
                  return Column(
                    children: [
                      const SizedBox(height: 20),

                      // TÍTULO
                      Text(
                        "CAR RACERS",
                        style: TextStyle(
                          fontSize: 48,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              blurRadius: 20,
                              color: Colors.blueAccent.shade700,
                              offset: const Offset(0, 0),
                            ),
                            Shadow(
                              blurRadius: 10,
                              color: Colors.redAccent.shade700,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // PANEL DE CONTROL
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        child: _buildControlPanel(isLandscape: false),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel({required bool isLandscape}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(25),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. FILA DE JUGADOR
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    playerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                    onPressed: _changeName,
                    tooltip: "Cambiar nombre",
                  ),
                ],
              ),

              SizedBox(height: isLandscape ? 10 : 20),

              // 2. BOTÓN JUGAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                    backgroundColor: const Color(0xFFFF3B30),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isLandscape ? 15 : 20,
                    ),
                    elevation: 10,
                    shadowColor: Colors.redAccent.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "JUGAR",
                    style: TextStyle(
                      fontSize: isLandscape ? 22 : 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

              SizedBox(height: isLandscape ? 15 : 25),

              // 3. BOTONES SECUNDARIOS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMenuButton(
                    icon: Icons.palette_outlined,
                    label: "Estilos",
                    onPressed: _openStyles,
                  ),
                  Container(height: 20, width: 1, color: Colors.white24),
                  _buildMenuButton(
                    icon: Icons.settings_outlined,
                    label: "Ajustes",
                    onPressed: _openSettings,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 28),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
