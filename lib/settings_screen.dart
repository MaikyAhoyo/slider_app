import 'package:flutter/material.dart';

/// Define un modelo simple para un coche
class CarOption {
  final String name;
  final String assetPath;

  CarOption({required this.name, required this.assetPath});
}

/// Pantalla para que el usuario elija su coche
class SettingsScreen extends StatefulWidget {
  final String currentCarAsset;

  const SettingsScreen({super.key, required this.currentCarAsset});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedCarAsset;

  // Lista de coches disponibles
  final List<CarOption> _carOptions = [
    CarOption(name: 'Naranja Clásico', assetPath: 'assets/cars/orange_car.png'),
    CarOption(name: 'Azul Veloz', assetPath: 'assets/cars/blue_car.png'),
    CarOption(name: 'Verde Deportivo', assetPath: 'assets/cars/green_car.png'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCarAsset = widget.currentCarAsset;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos el mismo fondo que el menú para consistencia
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/backgrounds/menu_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay oscuro
          Container(color: Colors.black.withOpacity(0.6)),

          // Contenido
          SafeArea(
            child: Column(
              children: [
                // AppBar personalizada
                AppBar(
                  title: const Text(
                    'Configuración',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      // Devuelve el coche seleccionado al menú
                      Navigator.of(context).pop(_selectedCarAsset);
                    },
                  ),
                ),

                // Título de la sección
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Elige tu coche',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Lista de coches
                Expanded(
                  child: ListView.builder(
                    itemCount: _carOptions.length,
                    itemBuilder: (context, index) {
                      final car = _carOptions[index];
                      final isSelected = car.assetPath == _selectedCarAsset;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCarAsset = car.assetPath;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.redAccent.withOpacity(0.8)
                                  : Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.redAccent
                                    : Colors.white.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Imagen del coche
                                Image.asset(
                                  car.assetPath,
                                  width: 100,
                                  height: 60,
                                  fit: BoxFit.contain,
                                  // Manejo de error si la imagen no carga
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 100,
                                      height: 60,
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.error_outline,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 20),
                                // Nombre del coche
                                Text(
                                  car.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                // Indicador de selección
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
