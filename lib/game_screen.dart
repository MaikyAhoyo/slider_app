import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'widgets/draggable_car.dart';

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

  // Estado del juego
  double _fuel = 100.0;
  int _tires = 3;
  int _score = 0;
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();

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

  /// Este es el corazón del juego, se llama ~60 veces por segundo
  void _onGameLoopTick() {
    if (_isGameOver) return;

    // setState() le dice a Flutter que redibuje la pantalla con los nuevos valores
    setState(() {
      // 1. Reducir la gasolina
      // Ajusta este valor para que se consuma más rápido o más lento
      _fuel -= 0.05; // Ejemplo: reduce la gasolina lentamente

      // 3. Lógica futura:
      // - Mover obstáculos y monedas hacia abajo

      // - Comprobar colisiones (carro vs obstáculo, carro vs moneda)
      // - Actualizar puntuación si recoge moneda
      // - Reducir llantas si choca

      // 4. Comprobar condiciones de Game Over
      if (_fuel <= 0) {
        _endGame("¡Sin gasolina!");
      }
      // if (_tires <= 0) {
      //   _endGame("¡Sin llantas!");
      // }
    });
  }

  /// Termina el juego, detiene el bucle y muestra el diálogo
  void _endGame(String reason) {
    if (_isGameOver) return; // Evita llamar esto múltiples veces

    _isGameOver = true;
    _gameLoopController.stop();

    // Guardar la puntuación en Supabase
    //widget.supabaseService.checkAndUpsertPlayer(
    //  playerName: widget.playerName,
    //  score: _score,
    //);

    // Muestra el diálogo de Game Over
    showDialog(
      context: context,
      barrierDismissible: false, // El usuario no puede cerrar el diálogo
      builder: (context) {
        return AlertDialog(
          title: const Text('¡Juego Terminado!'),
          content: Text('$reason\nPuntuación final: $_score'),
          actions: [
            TextButton(
              child: const Text('Volver al Menú'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.of(context).pop(); // Vuelve a la pantalla de menú
              },
            ),
          ],
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
    // Ancho del carro y carretera
    const double carWidth = 120;
    // final double roadWidth = carWidth * 4;

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
              // width: roadWidth,
              width: MediaQuery.of(context).size.width * 0.8,
              color: Colors.grey[700],
              // Aquí podrías añadir un CustomPaint para dibujar las líneas de la carretera
            ),
          ),

          // 3. El carro (tu widget)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: DraggableCar(
                imagePath: widget.carAssetPath,
                width: carWidth,
                height: 70,
              ),
            ),
          ),

          // 4. Interfaz de Usuario (UI) en la parte superior
          Positioned(top: 40, left: 10, right: 10, child: _buildGameUI()),
        ],
      ),
    );
  }

  /// Construye la UI del juego (Puntos, Gasolina, Llantas)
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
          // Puntuación
          Text(
            'Puntos: $_score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Llantas
          Row(
            children: [
              Icon(Icons.tire_repair, color: Colors.white),
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
              Icon(Icons.local_gas_station, color: Colors.white),
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
