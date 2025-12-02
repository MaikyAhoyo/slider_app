import 'package:flutter/material.dart';
import 'dart:math';
import 'services/supabase_service.dart';
import 'services/audio_manager.dart';
import 'widgets/draggable_car.dart';
import 'widgets/pause_menu.dart';
import 'widgets/settings_menu.dart';
import 'widgets/game_over_menu.dart';

// Configuración de generación
const double carWidth = 120;
const double roadWidth = carWidth * 4;

class GameScreen extends StatefulWidget {
  final String playerName;
  final SupabaseService supabaseService;
  final String carAssetPath;
  final String backgroundAssetPath;

  const GameScreen({
    super.key,
    required this.playerName,
    required this.supabaseService,
    required this.carAssetPath,
    required this.backgroundAssetPath,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  final AudioManager _audioManager = AudioManager.instance;
  late AnimationController _gameLoopController;
  final Random _random = Random();

  // Lista de objetos en la carretera
  final List<GameObject> _gameObjects = [];

  // Configuración de generación (variables dinámicas)
  late double carWidth;
  late double roadWidth;
  late double screenWidth;
  late double screenHeight;
  static const double spawnRate =
      0.02; // Probabilidad de generar objeto por tick

  // Estado del juego
  double _fuel = 100.0;
  int _tires = 3; // Llantas (vidas)
  int _coins = 0; // Monedas recolectadas
  bool _isPaused = false;
  bool _isSettings = false;
  bool _isGameOver = false;
  double _carXOffset = 0.0;

  // Variables para scroll infinito y velocidad
  double _gameSpeed = 5.0;
  double _backgroundScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      screenWidth = size.width;
      screenHeight = size.height;
      roadWidth = screenWidth * 0.8;
      carWidth = 35;
      setState(() {});
    });

    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _gameLoopController.addListener(_onGameLoopTick);
    _gameLoopController.repeat();
    _playMusic();
  }

  /// Genera objetos aleatoriamente en la carretera
  void _spawnGameObject() {
    if (_random.nextDouble() < spawnRate) {
      final String randomObject = _getRandomObject();
      double width = 50;
      double height = 50;
      if (randomObject == 'assets/objects/rock_large.png') {
        width = 100;
        height = 50;
      }

      final double halfRoadWidth = roadWidth / 2;
      final double minX = -(halfRoadWidth - width / 2);
      final double maxX = halfRoadWidth - width / 2;
      final double randomX = minX + _random.nextDouble() * (maxX - minX);

      // Determinar posición inicial Y (avance)
      final orientation = MediaQuery.of(context).orientation;
      final bool isLandscape = orientation == Orientation.landscape;

      double startY;
      if (isLandscape) {
        // En landscape, empiezan a la derecha (screenWidth)
        startY = screenWidth + 100;
      } else {
        // En portrait, empiezan arriba (-100)
        startY = -100;
      }

      _gameObjects.add(
        GameObject(
          x: randomX,
          y: startY,
          asset: randomObject,
          width: width,
          height: height,
        ),
      );
    }
  }

  /// Retorna un tipo de objeto aleatorio
  String _getRandomObject() {
    final double roll = _random.nextDouble();
    if (roll < 0.01) {
      return 'assets/objects/tire.png';
    } else if (roll < 0.11) {
      return 'assets/objects/gas.png';
    } else if (roll < 0.41) {
      return 'assets/objects/coin.png';
    } else {
      return _random.nextBool()
          ? 'assets/objects/rock.png'
          : 'assets/objects/rock_large.png';
    }
  }

  /// Actualiza la posición de los objetos
  void _updateGameObjects() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;

    for (var i = _gameObjects.length - 1; i >= 0; i--) {
      if (isLandscape) {
        _gameObjects[i].y -= _gameSpeed;
        if (_gameObjects[i].y < -100) {
          _gameObjects.removeAt(i);
        }
      } else {
        _gameObjects[i].y += _gameSpeed;
        if (_gameObjects[i].y > screenHeight) {
          _gameObjects.removeAt(i);
        }
      }
    }
  }

  /// Detecta colisiones entre el carro y los objetos
  void _checkCollisions() {
    final orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;

    double carScreenX, carScreenY;
    double carHitboxWidth, carHitboxHeight;

    if (isLandscape) {
      carScreenX = 20;
      carScreenY = (screenHeight / 2) + _carXOffset - (carWidth / 2);
      carHitboxWidth = 70;
      carHitboxHeight = carWidth;
    } else {
      carScreenX = (screenWidth / 2) + _carXOffset - (carWidth / 2);
      carScreenY = screenHeight - 20 - 70;
      carHitboxWidth = carWidth;
      carHitboxHeight = 70;
    }

    for (var i = _gameObjects.length - 1; i >= 0; i--) {
      final GameObject obj = _gameObjects[i];
      double objScreenX, objScreenY;
      double objHitboxWidth, objHitboxHeight;

      if (isLandscape) {
        objScreenX = obj.y;
        objScreenY = (screenHeight / 2) + obj.x - (obj.width / 2);
        objHitboxWidth = obj.height * 0.7;
        objHitboxHeight = obj.width * 0.7;
      } else {
        objScreenX = (screenWidth / 2) + obj.x - (obj.width / 2);
        objScreenY = obj.y;
        objHitboxWidth = obj.width * 0.7;
        objHitboxHeight = obj.height * 0.7;
      }

      double carLeft = carScreenX;
      double carRight = carScreenX + carHitboxWidth;
      double carTop = carScreenY;
      double carBottom = carScreenY + carHitboxHeight;

      double objLeft = objScreenX;
      double objRight = objScreenX + objHitboxWidth;
      double objTop = objScreenY;
      double objBottom = objScreenY + objHitboxHeight;

      if (carLeft < objRight &&
          carRight > objLeft &&
          carTop < objBottom &&
          carBottom > objTop) {
        if (obj.asset == 'assets/objects/gas.png') {
          _fuel = (_fuel + 30).clamp(0, 100);
          _playSound('gas_fx');
        } else if (obj.asset == 'assets/objects/coin.png') {
          _coins += 100;
          _playSound('coin_fx');
        } else if (obj.asset == 'assets/objects/tire.png') {
          _tires += 1;
          _playSound('tire_fx');
        } else if (obj.asset == 'assets/objects/rock.png' ||
            obj.asset == 'assets/objects/rock_large.png') {
          _tires -= 1;
          _playSound('crash_fx');
        }
        _gameObjects.removeAt(i);
      }
    }
  }

  Future<void> _playMusic() async {
    String theme = 'game_theme';
    if (widget.backgroundAssetPath.contains('forest')) {
      theme = 'theme_forest';
    } else if (widget.backgroundAssetPath.contains('snow')) {
      theme = 'theme_snow';
    } else if (widget.backgroundAssetPath.contains('haunted')) {
      theme = 'theme_haunted';
    } else if (widget.backgroundAssetPath.contains('mars')) {
      theme = 'theme_mars';
    } else if (widget.backgroundAssetPath.contains('underwater')) {
      theme = 'theme_underwater';
    }
    await _audioManager.playMusic(theme);
  }

  Future<void> _stopMusic() async {
    await _audioManager.stopMusic();
  }

  Future<void> _playSound(String soundId) async {
    await _audioManager.playSfx(soundId);
  }

  void _onGameLoopTick() {
    if (_isGameOver) return;
    setState(() {
      _fuel -= 0.05;

      // Actualizar scroll del fondo
      _backgroundScrollOffset += _gameSpeed;
      final orientation = MediaQuery.of(context).orientation;
      final bool isLandscape = orientation == Orientation.landscape;

      double maxScroll = isLandscape ? screenWidth : screenHeight;
      if (_backgroundScrollOffset >= maxScroll) {
        _backgroundScrollOffset = 0;
      }

      _spawnGameObject();
      _updateGameObjects();
      _checkCollisions();
      if (_fuel <= 0) _endGame("¡Sin gasolina!");
      if (_tires <= 0) _endGame("¡Sin llantas!");
    });
  }

  void _pauseGame() {
    setState(() => _isPaused = true);
    _gameLoopController.stop();
  }

  void _resumeGame() {
    setState(() => _isPaused = false);
    _gameLoopController.repeat();
  }

  void _restartGame() {
    setState(() {
      _fuel = 100.0;
      _tires = 3;
      _coins = 0;
      _isGameOver = false;
      _gameSpeed = 5.0;
      _backgroundScrollOffset = 0.0;
    });
    _gameLoopController.reset();
    _gameLoopController.repeat();
    _gameObjects.clear();
    _isPaused = false;
  }

  void _endGame(String reason) {
    if (_isGameOver) return;
    _isGameOver = true;
    _gameLoopController.stop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return GameOverMenu(
          reason: reason,
          score: _coins,
          onReturnToMenu: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          onRestart: () {
            Navigator.of(context).pop();
            _restartGame();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _gameLoopController.removeListener(_onGameLoopTick);
    _gameLoopController.dispose();
    _stopMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final size = MediaQuery.of(context).size;
        screenWidth = size.width;
        screenHeight = size.height;

        if (orientation == Orientation.landscape) {
          roadWidth = screenHeight * 0.8;
        } else {
          roadWidth = screenWidth * 0.8;
        }

        return Scaffold(
          body: orientation == Orientation.portrait
              ? _buildPortraitLayout()
              : _buildLandscapeLayout(),
        );
      },
    );
  }

  Widget _buildPortraitLayout() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fondo dinámico con scroll infinito (Vertical)
        Positioned(
          top: _backgroundScrollOffset,
          left: 0,
          right: 0,
          height: screenHeight,
          child: Image.asset(widget.backgroundAssetPath, fit: BoxFit.cover),
        ),
        Positioned(
          top: _backgroundScrollOffset - screenHeight,
          left: 0,
          right: 0,
          height: screenHeight,
          child: Image.asset(widget.backgroundAssetPath, fit: BoxFit.cover),
        ),

        // Carretera transparente
        Align(
          alignment: Alignment.center,
          child: Container(width: roadWidth, color: Colors.transparent),
        ),

        // Objetos
        ..._gameObjects.map((obj) {
          final double posX = (screenWidth / 2) + obj.x;
          return Positioned(
            left: posX - (obj.width / 2),
            top: obj.y,
            child: Image.asset(
              obj.asset,
              width: obj.width,
              height: obj.height,
              fit: BoxFit.contain,
            ),
          );
        }).toList(),

        // Hitboxes (Opcional: comentar para producción)
        /*
        ..._gameObjects.map((obj) {
          final double posX = (screenWidth / 2) + obj.x;
          final double hitboxWidth = obj.width * 0.7;
          final double hitboxHeight = obj.height * 0.7;
          return Positioned(
            left: posX - (hitboxWidth / 2),
            top: obj.y,
            child: Container(
              width: hitboxWidth,
              height: hitboxHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
              ),
            ),
          );
        }).toList(),
        */

        // Carro
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: DraggableCar(
              imagePath: widget.carAssetPath,
              width: carWidth,
              height: 70,
              onPositionChanged: (value) {
                _carXOffset = value;
              },
            ),
          ),
        ),

        // Hitbox del carro (Opcional)
        /*
        Positioned(
          left: (screenWidth / 2) + _carXOffset - (carWidth / 2),
          bottom: 20,
          child: IgnorePointer(
            child: Container(
              width: carWidth,
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
            ),
          ),
        ),
        */

        // UI
        Positioned(top: 40, left: 10, right: 10, child: _buildGameUI()),

        // Menus
        if (_isPaused && !_isSettings)
          PauseMenu(
            onResume: _resumeGame,
            onRestart: _restartGame,
            onQuit: () => Navigator.of(context).pop(),
            onSettings: () {
              setState(() {
                _isSettings = true;
              });
            },
          ),
        if (_isSettings)
          SettingsMenu(
            onBack: () {
              setState(() {
                _isSettings = false;
              });
            },
          ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fondo dinámico con scroll infinito (Horizontal hacia la izquierda)
        // Imagen 1
        Positioned(
          left: -_backgroundScrollOffset,
          top: 0,
          bottom: 0,
          width: screenWidth,
          child: Image.asset(widget.backgroundAssetPath, fit: BoxFit.cover),
        ),
        // Imagen 2 (inmediatamente después)
        Positioned(
          left: -_backgroundScrollOffset + screenWidth,
          top: 0,
          bottom: 0,
          width: screenWidth,
          child: Image.asset(widget.backgroundAssetPath, fit: BoxFit.cover),
        ),

        // Carretera transparente
        Align(
          alignment: Alignment.center,
          child: Container(height: roadWidth, color: Colors.transparent),
        ),

        // Objetos
        ..._gameObjects.map((obj) {
          final double posY = (screenHeight / 2) + obj.x;
          return Positioned(
            left: obj.y,
            top: posY - (obj.width / 2),
            child: Transform.rotate(
              angle: pi / 2,
              child: Image.asset(
                obj.asset,
                width: obj.width,
                height: obj.height,
                fit: BoxFit.contain,
              ),
            ),
          );
        }).toList(),

        // Hitboxes (Opcional)
        /*
        ..._gameObjects.map((obj) {
          final double posY = (screenHeight / 2) + obj.x;
          final double hitboxWidth = obj.height * 0.7;
          final double hitboxHeight = obj.width * 0.7;
          return Positioned(
            left: obj.y,
            top: posY - (hitboxHeight / 2),
            child: Container(
              width: hitboxWidth,
              height: hitboxHeight,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
              ),
            ),
          );
        }).toList(),
        */

        // Carro
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: SizedBox(
              height: roadWidth,
              child: DraggableCarHorizontal(
                imagePath: widget.carAssetPath,
                width: 70,
                height: carWidth,
                onPositionChanged: (value) {
                  _carXOffset = value;
                },
              ),
            ),
          ),
        ),

        // Hitbox del carro (Opcional)
        /*
        Positioned(
          left: 20,
          top: (screenHeight / 2) + _carXOffset - (carWidth / 2),
          child: IgnorePointer(
            child: Container(
              width: 70,
              height: carWidth,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
            ),
          ),
        ),
        */

        // UI
        Positioned(top: 10, left: 10, right: 10, child: _buildGameUI()),

        // Menus
        if (_isPaused && !_isSettings)
          Center(
            child: PauseMenu(
              onResume: _resumeGame,
              onRestart: _restartGame,
              onQuit: () => Navigator.of(context).pop(),
              onSettings: () {
                setState(() {
                  _isSettings = true;
                });
              },
            ),
          ),
        if (_isSettings)
          Center(
            child: SettingsMenu(
              onBack: () {
                setState(() {
                  _isSettings = false;
                });
              },
            ),
          ),
      ],
    );
  }

  Widget _buildGameUI() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.pause, color: Colors.white),
            onPressed: () {
              setState(() {
                _isPaused = !_isPaused;
              });
              _pauseGame();
            },
          ),
          Row(
            children: [
              const Text('🪙', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 5),
              Text(
                '$_coins',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.tire_repair, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                '$_tires',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.local_gas_station, color: Colors.white),
              const SizedBox(width: 5),
              SizedBox(
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _fuel / 100.0,
                    backgroundColor: Colors.grey,
                    color: _fuel > 20 ? Colors.green : Colors.red,
                    minHeight: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GameObject {
  double x;
  double y;
  String asset;
  double width;
  double height;

  GameObject({
    required this.x,
    required this.y,
    required this.asset,
    required this.width,
    required this.height,
  });
}
