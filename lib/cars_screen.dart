import 'package:flutter/material.dart';
import 'ui/retro_ui.dart';
import 'services/storage_service.dart';

class CarOption {
  final String name;
  final String description;
  final String assetPath;
  final String previewPath;

  CarOption({
    required this.name,
    required this.description,
    required this.assetPath,
    String? previewPath,
  }) : previewPath = previewPath ?? assetPath;
}

class CarsScreen extends StatefulWidget {
  final String currentCarAsset;
  const CarsScreen({super.key, required this.currentCarAsset});

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  late String _selectedCarAsset;

  final List<CarOption> _carOptions = [
    CarOption(
      name: 'Chevrolet Camaro',
      description:
          'El Camaro es un automóvil de alto rendimiento que combina estilo y potencia.',
      assetPath: 'assets/cars/Camaro.png',
      previewPath: 'assets/cars/Camaro.gif',
    ),
    CarOption(
      name: 'Honda Civic Type R',
      description:
          'El Civic Type R es un automóvil de alto rendimiento que combina estilo y potencia.',
      assetPath: 'assets/cars/TypeR.png',
      previewPath: 'assets/cars/TypeR.gif',
    ),
    CarOption(
      name: 'Nissan GTR Nismo',
      description:
          'El GTR Nismo es un automóvil de alto rendimiento que combina estilo y potencia.',
      assetPath: 'assets/cars/GTR.png',
      previewPath: 'assets/cars/GTR.gif',
    ),
    CarOption(
      name: 'Mazda Miata',
      description:
          'El Miata es un automóvil de alto rendimiento que combina estilo y potencia.',
      assetPath: 'assets/cars/Miata.png',
      previewPath: 'assets/cars/Miata.gif',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCarAsset = widget.currentCarAsset;

    final bool exists = _carOptions.any(
      (car) => car.assetPath == _selectedCarAsset,
    );

    if (!exists && _carOptions.isNotEmpty) {
      _selectedCarAsset = _carOptions.first.assetPath;
      StorageService().saveSelectedCar(_selectedCarAsset);
    }
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
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(bgImage, fit: BoxFit.cover),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                RetroBox(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_car,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'GARAJE',
                            style: getRetroStyle(
                              size: 20,
                              color: Colors.yellowAccent,
                            ),
                          ),
                        ],
                      ),

                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pop(_selectedCarAsset),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            color: Colors.red.shade900,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Text("X", style: getRetroStyle(size: 16)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: RetroBox(
                      padding: const EdgeInsets.all(8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int gridColumns = isLandscape ? 3 : 2;

                          return GridView.builder(
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: gridColumns,
                                  childAspectRatio: 0.65,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: _carOptions.length,
                            itemBuilder: (context, index) {
                              final car = _carOptions[index];
                              final isSelected =
                                  car.assetPath == _selectedCarAsset;
                              return _buildRetroCarSlot(car, isSelected);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroCarSlot(CarOption car, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border.all(
          color: isSelected ? Colors.greenAccent : Colors.white24,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey.shade900, Colors.black],
                ),
                border: Border.all(color: Colors.white10),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(car.previewPath, fit: BoxFit.contain),
            ),
          ),

          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    car.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: getRetroStyle(size: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    car.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          GestureDetector(
            onTap: () async {
              setState(() {
                _selectedCarAsset = car.assetPath;
              });
              await StorageService().saveSelectedCar(car.assetPath);
            },
            child: Container(
              height: 40,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00AA00)
                    : const Color(0xFF0000AA),
                border: Border.all(color: Colors.white54),
              ),
              child: Center(
                child: Text(
                  isSelected ? "EQUIPADO" : "SELECCIONAR",
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
