import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'services/supabase_service.dart';
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

  const GameScreen({
    super.key,
    required this.playerName,
    required this.supabaseService,
    required this.carAssetPath,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
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
  int _tires = 3; // Llantas (vidas) - inicia en 4
  int _score = 0; // Puntuación
  int _coins = 0; // Monedas recolectadas
  bool _isPaused = false;
  bool _isSettings = false;
  bool _isGameOver = false;
  double _carXOffset = 0.0;

  /// Genera objetos aleatoriamente en la carretera
  void _spawnGameObject() {
    if (_random.nextDouble() < spawnRate) {
      final String randomObject = _getRandomObject();

      // Determinar el tamaño según el tipo de objeto
      double width = 50;
      double height = 50;

      if (randomObject == 'assets/objects/rock_large.png') {
        // Rock large tiene el doble de ancho, mismo largo
        width = 100;
        height = 50;
      }

      // Generar SOLO dentro del ancho de la carretera
      // Considerar el ancho del objeto para no salir de la carretera
      final double halfRoadWidth = roadWidth / 2;
      final double minX = -(halfRoadWidth - width / 2);
      final double maxX = halfRoadWidth - width / 2;
      final double randomX = minX + _random.nextDouble() * (maxX - minX);

      _gameObjects.add(
        GameObject(
          x: randomX,
          y: -100,
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

    // Probabilidades:
    // 0.00 - 0.01: Llanta (1%) - Muy raro
    // 0.01 - 0.11: Gasolina (10%) - Raro
    // 0.11 - 0.41: Moneda (30%)
    // 0.41 - 1.00: Roca (59%)

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

    for (var i = _gameObjects.length - 1; i >= 0; i--) {
      _gameObjects[i].y += 5; // Velocidad de caída

      // Elimina objetos que salieron de la pantalla
      if (_gameObjects[i].y > screenHeight) {
        _gameObjects.removeAt(i);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Usar addPostFrameCallback para esperar a que el widget esté listo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Calcular dinámicamente el tamaño del carro basado en el ancho de pantalla
      final size = MediaQuery.of(context).size;
      screenWidth = size.width;
      screenHeight = size.height;
      // Carretera toma 80% del ancho de pantalla
      roadWidth = screenWidth * 0.8;
      // Carro es 35px de ancho
      carWidth = 35;

      setState(() {});
    });

    _gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 1,
      ), // La duración no importa, solo el tick
    );

    // Agregamos un listener que se llama en cada frame (tick)
    _gameLoopController.addListener(_onGameLoopTick);

    // Iniciamos el bucle del juego
    _gameLoopController.repeat();
  }

  /// Detecta colisiones entre el carro y los objetos
  void _checkCollisions() {
    // Posición del carro (aproximada, al centro abajo)
    final double carScreenX = (screenWidth / 2) + _carXOffset;
    final double carScreenY = screenHeight - 100;

    // Hitbox completa: usar el tamaño real del carro
    final double carHitboxWidth = carWidth;
    final double carHitboxHeight = 70;

    for (var i = _gameObjects.length - 1; i >= 0; i--) {
      final GameObject obj = _gameObjects[i];

      // Posición del objeto en pantalla
      final double objScreenX = (screenWidth / 2) + obj.x;
      final double objScreenY = obj.y;

      // Hitbox completa de los objetos
      final double objHitboxWidth = obj.width;
      final double objHitboxHeight = obj.height;

      // Detectar colisión (simple AABB collision)
      if (carScreenX - carHitboxWidth / 2 < objScreenX + objHitboxWidth / 2 &&
          carScreenX + carHitboxWidth / 2 > objScreenX - objHitboxWidth / 2 &&
          carScreenY < objScreenY + objHitboxHeight &&
          carScreenY + carHitboxHeight > objScreenY) {
        // Hay colisión
        if (obj.asset == 'assets/objects/gas.png') {
          // Si es gas, sumar 30 a fuel
          _fuel = (_fuel + 30).clamp(0, 100); // Max 100
          _playSound('gas_fx.mp3');
        } else if (obj.asset == 'assets/objects/coin.png') {
          // Si es moneda, sumar 1 al contador de monedas
          _coins += 100;
          _playSound('coin_fx.mp3');
        } else if (obj.asset == 'assets/objects/tire.png') {
          // Si es llanta, sumar 1 vida
          _tires += 1;
          _playSound('tire_fx.mp3'); // Usar sonido de moneda por ahora
        } else if (obj.asset == 'assets/objects/rock.png' ||
            obj.asset == 'assets/objects/rock_large.png') {
          // Si es roca, restar 1 llanta
          _tires -= 1;
          _playSound('crash_fx.mp3');
          // No establecer _isGameOver = true aquí, dejar que _onGameLoopTick lo maneje
        }

        // Eliminar el objeto
        _gameObjects.removeAt(i);
      }
    }
  }

  Future<void> _playSound(String fileName) async {
    try {
      // Crear un nuevo player para cada sonido para permitir superposición (overlapping)
      final player = AudioPlayer();
      await player.play(AssetSource('sfx/$fileName'));
      // Liberar recursos cuando termine de reproducir
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  /// Este es el corazón del juego, se llama ~60 veces por segundo
  void _onGameLoopTick() {
    if (_isGameOver) return;

    // setState() le dice a Flutter que redibuje la pantalla con los nuevos valores
    setState(() {
      // 1. Reducir la gasolina
      _fuel -= 0.05;

      // 2. Generar objetos aleatoriamente
      _spawnGameObject();

      // 3. Actualizar posición de objetos
      _updateGameObjects();

      // 4. Detectar colisiones
      _checkCollisions();

      // 5. Comprobar condiciones de Game Over
      if (_fuel <= 0) {
        _endGame("¡Sin gasolina!");
      }
      if (_tires <= 0) {
        _endGame("¡Sin llantas!");
      }
    });
  }

  /// Pausa el juego, detiene el bucle
  void _pauseGame() {
    setState(() {
      _isPaused = true;
    });
    _gameLoopController.stop();
  }

  /// Resume el juego, reanuda el bucle
  void _resumeGame() {
    setState(() {
      _isPaused = false;
    });
    _gameLoopController.repeat();
  }

  /// Reinicia el juego, resetea los valores y vuelve a iniciar el bucle
  void _restartGame() {
    setState(() {
      _fuel = 100.0;
      _tires = 3;
      _coins = 0;
      _isGameOver = false;
    });
    _gameLoopController.reset();
    _gameLoopController.repeat();
    _gameObjects.clear();
    _isPaused = false;
  }

  /// Termina el juego, detiene el bucle y muestra el diálogo
  void _endGame(String reason) {
    if (_isGameOver) return; // Evita llamar esto múltiples veces

    _isGameOver = true;
    _gameLoopController.stop();

    // Guardar la puntuación en Supabase
    //widget.supabaseService.checkAndUpsertPlayer(
    //  playerName: widget.playerName,
    //  score: _coins,
    //);

    // Muestra el diálogo de Game Over
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Fondo (Cielo)
          Container(color: Colors.lightBlue[100]),

          // 2. Carretera
          Align(
            alignment: Alignment.center,
            child: Container(
              width: roadWidth,
              color: Colors.grey[700],
              // Aquí podrías añadir un CustomPaint para dibujar las líneas de la carretera
            ),
          ),

          // 3. Objetos del juego
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

          // DEBUG: Hitbox de los objetos
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

          // 4. El carro (tu widget)
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

          // DEBUG: Hitbox del carro
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

          // 5. Interfaz de Usuario (UI) en la parte superior
          Positioned(top: 40, left: 10, right: 10, child: _buildGameUI()),

          // 6. Menú de Pausa
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

          // 7. Menú de Configuración
          if (_isSettings)
            SettingsMenu(
              onBack: () {
                setState(() {
                  _isSettings = false;
                });
              },
            ),
        ],
      ),
    );
  }

  /// Construye la UI del juego (Pausa, Puntos, Gasolina, Llantas)
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
          // Botón del menú de pausa
          IconButton(
            icon: const Icon(Icons.pause, color: Colors.white),
            onPressed: () {
              setState(() {
                _isPaused = !_isPaused;
              });
              _pauseGame();
            },
          ),

          // Monedas
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

          // Llantas
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

          // Gasolina
          Row(
            children: [
              const Icon(Icons.local_gas_station, color: Colors.white),
              const SizedBox(width: 5),
              // Barra de progreso para la gasolina
              SizedBox(
                width: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _fuel / 100.0, // Valor entre 0.0 y 1.0
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

/// Clase para representar un objeto en el juego
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
