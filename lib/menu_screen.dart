import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:slider_app/backgrounds_screen.dart';
import 'services/supabase_service.dart';
import 'services/audio_manager.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'cars_screen.dart';
import 'ui/retro_ui.dart';
import 'services/storage_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final StorageService _storage = StorageService();
  String playerName = "Jugador";
  final TextEditingController _controller = TextEditingController();

  late final SupabaseService _supabaseService;
  String _selectedCarAsset = 'assets/cars/Camaro.png';
  String _selectedBackgroundAsset = 'assets/backgrounds/forest_bg.png';
  final AudioManager _audioManager = AudioManager.instance;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService();
    _controller.text = playerName;
    _loadUserData();
    _signIn();
    _playMenuMusic();
  }

  void _loadUserData() {
    setState(() {
      playerName = _storage.getPlayerName();
      _selectedCarAsset = _storage.getSelectedCar();
      _selectedBackgroundAsset = _storage.getSelectedBackground();
      _controller.text = playerName;
    });
  }

  Future<void> _signIn() async {
    try {
      await _supabaseService.signIn(
        email: dotenv.env['AUTH_EMAIL']!,
        password: dotenv.env['AUTH_PASSWORD']!,
      );
    } catch (e) {
      debugPrint("Error auth: $e");
    }
  }

  Future<void> _playMenuMusic() async {
    await _audioManager.playMusic('menu_theme');
  }

  Future<void> _stopMenuMusic() async {
    await _audioManager.stopMusic();
  }

  void _changeName() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: RetroBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "INGRESA NOMBRE",
                style: getRetroStyle(size: 20, color: Colors.cyanAccent),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                style: getRetroStyle(),
                cursorColor: Colors.green,
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  hintText: "Tu nombre...",
                  hintStyle: TextStyle(
                    color: Colors.white54,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: RetroButton(
                      text: "CANCELAR",
                      color: Colors.red.shade900,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RetroButton(
                      text: "OK",
                      color: Colors.green.shade900,
                      onPressed: () {
                        setState(() {
                          playerName = _controller.text.isNotEmpty
                              ? _controller.text
                              : "Jugador";
                        });
                        _storage.savePlayerName(playerName);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCars() async {
    final newCar = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarsScreen(currentCarAsset: _selectedCarAsset),
      ),
    );
    if (newCar != null && newCar is String) {
      setState(() {
        _selectedCarAsset = newCar;
      });
    }
  }

  void _openBackgrounds() async {
    final newBackground = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            BackgroundStyles(currentBackground: _selectedBackgroundAsset),
      ),
    );
    if (newBackground != null && newBackground is String) {
      setState(() {
        _selectedBackgroundAsset = newBackground;
      });
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final bgImage = isLandscape
        ? "assets/backgrounds/menu_h_bg.png"
        : "assets/backgrounds/menu_bg.png";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(bgImage),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),

          Container(color: Colors.black.withOpacity(0.3)),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape =
                    constraints.maxWidth > constraints.maxHeight;

                if (isLandscape) {
                  return Row(
                    children: [
                      Expanded(flex: 4, child: Center(child: _buildTitle())),
                      Expanded(
                        flex: 5,
                        child: Center(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 40),
                              child: _buildControlPanel(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildTitle(),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        child: _buildControlPanel(),
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

  Widget _buildTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "POLY",
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: 60,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: Colors.yellowAccent,
            shadows: [
              Shadow(
                offset: Offset(4, 4),
                color: Colors.red.shade900,
                blurRadius: 0,
              ),
            ],
          ),
        ),
        Text(
          "RACER",
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: 60,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(4, 4),
                color: Colors.blue.shade900,
                blurRadius: 0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return RetroBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // JUGADOR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("PILOTO:", style: getRetroStyle(color: Colors.grey)),
              Row(
                children: [
                  Text(
                    playerName,
                    style: getRetroStyle(color: Colors.greenAccent),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _changeName,
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.white54, thickness: 1),
          const SizedBox(height: 10),

          // BOTÓN JUGAR
          RetroButton(
            text: "INICIAR CARRERA",
            color: const Color(0xFFAA0000),
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
                      backgroundAssetPath: _selectedBackgroundAsset,
                    ),
                  ),
                );
              }
              await Future.delayed(const Duration(milliseconds: 1000));

              if (mounted) {
                _playMenuMusic();
              }
            },
          ),

          const SizedBox(height: 10),

          // BOTONES SECUNDARIOS
          RetroButton(text: "GARAJE", onPressed: _openCars),
          RetroButton(text: "ESCENARIOS", onPressed: _openBackgrounds),
          RetroButton(text: "CONFIG", onPressed: _openSettings),
        ],
      ),
    );
  }
}
