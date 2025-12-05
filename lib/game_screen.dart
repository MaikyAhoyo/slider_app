import 'package:flutter/material.dart';
import 'dart:math';
import 'services/supabase_service.dart';
import 'services/audio_manager.dart';
import 'services/storage_service.dart';
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

  // Variable para controlar el fondo real (cargado de memoria)
  late String _currentBackgroundPath;

  // Lista de objetos en la carretera
  final List<GameObject> _gameObjects = [];

  // Configuración de generación (variables dinámicas)
  late double carWidth;
  late double roadWidth;
  late double screenWidth;
  late double screenHeight;
  static const double spawnRate = 0.095;
  static const double targetAspectRatio = 9 / 16;
  static const double targetLandscapeRatio = 16 / 9;

  // Estado del juego
  double _fuel = 100.0;
  int _tires = 3;
  int _coins = 0;
  bool _isPaused = false;
  bool _isSettings = false;
  bool _isGameOver = false;
  double _carXOffset = 0.0;

  // Variables para scroll infinito y velocidad
  double _gameSpeed = 7.0;
  double _backgroundScrollOffset = 0.0;

  @override
  void initState() {
    super.initState();

    final savedBg = StorageService().getSelectedBackground();
    _currentBackgroundPath = savedBg.isNotEmpty
        ? savedBg
        : widget.backgroundAssetPath;

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

  // Transforma los archivos de fondo para que sean responsivos
  String _getResponsiveBackground(bool isLandscape) {
    if (!isLandscape) return _currentBackgroundPath;

    if (_currentBackgroundPath.endsWith('_bg.png')) {
      return _currentBackgroundPath.replaceAll('_bg.png', '_h_bg.png');
    }
    return _currentBackgroundPath;
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

      // Determinar posición inicial Y (avance)
      final orientation = MediaQuery.of(context).orientation;
      final bool isLandscape = orientation == Orientation.landscape;

      double startY;
      if (isLandscape) {
        startY = screenWidth + 100;
      } else {
        startY = -100;
      }

      for (int attempt = 0; attempt < 15; attempt++) {
        final double randomX = minX + _random.nextDouble() * (maxX - minX);

        bool overlaps = false;

        for (final obj in _gameObjects) {
          if ((isLandscape && (obj.y - startY).abs() < 150) ||
              (!isLandscape && (obj.y - startY).abs() < 150)) {
            double margin = 8.0;

            if (randomX < obj.x + obj.width + margin &&
                randomX + width + margin > obj.x) {
              overlaps = true;
              break;
            }
          }
        }
        if (!overlaps) {
          _gameObjects.add(
            GameObject(
              x: randomX,
              y: startY,
              asset: randomObject,
              width: width,
              height: height,
            ),
          );
          break;
        }
      }
    }
  }

  /// Retorna un tipo de objeto aleatorio
  String _getRandomObject() {
    final double roll = _random.nextDouble();

    if (_fuel < 15.0 && roll < 0.40) {
      return 'assets/objects/gas.png';
    }

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
        objHitboxWidth = obj.width * 0.7;
        objHitboxHeight = obj.height * 0.7;
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
          _playSound('gas_sfx');
        } else if (obj.asset == 'assets/objects/coin.png') {
          _coins += 100;
          _playSound('coin_sfx');
        } else if (obj.asset == 'assets/objects/tire.png') {
          _tires += 1;
          _playSound('tire_sfx');
        } else if (obj.asset == 'assets/objects/rock.png' ||
            obj.asset == 'assets/objects/rock_large.png') {
          _tires -= 1;
          _playSound('crash_sfx');
        }
        _gameObjects.removeAt(i);
      }
    }
  }

  /// Reproduce música dependiendo del fondo (Ahora usa _currentBackgroundPath)
  Future<void> _playMusic() async {
    String theme = 'menu_theme';
    if (_currentBackgroundPath.contains('forest')) {
      theme = 'forest_theme';
    } else if (_currentBackgroundPath.contains('snow')) {
      theme = 'snow_theme';
    } else if (_currentBackgroundPath.contains('haunted')) {
      theme = 'haunted_theme';
    } else if (_currentBackgroundPath.contains('desert')) {
      theme = 'desert_theme';
    } else if (_currentBackgroundPath.contains('underwater')) {
      theme = 'underwater_theme';
    } else if (_currentBackgroundPath.contains('futuristic')) {
      theme = 'futuristic_theme';
    }
    await _audioManager.playMusic(theme);
  }

  /// Detiene la música
  Future<void> _stopMusic() async {
    await _audioManager.stopMusic();
  }

  /// Reproduce un sonido
  Future<void> _playSound(String soundId) async {
    await _audioManager.playSfx(soundId);
  }

  /// Actualiza la dificultad del juego
  void _updateDifficulty() {
    double newSpeed = 5.0 + (_coins / 300) * 0.5;
    _gameSpeed = newSpeed.clamp(7.0, 15.0);
  }

  /// Actualiza el bucle del juego
  void _onGameLoopTick() {
    if (_isGameOver) return;
    setState(() {
      _fuel -= 0.05;
      _updateDifficulty();
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

  /// Pausa el juego
  void _pauseGame() {
    setState(() => _isPaused = true);
    _gameLoopController.stop();
  }

  /// Reanuda el juego
  void _resumeGame() {
    setState(() => _isPaused = false);
    _gameLoopController.repeat();
  }

  /// Reinicia el juego
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

  /// Finaliza el juego
  void _endGame(String reason) {
    if (_isGameOver) return;
    _isGameOver = true;
    _gameLoopController.stop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        _playSound('game_over_sfx');
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

        // Calcular dimensiones efectivas del juego
        double effectiveWidth = size.width;
        double effectiveHeight = size.height;
        bool needConstrain = false;

        // Si estamos en portrait y la pantalla es muy ancha (ej. tablets),
        // limitamos el ancho para mantener la relación de aspecto 9:16
        if (orientation == Orientation.portrait) {
          final double currentAspectRatio = size.width / size.height;
          if (currentAspectRatio > targetAspectRatio) {
            needConstrain = true;
            effectiveWidth = size.height * targetAspectRatio;
          }
        }
        // Si estamos en landscape y la pantalla es muy ancha (ej. teléfonos ultra-wide),
        // limitamos el ancho para mantener la relación de aspecto 16:9
        else {
          final double currentAspectRatio = size.width / size.height;
          if (currentAspectRatio > targetLandscapeRatio) {
            needConstrain = true;
            effectiveWidth = size.height * targetLandscapeRatio;
          }
        }

        // Actualizar variables globales del estado
        screenWidth = effectiveWidth;
        screenHeight = effectiveHeight;

        if (orientation == Orientation.landscape) {
          roadWidth = screenHeight * 0.8;
        } else {
          roadWidth = screenWidth * 0.8;
        }

        final Widget content = orientation == Orientation.portrait
            ? _buildPortraitLayout()
            : _buildLandscapeLayout();

        if (needConstrain) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: SizedBox(
                width: effectiveWidth,
                height: effectiveHeight,
                child: ClipRect(
                  child: content,
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            body: content,
          );
        }
      },
    );
  }

  /// Construye la pantalla en modo vertical
  Widget _buildPortraitLayout() {
    final String bgPath = _getResponsiveBackground(false);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: _backgroundScrollOffset,
          left: 0,
          right: 0,
          height: screenHeight,
          child: Image.asset(bgPath, fit: BoxFit.cover),
        ),
        Positioned(
          top: _backgroundScrollOffset - screenHeight,
          left: 0,
          right: 0,
          height: screenHeight,
          child: Image.asset(bgPath, fit: BoxFit.cover),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(width: roadWidth, color: Colors.transparent),
        ),
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
        Positioned(top: 40, left: 10, right: 10, child: _buildGameUI()),
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

  /// Construye la pantalla en modo paisaje
  Widget _buildLandscapeLayout() {
    final String bgPath = _getResponsiveBackground(true);

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: -_backgroundScrollOffset,
          top: 0,
          bottom: 0,
          width: screenWidth,
          child: Image.asset(bgPath, fit: BoxFit.cover),
        ),
        Positioned(
          left: -_backgroundScrollOffset + screenWidth,
          top: 0,
          bottom: 0,
          width: screenWidth,
          child: Image.asset(bgPath, fit: BoxFit.cover),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(height: roadWidth, color: Colors.transparent),
        ),
        ..._gameObjects.map((obj) {
          final double posY = (screenHeight / 2) + obj.x;
          return Positioned(
            left: obj.y,
            top: posY - (obj.width / 2),
            child: Image.asset(
              obj.asset,
              width: obj.width,
              height: obj.height,
              fit: BoxFit.contain,
            ),
          );
        }).toList(),
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
        Positioned(top: 10, left: 10, right: 10, child: _buildGameUI()),
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
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0000AA), Color(0xFF000044)],
        ),
        border: Border.all(color: Colors.white, width: 2.0),
        boxShadow: const [
          BoxShadow(color: Colors.black54, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isPaused = !_isPaused;
              });
              _pauseGame();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54),
                color: Colors.black26,
              ),
              child: const Icon(Icons.pause, color: Colors.white, size: 24),
            ),
          ),
          Row(
            children: [
              const Text(
                '\$',
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 20,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '$_coins'.padLeft(3, '0'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, offset: Offset(2, 2))],
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.tire_repair,
                color: Colors.orangeAccent,
                size: 20,
              ),
              const SizedBox(width: 5),
              Text(
                '$_tires',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, offset: Offset(2, 2))],
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(
                Icons.local_gas_station,
                color: Colors.cyanAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Container(
                width: 100,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (_fuel / 100.0).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _fuel > 20
                            ? [Colors.greenAccent, Colors.green]
                            : [Colors.redAccent, Colors.red],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
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
